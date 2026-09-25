import SwiftUI

/// Vector pieces keep every construction crisp at both card and scene sizes.
struct CozyGlyph: Shape {
    let kind: String
    func path(in rect: CGRect) -> Path {
        var p = Path()
        func box(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
            CGRect(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height,
                   width: w * rect.width, height: h * rect.height)
        }
        switch kind {
        case "circle", "oval": p.addEllipse(in: rect)
        case "ring":
            p.addEllipse(in: rect); p.addEllipse(in: box(0.12, 0.18, 0.76, 0.6))
        case "triangle": return TownGlyph(kind: .triangle).path(in: rect)
        case "eggs":
            for i in 0..<3 { p.addEllipse(in: box(CGFloat(i) * 0.35, 0, 0.3, 1)) }
        case "stripes":
            for i in 0..<3 { p.addRoundedRect(in: box(0, CGFloat(i) * 0.4, 1, 0.18), cornerSize: CGSize(width: 5, height: 5)) }
        case "supports":
            for x: CGFloat in [0, 0.8] { p.addRect(box(x, 0, 0.2, 1)) }
        case "posts", "stems":
            for x: CGFloat in [0.05, 0.46, 0.87] { p.addRect(box(x, 0, 0.08, 1)) }
        case "benches":
            p.addRect(box(0, 0, 0.27, 1)); p.addRect(box(0.73, 0, 0.27, 1))
        case "flowers":
            for x: CGFloat in [0, 0.4, 0.8] { p.addEllipse(in: box(x, 0, 0.2, 1)) }
        case "tubes":
            for y: CGFloat in [0, 0.55] {
                for x: CGFloat in [0, 0.36, 0.72] {
                    p.addEllipse(in: box(x, y, 0.26, 0.43))
                    p.addEllipse(in: box(x + 0.065, y + 0.1, 0.13, 0.23))
                }
            }
        case "bone":
            p.move(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.3))
            p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.75, y: rect.minY + rect.height * 0.3))
            p.addCurve(to: CGPoint(x: rect.minX + rect.width * 0.75, y: rect.minY + rect.height * 0.7), control1: CGPoint(x: rect.maxX + rect.width * 0.15, y: rect.minY - rect.height * 0.7), control2: CGPoint(x: rect.maxX + rect.width * 0.15, y: rect.maxY + rect.height * 0.7))
            p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.7))
            p.addCurve(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.3), control1: CGPoint(x: rect.minX - rect.width * 0.15, y: rect.maxY + rect.height * 0.7), control2: CGPoint(x: rect.minX - rect.width * 0.15, y: rect.minY - rect.height * 0.7))
            p.closeSubpath()
        case "arch":
            p.addRoundedRect(in: rect, cornerSize: CGSize(width: rect.width / 2, height: rect.width / 2))
        case "star":
            for i in 0..<10 {
                let angle = Double(i) * .pi / 5 - .pi / 2
                let radius: CGFloat = i.isMultiple(of: 2) ? 0.5 : 0.22
                let point = CGPoint(x: rect.midX + CGFloat(cos(angle)) * rect.width * radius,
                                    y: rect.midY + CGFloat(sin(angle)) * rect.height * radius)
                if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
            }
            p.closeSubpath()
        case "hull":
            p.move(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.2, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.maxY)); p.closeSubpath()
        default: p.addRoundedRect(in: rect, cornerSize: CGSize(width: 5, height: 5))
        }
        return p
    }
}

struct CozyNestGame: View {
    @AppStorage("nature.cozy.lastSecond") private var lastSecond = ""
    @State private var play = CozyPlay()
    @State private var started = false
    var body: some View {
        ToddlerGameScaffold(title: "A Cozy Nest", prompt: play.prompt, accent: .brown,
                            completion: play.complete, onReplay: restart) {
            if !play.complete {
                let project = play.current
                let step = play.placed
                Text("Project \(play.index + 1) of \(play.projects.count)")
                    .font(.headline).accessibilityIdentifier("cozy.progress")
                Text(project.name.capitalized).font(.title2.bold())
                    .accessibilityIdentifier("cozy.project.\(project.id)")
                scene(project).accessibilityLabel("\(project.name), \(step) of \(project.pieces.count) pieces built")
                if play.built {
                    Label("We built it!", systemImage: "checkmark.seal.fill").font(.title2.bold())
                        .accessibilityIdentifier("cozy.built")
                    ToddlerActionButton(title: play.index == play.projects.count - 1 ? "Finish building" : "Build something new", systemImage: "arrow.right", color: .brown) {
                        play.advance(from: project.id)
                    }.accessibilityIdentifier("cozy.next")
                } else {
                    Text("Step \(step + 1) of \(project.pieces.count) · Choose \(project.pieces[step].name.lowercased())")
                        .font(.headline).multilineTextAlignment(.center).accessibilityIdentifier("cozy.step")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(project.pieces.filter { $0.id >= step }) { piece in
                            Button {
                                play.choose(piece.id, project: project.id, step: step)
                            } label: {
                                VStack(spacing: 8) {
                                    CozyGlyph(kind: piece.kind).fill(piece.color, style: FillStyle(eoFill: true))
                                        .overlay(CozyGlyph(kind: piece.kind).stroke(.brown.opacity(0.4), lineWidth: 1))
                                        .aspectRatio(piece.width / piece.height, contentMode: .fit)
                                        .frame(width: 100, height: 55)
                                    Text(piece.name).font(.headline).multilineTextAlignment(.center)
                                }.padding(12).frame(maxWidth: .infinity, minHeight: 112)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 20))
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.brown.opacity(0.25), lineWidth: 2))
                            }.buttonStyle(.plain).accessibilityLabel(piece.name)
                                .accessibilityIdentifier("cozy.piece.\(piece.id)")
                        }
                    }
                    if play.needsHelp {
                        Text("Let's find the next piece together.").font(.headline)
                            .accessibilityIdentifier("cozy.retry")
                    }
                }
            }
        }.onAppear {
            if !started { restart(); started = true }
        }
    }
    private func restart() {
        play = CozyPlay(previousSecond: lastSecond)
        lastSecond = play.projects[1].id
    }
    private func scene(_ project: CozyProject) -> some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / 320, 1.3)
            ZStack {
                RoundedRectangle(cornerRadius: 26).fill(Color.green.opacity(0.08))
                ForEach(project.pieces) { piece in
                    CozyGlyph(kind: piece.kind)
                        .fill(piece.id < play.placed ? piece.color : piece.color.opacity(0.08), style: FillStyle(eoFill: true))
                        .overlay(CozyGlyph(kind: piece.kind).stroke(.brown.opacity(piece.id == play.placed ? 0.65 : 0.12), style: StrokeStyle(lineWidth: 2, dash: piece.id < play.placed ? [] : [5, 5])))
                        .frame(width: piece.width * scale, height: piece.height * scale)
                        .position(x: geometry.size.width / 2 + (piece.x - 160) * scale, y: piece.y * scale)
                }
            }
        }.frame(height: 285).accessibilityElement(children: .ignore)
    }
}
