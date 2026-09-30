import SwiftUI

/// Both faces share the same puppet; each feature changes independently.
struct StudioFace: View {
    let design: StudioFaceDesign
    var size: CGFloat = 220

    init(design: StudioFaceDesign, size: CGFloat = 220) {
        self.design = design; self.size = size
    }
    init(emotion: StudioEmotion, size: CGFloat = 220) {
        self.init(design: emotion.face, size: size)
    }

    var body: some View {
        Canvas { context, bounds in
            let scale = bounds.width
            func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * scale, y: y * scale) }
            func oval(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> Path {
                Path(ellipseIn: CGRect(x: x * scale, y: y * scale, width: w * scale, height: h * scale))
            }
            func star(at center: CGPoint, radius: CGFloat) -> Path {
                Path { path in
                    for corner in 0..<10 {
                        let angle = CGFloat(corner) * .pi / 5 - .pi / 2
                        let length = corner.isMultiple(of: 2) ? radius : radius * 0.54
                        let p = CGPoint(x: center.x + cos(angle) * length, y: center.y + sin(angle) * length)
                        if corner == 0 { path.move(to: p) } else { path.addLine(to: p) }
                    }
                    path.closeSubpath()
                }
            }
            let ink = Color(red: 0.28, green: 0.16, blue: 0.12)
            let line = StrokeStyle(lineWidth: max(2, scale * 0.024), lineCap: .round, lineJoin: .round)
            context.fill(oval(0.02, 0.12, 0.96, 0.86), with: .color(Color(red: 1, green: 0.82, blue: 0.53)))
            context.stroke(oval(0.02, 0.12, 0.96, 0.86), with: .color(.brown.opacity(0.22)), lineWidth: 2)
            for x: CGFloat in [0.17, 0.73] {
                context.fill(oval(x, 0.61, 0.10, 0.065), with: .color(.pink.opacity(0.25)))
            }
            for x: CGFloat in [0.32, 0.68] {
                var brow = Path()
                let left = x < 0.5
                let tilt: CGFloat = design.eyebrows == 2 ? (left ? 0.035 : -0.035) :
                    (design.eyebrows == 1 ? (left ? -0.04 : 0.04) : 0)
                let y: CGFloat = design.eyebrows == 3 ? 0.29 : 0.35
                brow.move(to: point(x - 0.085, y - tilt)); brow.addLine(to: point(x + 0.085, y + tilt))
                context.stroke(brow, with: .color(ink), style: line)
                if design.eyes == 3 {
                    var eye = Path(); eye.move(to: point(x - 0.055, 0.49))
                    eye.addQuadCurve(to: point(x + 0.055, 0.49), control: point(x, 0.54))
                    context.stroke(eye, with: .color(ink), style: line)
                } else if design.eyes == 2 {
                    context.fill(oval(x - 0.065, 0.43, 0.13, 0.11), with: .color(.white))
                    context.fill(oval(x + 0.005, 0.45, 0.05, 0.08), with: .color(ink))
                } else {
                    let height: CGFloat = design.eyes == 1 ? 0.15 : 0.10
                    context.fill(oval(x - 0.037, 0.44, 0.074, height), with: .color(ink))
                    context.fill(oval(x - 0.018, 0.45, 0.024, 0.03), with: .color(.white))
                }
            }
            var mouth = Path()
            switch design.mouth {
            case 0:
                mouth.move(to: point(0.30, 0.68)); mouth.addLine(to: point(0.70, 0.68))
                mouth.addQuadCurve(to: point(0.30, 0.68), control: point(0.50, 1.01)); mouth.closeSubpath()
                context.fill(mouth, with: .color(ink))
                var teeth = Path(); teeth.move(to: point(0.34, 0.71)); teeth.addLine(to: point(0.66, 0.71))
                context.stroke(teeth, with: .color(.white), style: StrokeStyle(lineWidth: scale * 0.025, lineCap: .round))
            case 5:
                mouth.move(to: point(0.39, 0.71)); mouth.addQuadCurve(to: point(0.61, 0.71), control: point(0.5, 0.82))
                context.stroke(mouth, with: .color(ink), style: line)
            case 4:
                context.fill(oval(0.42, 0.68, 0.16, 0.20), with: .color(ink))
            case 3:
                mouth.move(to: point(0.37, 0.75)); mouth.addLine(to: point(0.43, 0.72))
                mouth.addLine(to: point(0.50, 0.76)); mouth.addLine(to: point(0.57, 0.72)); mouth.addLine(to: point(0.63, 0.75))
                context.stroke(mouth, with: .color(ink), style: line)
            default:
                let edge: CGFloat = design.mouth == 1 ? 0.31 : 0.38
                mouth.move(to: point(edge, 0.79))
                mouth.addQuadCurve(to: point(1 - edge, 0.79), control: point(0.5, design.mouth == 1 ? 0.55 : 0.65))
                context.stroke(mouth, with: .color(ink), style: line)
            }
            if design.glasses > 0 {
                let color: Color = design.glasses == 1 ? .purple : .blue
                for x: CGFloat in [0.32, 0.68] {
                    let lens = design.glasses == 1 ? oval(x - 0.12, 0.385, 0.24, 0.23)
                        : star(at: point(x, 0.50), radius: scale * 0.145)
                    context.stroke(lens, with: .color(color), style: line)
                }
                var bridge = Path(); bridge.move(to: point(0.44, 0.48)); bridge.addQuadCurve(to: point(0.56, 0.48), control: point(0.5, 0.44))
                bridge.move(to: point(0.08, 0.44)); bridge.addLine(to: point(0.20, 0.48))
                bridge.move(to: point(0.80, 0.48)); bridge.addLine(to: point(0.92, 0.44))
                context.stroke(bridge, with: .color(color), style: line)
            }
            if design.hat == 1 {
                var hat = Path(); hat.move(to: point(0.5, 0.015)); hat.addLine(to: point(0.30, 0.25))
                hat.addLine(to: point(0.70, 0.25)); hat.closeSubpath()
                context.fill(hat, with: .color(.purple))
                for (x, y) in [(0.49, 0.10), (0.42, 0.18), (0.55, 0.20)] {
                    context.fill(oval(x, y, 0.04, 0.04), with: .color(.yellow))
                }
                context.fill(oval(0.46, 0.00, 0.08, 0.08), with: .color(.pink))
            } else if design.hat == 2 {
                let crown = Path(roundedRect: CGRect(x: scale * 0.32, y: scale * 0.03, width: scale * 0.36, height: scale * 0.20), cornerRadius: scale * 0.035)
                context.fill(crown, with: .color(.indigo))
                context.fill(Path(CGRect(x: scale * 0.32, y: scale * 0.17, width: scale * 0.36, height: scale * 0.045)), with: .color(.mint))
                context.fill(oval(0.22, 0.21, 0.56, 0.06), with: .color(.indigo))
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pretend face")
        .accessibilityValue(design.description)
    }
}

struct FunnyFaceStudioGame: View {
    let onReplay: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("feelings.studio.lastFirst") private var lastFirst = ""
    @AppStorage("feelings.studio.lastShown") private var lastShown = ""
    @State private var play = StudioPlay()
    @State private var started = false
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ToddlerGameScaffold(title: "Funny Face Studio", prompt: play.prompt, accent: .pink,
                            completion: play.complete, onReplay: onReplay,
                            scrollToTopOnPromptChange: false, autoNarratePrompt: false, allowUnrecordedPrompt: true) {
            if !play.complete {
                Text("Face \(play.index + 1) of \(play.rounds.count)")
                    .font(.headline).accessibilityIdentifier("studio.progress")
                faceBoard
                HStack(spacing: 6) {
                    ForEach(play.current.features) { feature in
                        Image(systemName: play.matchedFeatures.contains(feature) ? "star.fill" : "star")
                            .foregroundStyle(play.matchedFeatures.contains(feature) ? .orange : .secondary)
                    }
                    Text("\(play.matchedFeatures.count) of \(play.current.features.count) matched")
                }
                .font(.subheadline.bold())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(play.matchedFeatures.count) of \(play.current.features.count) parts matched")
                .accessibilityIdentifier("studio.matches")
                if play.phase == .found {
                    Label("You matched it!", systemImage: "checkmark.seal.fill")
                        .font(.title2.bold()).foregroundStyle(.green)
                        .accessibilityIdentifier("studio.found")
                    ToddlerActionButton(title: play.index == play.rounds.count - 1 ? "Finish playing" : "Try another face", systemImage: "arrow.right", color: .pink) {
                        play.advance(from: play.current.emotion)
                        if !play.complete { lastShown = play.current.emotion.rawValue }
                    }.accessibilityIdentifier("studio.next")
                } else {
                    Text("Tap a face part or a button to change it.")
                        .font(.subheadline).multilineTextAlignment(.center)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 94), spacing: 8)], spacing: 8) {
                        ForEach(play.current.features) { feature in featureButton(feature) }
                    }
                }
            }
        }
        .onAppear {
            guard !started else { return }
            play = StudioPlay(previousFirst: lastFirst, previousLast: lastShown)
            lastFirst = play.current.emotion.rawValue; lastShown = lastFirst; started = true
        }
        .task(id: "\(started):\(play.prompt)") {
            guard started else { return }
            narrator.speak(play.prompt, allowUnrecorded: !play.complete)
        }
        .sensoryFeedback(.success, trigger: play.phase == .found)
        .onDisappear { narrator.stop() }
    }

    private var faceBoard: some View {
        GeometryReader { geometry in
            let size = min(260, (geometry.size.width - 32) / 2)
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 6) {
                    Text("Match this").font(.headline)
                    Text("EXAMPLE").font(.caption2.bold()).foregroundStyle(.secondary)
                    StudioFace(design: play.current.target, size: size)
                        .accessibilityLabel("Example to match")
                        .accessibilityIdentifier("studio.target.\(play.current.emotion.rawValue)")
                }
                .padding(.vertical, 10).frame(maxWidth: .infinity)
                .background(.white, in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.purple.opacity(0.3), lineWidth: 2))
                VStack(spacing: 6) {
                    Text("Your face").font(.headline)
                    Text(play.phase == .found ? "MATCHED!" : "TAP TO CHANGE")
                        .font(.caption2.bold()).foregroundStyle(.pink)
                    StudioFace(design: play.face, size: size)
                        .accessibilityLabel("Your face")
                        .accessibilityIdentifier("studio.editable")
                        .overlay { faceHotspots(size: size) }
                }
                .padding(.vertical, 10).frame(maxWidth: .infinity)
                .background(.pink.opacity(0.07), in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.pink.opacity(0.5), lineWidth: 2))
            }
        }
        .aspectRatio(1.42, contentMode: .fit)
        .frame(maxHeight: 340)
    }

    private func faceHotspots(size: CGFloat) -> some View {
        ZStack {
            // The large labeled controls below provide an alternative to these face regions.
            hotspot(.eyebrows, x: 0.50, y: 0.33, width: 0.72, height: 0.18, size: size)
            hotspot(.eyes, x: 0.50, y: 0.51, width: 0.60, height: 0.18, size: size)
            hotspot(.mouth, x: 0.50, y: 0.77, width: 0.60, height: 0.27, size: size)
            if play.current.features.contains(.glasses) {
                hotspot(.glasses, x: 0.10, y: 0.49, width: 0.20, height: 0.27, size: size)
                hotspot(.glasses, x: 0.90, y: 0.49, width: 0.20, height: 0.27, size: size)
            }
            if play.current.features.contains(.hat) {
                hotspot(.hat, x: 0.50, y: 0.12, width: 0.60, height: 0.24, size: size)
            }
        }
        .frame(width: size, height: size)
        .disabled(play.phase == .found)
        .accessibilityHidden(true)
    }

    private func hotspot(_ feature: StudioFeature, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, size: CGFloat) -> some View {
        let expectedStyle = play.face[feature]
        let emotion = play.current.emotion
        return Button { change(feature, for: emotion, from: expectedStyle) } label: {
            Color.clear.contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(width: size * width, height: size * height)
        .position(x: size * x, y: size * y)
    }

    private func featureButton(_ feature: StudioFeature) -> some View {
        let expectedStyle = play.face[feature]
        let emotion = play.current.emotion
        let matched = play.matchedFeatures.contains(feature)
        return Button { change(feature, for: emotion, from: expectedStyle) } label: {
            VStack(spacing: 6) {
                Image(systemName: matched ? "checkmark.circle.fill" : feature.symbol)
                    .font(.title3).foregroundStyle(matched ? .green : .pink)
                Text(feature.name).font(.system(.subheadline, design: .rounded, weight: .bold))
            }
            .frame(maxWidth: .infinity, minHeight: 64)
            .padding(.horizontal, 4)
            .background(.white, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(matched ? .green.opacity(0.5) : .pink.opacity(0.25), lineWidth: 2))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Change \(feature.rawValue)")
        .accessibilityValue("\(feature.styles[expectedStyle]). \(matched ? "Matches example" : "Keep trying")")
        .accessibilityHint("Example: \(feature.styles[play.current.target[feature]]). Double tap to try the next style.")
        .accessibilityIdentifier("studio.feature.\(feature.rawValue)")
    }

    private func change(_ feature: StudioFeature, for emotion: StudioEmotion, from expectedStyle: Int) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.18)) {
            play.change(feature, for: emotion, from: expectedStyle)
        }
    }
}
