import SwiftUI
import AVFoundation

struct SleepySheepSession {
    private(set) var count = 0
    private(set) var isCounting = false
    private(set) var hasArrived = false
    private(set) var finished = false
    static let prompt = "Let's count sheep!"
    static let completion = "One hundred sheep! You counted all the way to one hundred. Sweet dreams!"

    @discardableResult mutating func beginHop() -> Bool {
        guard !isCounting, !finished, count < 100 else { return false }
        isCounting = true; hasArrived = false
        return true
    }
    mutating func arrive() {
        guard isCounting, !hasArrived, count < 100 else { return }
        count += 1; hasArrived = true
    }
    mutating func finishCount() {
        guard isCounting, hasArrived else { return }
        isCounting = false; finished = count == 100
    }
}

private struct SheepHop: GeometryEffect {
    var progress: CGFloat
    let distance: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: progress * distance,
                                             y: -abs(sin(progress * .pi)) * 65))
    }
}

struct SleepySheepGame: View {
    @State private var session = SleepySheepSession()
    @State private var hopID: UUID?
    @State private var position: CGFloat = -1
    @StateObject private var narrator = GameNarrator()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ToddlerGameScaffold(title: "Sleepy Sheep", prompt: session.finished ? SleepySheepSession.completion : SleepySheepSession.prompt,
                            accent: .indigo, completion: session.finished, onReplay: {
            narrator.stop(); session = SleepySheepSession(); position = -1; queueSheep()
        }) {
            Text("\(session.count)")
                .font(.system(size: 64, weight: .bold, design: .rounded)).monospacedDigit()
                .accessibilityLabel("\(session.count) sheep counted")
                .accessibilityIdentifier("counting.sheep.total")
            Text("Count to 100").font(.headline)
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 26).fill(Color.indigo.opacity(0.12))
                    Image(systemName: "moon.stars.fill").font(.system(size: 44)).foregroundStyle(.indigo)
                        .position(x: geometry.size.width - 50, y: 42)
                    Ellipse().fill(Color.green.opacity(0.25))
                        .frame(width: geometry.size.width * 1.4, height: 110)
                        .position(x: geometry.size.width / 2, y: 255)
                    ToddlerArt(asset: "sheep", size: 130)
                        .modifier(SheepHop(progress: reduceMotion ? 0 : position, distance: geometry.size.width / 2 + 90))
                        .opacity(reduceMotion && position != 0 ? 0 : 1)
                        .offset(y: 45)
                        .accessibilityLabel("Sheep")
                        .accessibilityIdentifier("counting.sheep.picture")
                }.clipShape(RoundedRectangle(cornerRadius: 26))
            }.frame(height: 270)
            ToddlerActionButton(title: "Count sheep", systemImage: "plus.circle.fill", color: .indigo, action: queueSheep)
                .disabled(session.isCounting || session.finished)
                .accessibilityIdentifier("counting.sheep.count")
            Text(session.finished ? "100 sheep. Sweet dreams!" : "Tap Count sheep to welcome the next sheep.")
                .font(.headline).multilineTextAlignment(.center)
        }
        .onAppear { if session.count == 0 && !session.isCounting { queueSheep() } }
        .task(id: hopID) {
            guard hopID != nil, session.isCounting else { return }
            do {
                if session.count == 0 {
                    // Allow the brief introduction to finish before Ruth counts one.
                    try await Task.sleep(for: .seconds(speechDuration(SleepySheepSession.prompt)))
                } else {
                    withAnimation(reduceMotion ? nil : .linear(duration: 0.45)) { position = 1 }
                    try await Task.sleep(for: .milliseconds(reduceMotion ? 100 : 450))
                }
                position = -1
                // Commit the offscreen starting position before animating the new sheep.
                try await Task.sleep(for: .milliseconds(40))
                withAnimation(reduceMotion ? nil : .linear(duration: 0.45)) { position = 0 }
                try await Task.sleep(for: .milliseconds(reduceMotion ? 100 : 450))
                try Task.checkCancellation()
                session.arrive()
                narrator.speak("\(session.count)")
                try await Task.sleep(for: .seconds(speechDuration("\(session.count)")))
                try Task.checkCancellation()
                session.finishCount()
            } catch { return }
        }
        .onDisappear { narrator.stop() }
    }

    private func queueSheep() {
        guard session.beginHop() else { return }
        hopID = UUID()
    }
    private func speechDuration(_ text: String) -> TimeInterval {
        guard GameNarrator.promptsEnabled(), let url = NarrationAudioCatalog.shared.url(for: text),
              let audio = try? AVAudioPlayer(contentsOf: url) else { return 0.15 }
        return max(0.15, audio.duration + 0.2)
    }
}
