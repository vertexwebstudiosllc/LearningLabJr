import SwiftUI

private struct GentleFlower: View {
    let open: Bool
    var color: Color = .pink
    var size: CGFloat = 160
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { petal in
                Ellipse().fill(color.opacity(0.75))
                    .frame(width: size * (open ? 0.28 : 0.19), height: size * (open ? 0.43 : 0.30))
                    .offset(y: -size * (open ? 0.27 : 0.16))
                    .rotationEffect(.degrees(Double(petal) * 45))
            }
            Circle().fill(.yellow).frame(width: size * 0.3, height: size * 0.3)
        }.frame(width: size, height: size)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.6), value: open)
            .accessibilityHidden(true)
    }
}

struct FlowerBreathsGame: View {
    let onReplay: () -> Void
    @State private var play = GentlePlay()
    var body: some View {
        ToddlerGameScaffold(title: "Flower Breaths", prompt: play.prompt, accent: .teal,
                            completion: play.complete, onReplay: onReplay) {
            if !play.complete {
                let level = play.current
                let step = play.step
                Text("Activity \(play.index + 1) of \(GentleLevel.bank.count)")
                    .font(.headline).accessibilityIdentifier("gentle.progress")
                Text(level.title).font(.title2.bold()).accessibilityIdentifier("gentle.level.\(level.id)")
                activity(level, step: step)
                if play.finishedLevel {
                    Label("A gentle moment together", systemImage: "heart.fill")
                        .font(.headline).foregroundStyle(.teal).accessibilityIdentifier("gentle.finished")
                    ToddlerActionButton(title: play.index == GentleLevel.bank.count - 1 ? "Finish together" : "Explore another activity", systemImage: "arrow.right", color: .teal) {
                        play.advance(level.id)
                    }.accessibilityIdentifier("gentle.next")
                } else {
                    Button("Watch with my grown-up") { play.watch(level.id) }
                        .font(.headline).frame(minHeight: 48).accessibilityIdentifier("gentle.watch")
                    Text("Take your time. You can join in, watch, or stop whenever you like.")
                        .font(.subheadline).multilineTextAlignment(.center)
                }
            } else {
                HStack(spacing: 10) {
                    GentleFlower(open: true, size: 85)
                    Image(systemName: "heart.fill").font(.system(size: 50)).foregroundStyle(.teal)
                    GentleFlower(open: true, color: .purple, size: 85)
                }.accessibilityLabel("Flowers and a heart")
            }
        }
    }

    @ViewBuilder private func activity(_ level: GentleLevel, step: Int) -> some View {
        switch level.kind {
        case .flower:
            GentleFlower(open: step.isMultiple(of: 2) == false && !play.finishedLevel, size: 210)
                .accessibilityHidden(false).accessibilityLabel(step.isMultiple(of: 2) ? "Flower resting" : "Flower opening")
            if !play.finishedLevel {
                ToddlerActionButton(title: step.isMultiple(of: 2) ? "Smell the flower" : "Soft breeze out",
                                    systemImage: step.isMultiple(of: 2) ? "camera.macro" : "wind", color: .teal) {
                    play.act(step, in: level.id, at: step)
                }.accessibilityIdentifier("gentle.act")
                Text("Tap when you are ready. Keep breathing comfortably.")
                    .font(.subheadline).multilineTextAlignment(.center)
            }
        case .feather, .turtle:
            steppingScene(level, step: step)
        case .flowers:
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { bud in
                    Button { play.act(bud, in: level.id, at: step) } label: {
                        VStack(spacing: 12) {
                            GentleFlower(open: play.finishedLevel || play.touched.contains(bud), color: [.pink, .purple, .orange][bud], size: 85)
                            Image(systemName: play.touched.contains(bud) ? "heart.fill" : "hand.point.up.left.fill")
                                .foregroundStyle(.teal)
                        }.frame(maxWidth: .infinity, minHeight: 150)
                            .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 22))
                    }.buttonStyle(.plain).disabled(play.touched.contains(bud) || play.finishedLevel)
                        .accessibilityLabel(play.touched.contains(bud) ? "Flower \(bud + 1) opened" : "Open flower \(bud + 1)")
                        .accessibilityIdentifier("gentle.spot.\(bud)")
                }
            }
        case .teddy:
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 28).fill(.purple.opacity(0.08))
                Image(systemName: "teddybear.fill").resizable().scaledToFit().foregroundStyle(.brown)
                    .frame(width: 150, height: 185).padding(.bottom, 12)
                if play.finishedLevel { blanket.frame(width: 180, height: 85).padding(.bottom, 5) }
            }.frame(height: 220).accessibilityLabel(play.finishedLevel ? "Teddy tucked in" : "Teddy's cozy spot")
                .accessibilityIdentifier("gentle.teddy")
                .dropDestination(for: String.self) { items, _ in
                    play.dropBlanket(items, in: level.id, at: step)
                }
            if !play.finishedLevel {
                blanket.frame(width: 125, height: 65).draggable("gentle.teddy.blanket")
                    .accessibilityLabel("Blanket").accessibilityIdentifier("gentle.blanket")
                ToddlerActionButton(title: "Tuck Teddy in", systemImage: "heart.fill", color: .teal) {
                    play.act(step, in: level.id, at: step)
                }.accessibilityIdentifier("gentle.act")
            }
        case .pond:
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { pad in
                    Button { play.act(pad, in: level.id, at: step) } label: {
                        ZStack {
                            ForEach(1..<4, id: \.self) { ring in
                                Circle().stroke(.teal.opacity(play.touched.contains(pad) ? 0.5 : 0.08), lineWidth: 2)
                                    .frame(width: CGFloat(32 + ring * 18), height: CGFloat(32 + ring * 18))
                            }
                            Image(systemName: "leaf.fill").font(.system(size: 35)).foregroundStyle(.green)
                                .rotationEffect(.degrees(Double(pad * 35)))
                        }.frame(maxWidth: .infinity, minHeight: 170)
                    }.buttonStyle(.plain).disabled(play.touched.contains(pad) || play.finishedLevel)
                        .accessibilityLabel(play.touched.contains(pad) ? "Circles around lily pad \(pad + 1)" : "Tap lily pad \(pad + 1)")
                        .accessibilityIdentifier("gentle.spot.\(pad)")
                }
            }.padding(.horizontal, 8).background(.cyan.opacity(0.09), in: RoundedRectangle(cornerRadius: 28))
        case .listening:
            ZStack {
                RoundedRectangle(cornerRadius: 28).fill(.green.opacity(0.08))
                HStack(spacing: 25) {
                    Image(systemName: "leaf.fill").foregroundStyle(.green)
                    Image(systemName: "ear.fill").foregroundStyle(.teal)
                    Image(systemName: "leaf.fill").foregroundStyle(.orange)
                }.font(.system(size: 55))
            }.frame(height: 180).accessibilityLabel("Leaves and an ear for looking and listening")
            if !play.finishedLevel {
                ToddlerActionButton(title: step == 0 ? "Let's notice together" : "Ready to continue", systemImage: "ear.fill", color: .teal) {
                    play.act(step, in: level.id, at: step)
                }.accessibilityIdentifier("gentle.act")
            }
        case .kindwords:
            Image(systemName: "bubble.left.and.bubble.right.fill").font(.system(size: 90)).foregroundStyle(.teal)
                .frame(height: 115).accessibilityHidden(true)
            if !play.finishedLevel {
                ForEach(GentleWords.bank) { choice in
                    ToddlerActionButton(title: choice.title, systemImage: "heart.fill", color: .teal) {
                        play.chooseWord(choice.id)
                    }.accessibilityIdentifier("gentle.word.\(choice.id)")
                }
            } else if let word = play.word {
                Text(word.title).font(.title2.bold()).multilineTextAlignment(.center)
            }
        }
    }
    private var blanket: some View {
        RoundedRectangle(cornerRadius: 16).fill(.pink.opacity(0.75))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white, style: StrokeStyle(lineWidth: 3, dash: [6, 4])).padding(6))
            .overlay(Image(systemName: "heart.fill").foregroundStyle(.white).font(.title2))
    }
    private func steppingScene(_ level: GentleLevel, step: Int) -> some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { spot in
                VStack(spacing: 14) {
                    Group {
                        if level.kind == .turtle {
                            Image(systemName: "tortoise.fill").font(.system(size: 55)).foregroundStyle(.green)
                        } else {
                            GentleFeather().frame(width: 55, height: 70).rotationEffect(.degrees(-25))
                        }
                    }.frame(height: 70).opacity(spot == min(step, 2) ? 1 : 0)
                        .accessibilityHidden(true)
                    Button { play.act(spot, in: level.id, at: step) } label: {
                        Image(systemName: level.kind == .turtle ? "oval.fill" : "cloud.fill")
                            .font(.system(size: 50)).foregroundStyle(spot == step ? .teal : .teal.opacity(0.2))
                            .frame(maxWidth: .infinity, minHeight: 75)
                            .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(spot == step ? .teal : .clear, lineWidth: 3))
                    }.buttonStyle(.plain).disabled(spot != step || play.finishedLevel)
                        .accessibilityLabel("\(level.kind == .turtle ? "Stepping stone" : "Cloud") \(spot + 1)")
                        .accessibilityIdentifier("gentle.spot.\(spot)")
                }.frame(maxWidth: .infinity)
            }
        }.padding(12).background(.teal.opacity(0.06), in: RoundedRectangle(cornerRadius: 28))
    }
}

private struct GentleFeather: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width, h = size.height
            let blade = Path(ellipseIn: CGRect(x: w * 0.15, y: 0, width: w * 0.7, height: h * 0.85))
            context.fill(blade, with: .color(.orange.opacity(0.6)))
            var ribs = Path()
            ribs.move(to: CGPoint(x: w * 0.5, y: h)); ribs.addLine(to: CGPoint(x: w * 0.5, y: h * 0.06))
            for row in 1...5 {
                let y = h * (0.12 + CGFloat(row) * 0.12)
                let spread = row == 1 || row == 5 ? w * 0.2 : w * 0.3
                ribs.move(to: CGPoint(x: w * 0.5 - spread, y: y - h * 0.09))
                ribs.addLine(to: CGPoint(x: w * 0.5, y: y))
                ribs.addLine(to: CGPoint(x: w * 0.5 + spread, y: y - h * 0.09))
            }
            context.stroke(ribs, with: .color(.brown), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
    }
}
