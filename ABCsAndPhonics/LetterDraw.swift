import SwiftUI
import UIKit

enum LetterDrawAlphabet {
    static let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map(String.init)

    static func shuffled(startingAfter previousStart: String, lastShown: String = "") -> [String] {
        let first = letters.filter { $0 != previousStart && $0 != lastShown }.randomElement()!
        return [first] + letters.filter { $0 != first }.shuffled()
    }
}

/// Uses matching centerline letterforms and one guided stroke at a time.
struct LetterDraw: View {
    @StateObject private var play = LiteracyPlay(total: 26)
    @AppStorage("letterDraw.previousStartingLetter") private var previousStartingLetter = ""
    @AppStorage("letterDraw.lastShownLetter") private var lastShownLetter = ""
    @State private var letters: [String] = []
    @State private var canvasID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            if letters.indices.contains(play.round) {
                let letter = letters[play.round]
                LiteracyStage(title: "Letter Draw", prompt: "Draw over the big letter \(letter). Or draw it in the air with your grown-up.", play: play, onReplay: restart, progressLabel: "Letter", nextLabel: "Next letter") {
                    VStack(spacing: 18) {
                        LetterTraceView(letter: letter, isComplete: Binding(
                            get: { play.solved },
                            set: { done in if done { play.win("You explored the lines in \(letter)!") } }
                        ))
                        .id("\(play.round)-\(canvasID)")
                        .frame(height: 370)
                        .padding(20)
                        .background(Color(red: 0.15, green: 0.32, blue: 0.36), in: RoundedRectangle(cornerRadius: 26))
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Drawing canvas for letter \(letter)")
                        .accessibilityIdentifier("letter-draw.canvas")
                        .accessibilityHint("Trace the large dotted letter with your finger, or use the air drawing button below.")
                        ToddlerActionButton(title: "Clear my drawing", systemImage: "arrow.counterclockwise", color: .orange) { canvasID = UUID() }
                        ToddlerActionButton(title: "We drew it in the air", systemImage: "hand.draw.fill", color: .orange) {
                            play.win("You made the letter \(letter) together!")
                        }
                    }
                }
            }
        }
        .onAppear(perform: restart)
        .onChange(of: play.round) { _, round in
            if letters.indices.contains(round) { lastShownLetter = letters[round] }
        }
    }

    private func restart() {
        letters = LetterDrawAlphabet.shuffled(startingAfter: previousStartingLetter, lastShown: lastShownLetter)
        previousStartingLetter = letters[0]
        lastShownLetter = letters[0]
        canvasID = UUID()
        play.replay()
    }
}

struct LetterTraceView: View {
    let letter: String
    @Binding var isComplete: Bool
    @State private var step = 0
    @State private var drawing: [CGPoint] = []
    @GestureState private var tracing = false
    private var guides: [LetterTraceStroke] { LetterFormation.strokes[letter] ?? [] }
    var body: some View {
        VStack(spacing: 10) {
            Text(isComplete ? "Great tracing!" : "Stroke \(step + 1) of \(guides.count) · Start at the orange dot")
                .font(.headline).foregroundStyle(.white).multilineTextAlignment(.center)
            Text(guides.indices.contains(step) ? guides[step].hint : "You made every part of the letter.")
                .font(.subheadline).foregroundStyle(.white).multilineTextAlignment(.center).frame(minHeight: 40)
            GeometryReader { geo in
                ZStack {
                    ForEach(guides.indices, id: \.self) { index in
                        let points = guides[index].fitted(in: geo.size)
                        LetterTraceStroke.path(points).stroke(index < step ? Color.green : Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        if index == step {
                            LetterTraceStroke.path(points).stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [2, 9]))
                            if let start = points.first {
                                Circle().fill(.orange).frame(width: 26, height: 26)
                                    .overlay(Text("\(index + 1)").font(.caption.bold()).foregroundStyle(.black)).position(start)
                            }
                            let arrowIndex = min(points.count - 1, max(1, points.count / 3))
                            let before = points[arrowIndex - 1], tip = points[arrowIndex]
                            Image(systemName: "arrowtriangle.right.fill").font(.system(size: 16)).foregroundStyle(.orange)
                                .rotationEffect(.radians(atan2(tip.y-before.y, tip.x-before.x))).position(tip)
                        }
                    }
                    LetterTraceStroke.path(drawing).stroke(.cyan, style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round))
                }.contentShape(Rectangle())
                    .highPriorityGesture(DragGesture(minimumDistance: 0).updating($tracing) { _, active, _ in active = true }
                        .onChanged { value in
                            guard !isComplete, guides.indices.contains(step) else { return }
                            drawing.append(value.location)
                        }.onEnded { _ in
                            guard !isComplete, guides.indices.contains(step) else { return }
                            if guides[step].covered(by: drawing, in: geo.size) {
                                step += 1
                                if step == guides.count { isComplete = true }
                            }
                            drawing = []
                        })
                    .clipped()
            }
        }
    }
}
