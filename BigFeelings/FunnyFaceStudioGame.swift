import SwiftUI

/// The same puppet changes only its expression, so color never gives away an answer.
struct StudioFace: View {
    let emotion: StudioEmotion
    var size: CGFloat = 220
    var body: some View {
        Canvas { context, bounds in
            let scale = bounds.width
            func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * scale, y: y * scale) }
            func oval(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> Path {
                Path(ellipseIn: CGRect(x: x * scale, y: y * scale, width: w * scale, height: h * scale))
            }
            let ink = Color(red: 0.28, green: 0.16, blue: 0.12)
            let line = StrokeStyle(lineWidth: max(2, scale * 0.025), lineCap: .round, lineJoin: .round)
            context.fill(oval(0.02, 0.02, 0.96, 0.96), with: .color(Color(red: 1, green: 0.82, blue: 0.53)))
            context.stroke(oval(0.02, 0.02, 0.96, 0.96), with: .color(.brown.opacity(0.22)), lineWidth: 2)
            for x: CGFloat in [0.32, 0.68] {
                var brow = Path()
                let left = x < 0.5
                let tilt: CGFloat = emotion == .mad ? (left ? 0.035 : -0.035) :
                    (emotion == .sad || emotion == .worried ? (left ? -0.04 : 0.04) : 0)
                let y: CGFloat = emotion == .surprised ? 0.24 : 0.31
                brow.move(to: point(x - 0.085, y - tilt)); brow.addLine(to: point(x + 0.085, y + tilt))
                context.stroke(brow, with: .color(ink), style: line)
                if emotion == .calm {
                    var eye = Path(); eye.move(to: point(x - 0.055, 0.44))
                    eye.addQuadCurve(to: point(x + 0.055, 0.44), control: point(x, 0.49))
                    context.stroke(eye, with: .color(ink), style: line)
                } else {
                    let height: CGFloat = emotion == .surprised ? 0.15 : 0.10
                    context.fill(oval(x - 0.037, 0.39, 0.074, height), with: .color(ink))
                    context.fill(oval(x - 0.018, 0.40, 0.024, 0.03), with: .color(.white))
                }
            }
            var mouth = Path()
            switch emotion {
            case .happy:
                mouth.move(to: point(0.30, 0.64)); mouth.addLine(to: point(0.70, 0.64))
                mouth.addQuadCurve(to: point(0.30, 0.64), control: point(0.50, 1.02)); mouth.closeSubpath()
                context.fill(mouth, with: .color(ink))
                var teeth = Path(); teeth.move(to: point(0.34, 0.67)); teeth.addLine(to: point(0.66, 0.67))
                context.stroke(teeth, with: .color(.white), style: StrokeStyle(lineWidth: scale * 0.025, lineCap: .round))
            case .calm:
                mouth.move(to: point(0.39, 0.67)); mouth.addQuadCurve(to: point(0.61, 0.67), control: point(0.5, 0.77))
                context.stroke(mouth, with: .color(ink), style: line)
            case .surprised:
                context.fill(oval(0.42, 0.64, 0.16, 0.21), with: .color(ink))
            case .worried:
                mouth.move(to: point(0.37, 0.70)); mouth.addLine(to: point(0.43, 0.68))
                mouth.addLine(to: point(0.50, 0.71)); mouth.addLine(to: point(0.57, 0.68)); mouth.addLine(to: point(0.63, 0.70))
                context.stroke(mouth, with: .color(ink), style: line)
            case .sad, .mad:
                let edge: CGFloat = emotion == .sad ? 0.31 : 0.38
                mouth.move(to: point(edge, 0.75))
                mouth.addQuadCurve(to: point(1 - edge, 0.75), control: point(0.5, emotion == .sad ? 0.51 : 0.62))
                context.stroke(mouth, with: .color(ink), style: line)
            }
        }.frame(width: size, height: size)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Pretend face")
            .accessibilityValue(emotion.clue)
    }
}

struct FunnyFaceStudioGame: View {
    let onReplay: () -> Void
    @AppStorage("feelings.studio.lastFirst") private var lastFirst = ""
    @AppStorage("feelings.studio.lastShown") private var lastShown = ""
    @State private var play = StudioPlay()
    @State private var started = false
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Funny Face Studio", prompt: play.prompt, accent: .pink,
                            completion: play.complete, onReplay: onReplay) {
            if !play.complete {
                let emotion = play.current.emotion
                Text("Face \(play.index + 1) of \(play.rounds.count)")
                    .font(.headline).accessibilityIdentifier("studio.progress")
                StudioFace(emotion: emotion).accessibilityIdentifier("studio.target.\(emotion.rawValue)")
                switch play.phase {
                case .copy:
                    Text("Look • Copy • Name").font(.title2.bold())
                    Text("Make a face like the puppet with your grown-up.")
                        .multilineTextAlignment(.center)
                    ToddlerActionButton(title: "I tried the face!", systemImage: "face.smiling", color: .pink) {
                        play.copied(emotion)
                    }.accessibilityIdentifier("studio.copied")
                    Button("I watched with my grown-up") { play.copied(emotion) }
                        .font(.headline).frame(minHeight: 48).accessibilityIdentifier("studio.watched")
                case .identify:
                    Text("Find the feeling").font(.title2.bold())
                    HStack(alignment: .top, spacing: 10) {
                        ForEach(play.current.choices) { choice in
                            VStack(spacing: 6) {
                                Button { play.choose(choice, for: emotion) } label: {
                                    VStack(spacing: 10) {
                                        StudioFace(emotion: choice, size: 64).accessibilityHidden(true)
                                        Text(choice.name).font(.system(.headline, design: .rounded))
                                            .minimumScaleFactor(0.75).lineLimit(1)
                                    }.padding(.vertical, 12).frame(maxWidth: .infinity)
                                        .background(.white, in: RoundedRectangle(cornerRadius: 20))
                                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.pink.opacity(0.25), lineWidth: 2))
                                }.buttonStyle(.plain).accessibilityLabel(choice.name)
                                    .accessibilityIdentifier("studio.choice.\(choice.rawValue)")
                                Button { narrator.speak(choice.wordPrompt) } label: {
                                    Image(systemName: "speaker.wave.2.fill").font(.title3)
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                }.accessibilityLabel("Hear \(choice.name)")
                                    .accessibilityIdentifier("studio.hear.\(choice.rawValue)")
                            }.frame(maxWidth: .infinity)
                        }
                    }
                    if play.needsHelp {
                        Text("Let's look and try together.").font(.headline)
                            .accessibilityIdentifier("studio.retry")
                    }
                case .found:
                    Label(emotion.name, systemImage: "checkmark.seal.fill")
                        .font(.largeTitle.bold()).accessibilityIdentifier("studio.found")
                    ToddlerActionButton(title: play.index == play.rounds.count - 1 ? "Finish playing" : "Try another face", systemImage: "arrow.right", color: .pink) {
                        play.advance(from: emotion)
                        if !play.complete { lastShown = play.current.emotion.rawValue }
                    }.accessibilityIdentifier("studio.next")
                }
            }
        }.onAppear {
            guard !started else { return }
            play = StudioPlay(previousFirst: lastFirst, previousLast: lastShown)
            lastFirst = play.current.emotion.rawValue; lastShown = lastFirst; started = true
        }.onDisappear { narrator.stop() }
    }
}
