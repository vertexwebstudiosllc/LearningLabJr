import SwiftUI

struct MosaicPiece: Identifiable {
    let id: Int
    let name: String
    let shape: TownShape
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    var upsideDown = false
    var glyph: TownGlyph { TownGlyph(kind: shape, upsideDown: upsideDown) }
    func frame(boardWidth: CGFloat) -> CGRect {
        let scale = min(boardWidth / 320, 1)
        return CGRect(x: (boardWidth - 320 * scale) / 2 + (x - width / 2) * scale,
                      y: (y - height / 2) * scale, width: width * scale, height: height * scale)
    }
}

struct MosaicPicture: Identifiable {
    let id: String
    let name: String
    let pieces: [MosaicPiece]
    var prompt: String { "Let's paint the \(name.lowercased())! Choose a color, then tap a part of the picture. You can use any colors you like." }
    static let completion = "Twelve colorful pictures! You made a wonderful garden of art!"
    static let paints = ["red", "yellow", "blue", "orange", "green", "purple", "pink", "brown"].map { LabPaint.named($0) }
    static let bank: [Self] = [
        .init(id: "flower", name: "Flower", pieces: (0..<6).map { index in
            let angle = Double(index) * .pi / 3 - .pi / 2
            return MosaicPiece(id: index, name: "Petal \(index + 1)", shape: .circle,
                               x: 160 + cos(angle) * 80, y: 132 + sin(angle) * 80, width: 74, height: 74)
        }),
        .init(id: "butterfly", name: "Butterfly", pieces: [
            .init(id: 0, name: "Upper left wing", shape: .oval, x: 101, y: 88, width: 108, height: 110),
            .init(id: 1, name: "Upper right wing", shape: .oval, x: 219, y: 88, width: 108, height: 110),
            .init(id: 2, name: "Lower left wing", shape: .oval, x: 111, y: 188, width: 88, height: 88),
            .init(id: 3, name: "Lower right wing", shape: .oval, x: 209, y: 188, width: 88, height: 88),
        ]),
        .init(id: "house", name: "House", pieces: [
            .init(id: 0, name: "Wall", shape: .rectangle, x: 160, y: 167, width: 194, height: 146),
            .init(id: 1, name: "Roof", shape: .triangle, x: 160, y: 58, width: 230, height: 76),
            .init(id: 2, name: "Door", shape: .rectangle, x: 163, y: 204, width: 52, height: 72),
            .init(id: 3, name: "Left window", shape: .square, x: 105, y: 135, width: 52, height: 52),
            .init(id: 4, name: "Right window", shape: .square, x: 217, y: 135, width: 52, height: 52),
        ]),
        .init(id: "fish", name: "Fish", pieces: [
            .init(id: 0, name: "Tail", shape: .triangle, x:  60, y: 140, width: 84, height: 110),
            .init(id: 1, name: "Top fin", shape: .triangle, x: 173, y: 76, width: 88, height: 82),
            .init(id: 2, name: "Body", shape: .oval, x: 181, y: 145, width: 195, height: 125),
            .init(id: 3, name: "Side fin", shape: .triangle, x: 162, y: 165, width:  60, height:  60, upsideDown: true),
        ]),
        .init(id: "tree", name: "Tree", pieces: [
            .init(id: 0, name: "Trunk", shape: .rectangle, x: 160, y: 199, width:  60, height: 92),
            .init(id: 1, name: "Leaves", shape: .oval, x: 160, y: 100, width: 220, height: 154),
            .init(id: 2, name: "Left apple", shape: .circle, x: 107, y: 104, width: 54, height: 54),
            .init(id: 3, name: "Right apple", shape: .circle, x: 213, y: 104, width: 54, height: 54),
        ]),
        .init(id: "rocket", name: "Rocket", pieces: [
            .init(id: 0, name: "Left fin", shape: .triangle, x: 92, y: 205, width: 76, height: 78),
            .init(id: 1, name: "Right fin", shape: .triangle, x: 228, y: 205, width: 76, height: 78),
            .init(id: 2, name: "Body", shape: .rectangle, x: 160, y: 155, width: 88, height: 126),
            .init(id: 3, name: "Nose", shape: .triangle, x: 160, y: 56, width: 108, height: 72),
            .init(id: 4, name: "Window", shape: .circle, x: 160, y: 137, width: 56, height: 56),
        ]),
        .init(id: "sailboat", name: "Sailboat", pieces: [
            .init(id: 0, name: "Left sail", shape: .triangle, x: 95, y: 107, width: 112, height: 154),
            .init(id: 1, name: "Right sail", shape: .triangle, x: 223, y: 125, width: 112, height: 118),
            .init(id: 2, name: "Hull", shape: .rectangle, x: 160, y: 219, width: 238, height: 58),
        ]),
        .init(id: "snail", name: "Snail", pieces: [
            .init(id: 0, name: "Body", shape: .oval, x: 164, y: 207, width: 250, height: 70),
            .init(id: 1, name: "Shell", shape: .circle, x: 128, y: 122, width: 158, height: 158),
            .init(id: 2, name: "Shell center", shape: .circle, x: 128, y: 122, width: 72, height: 72),
            .init(id: 3, name: "Head", shape: .oval, x: 251, y: 161, width: 66, height: 100),
        ]),
        .init(id: "mushroom", name: "Mushroom", pieces: [
            .init(id: 0, name: "Stem", shape: .rectangle, x: 160, y: 194, width: 80, height: 102),
            .init(id: 1, name: "Cap", shape: .oval, x: 160, y: 103, width: 260, height: 150),
            .init(id: 2, name: "Left spot", shape: .circle, x:  90, y: 108, width: 56, height: 56),
            .init(id: 3, name: "Middle spot", shape: .circle, x: 160, y: 81, width: 56, height: 56),
            .init(id: 4, name: "Right spot", shape: .circle, x: 230, y: 108, width: 56, height: 56),
        ]),
        .init(id: "ice-cream", name: "Ice cream", pieces: [
            .init(id: 0, name: "Cone", shape: .triangle, x: 160, y: 199, width: 114, height: 102, upsideDown: true),
            .init(id: 1, name: "Left scoop", shape: .circle, x: 113, y: 119, width: 102, height: 102),
            .init(id: 2, name: "Right scoop", shape: .circle, x: 207, y: 119, width: 102, height: 102),
            .init(id: 3, name: "Top scoop", shape: .circle, x: 160, y: 62, width: 86, height: 86),
        ]),
        .init(id: "turtle", name: "Turtle", pieces: [
            .init(id: 0, name: "Left foot", shape: .oval, x:  90, y: 199, width: 64, height: 70),
            .init(id: 1, name: "Right foot", shape: .oval, x: 190, y: 199, width: 64, height: 70),
            .init(id: 2, name: "Head", shape: .oval, x: 261, y: 134, width: 64, height: 74),
            .init(id: 3, name: "Shell", shape: .oval, x: 140, y: 133, width: 196, height: 138),
            .init(id: 4, name: "Shell pattern", shape: .diamond, x: 140, y: 133, width:  80, height: 84),
        ]),
        .init(id: "balloon", name: "Balloon", pieces: [
            .init(id: 0, name: "Balloon", shape: .oval, x: 160, y: 103, width: 198, height: 168),
            .init(id: 1, name: "Middle stripe", shape: .oval, x: 160, y: 103, width: 82, height: 168),
            .init(id: 2, name: "Basket", shape: .rectangle, x: 160, y: 231, width: 86, height: 54),
        ]),
    ]
}

struct MosaicSession {
    let pictures = [MosaicPicture.bank[0]] + MosaicPicture.bank.dropFirst().shuffled()
    private(set) var index = 0
    private(set) var fills: [Int: String] = [:]
    var current: MosaicPicture { pictures[min(index, pictures.count - 1)] }
    var finished: Bool { index == pictures.count }
    var ready: Bool { current.pieces.allSatisfy { fills[$0.id] != nil } }
    @discardableResult mutating func fill(_ id: Int, paint: String) -> Bool {
        guard !finished, current.pieces.contains(where: { $0.id == id }), MosaicPicture.paints.contains(where: { $0.id == paint }) else { return false }
        fills[id] = paint
        return true
    }
    mutating func next() {
        guard !finished, ready else { return }
        index += 1
        if !finished { fills = [:] }
    }
}

struct MosaicGardenGame: View {
    let onReplay: () -> Void
    @State private var session = MosaicSession()
    @State private var paint = MosaicPicture.paints[0]
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Mosaic Garden", prompt: session.finished ? MosaicPicture.completion : session.current.prompt, accent: .pink, completion: session.finished, onReplay: onReplay) {
            Text("Picture \(min(session.index + 1, session.pictures.count)) of \(session.pictures.count) · \(session.current.name)")
                .font(.system(.headline, design: .rounded)).accessibilityIdentifier("shapes.mosaic.name")
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 24).fill(.white)
                    decoration.accessibilityHidden(true).allowsHitTesting(false)
                        .frame(width: 320, height: 270)
                        .scaleEffect(min(geometry.size.width / 320, 1), anchor: .top)
                        .offset(x: (geometry.size.width - 320) / 2)
                    ForEach(session.current.pieces) { piece in
                        let frame = piece.frame(boardWidth: geometry.size.width)
                        let fill = session.fills[piece.id]
                        Button { session.fill(piece.id, paint: paint.id) } label: {
                            piece.glyph.fill(fill.map { LabPaint.named($0).color } ?? Color(white: 0.96))
                                .overlay(piece.glyph.stroke(.indigo.opacity(0.5), lineWidth: 2.5))
                                .overlay {
                                    if fill == nil { Image(systemName: "paintbrush.pointed.fill").font(.system(size: 18)).foregroundStyle(.indigo.opacity(0.45)) }
                                }
                                .contentShape(piece.glyph)
                        }.buttonStyle(.plain)
                            .frame(width: frame.width, height: frame.height)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(piece.name), \(fill?.capitalized ?? "unpainted")")
                            .accessibilityIdentifier("shapes.mosaic.part.\(piece.id)")
                            .accessibilityAddTraits(.isButton)
                            .accessibilityAction { session.fill(piece.id, paint: paint.id) }
                            .offset(x: frame.minX, y: frame.minY)
                            .disabled(session.finished)
                    }
                    details.accessibilityHidden(true).allowsHitTesting(false)
                        .frame(width: 320, height: 270)
                        .scaleEffect(min(geometry.size.width / 320, 1), anchor: .top)
                        .offset(x: (geometry.size.width - 320) / 2)
                }
            }.frame(height: 270)
            Text("\(session.fills.count) of \(session.current.pieces.count) parts painted")
                .font(.subheadline).accessibilityIdentifier("shapes.mosaic.progress")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(MosaicPicture.paints) { option in
                    Button {
                        paint = option
                        narrator.speak(option.selectionPrompt)
                    } label: {
                        VStack(spacing: 4) {
                            Circle().fill(option.color).frame(width: 44, height: 44)
                                .overlay { if paint.id == option.id { Image(systemName: "checkmark").bold().foregroundStyle(option.ink) } }
                            Text(option.name).font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(.primary)
                        }.frame(maxWidth: .infinity, minHeight: 70)
                            .background(paint.id == option.id ? Color.pink.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 14))
                    }.buttonStyle(.plain)
                        .accessibilityLabel(option.name + " paint")
                        .accessibilityAddTraits(paint.id == option.id ? .isSelected : [])
                        .accessibilityIdentifier("shapes.mosaic.paint.\(option.id)")
                        .disabled(session.finished)
                }
            }
            if session.ready && !session.finished {
                ToddlerActionButton(title: session.index == session.pictures.count - 1 ? "My art is ready" : "Paint another picture", systemImage: "checkmark", color: .pink) { session.next() }
                    .accessibilityIdentifier("shapes.mosaic.next")
            }
            SCNote(text: "Every color choice is welcome. Tap a painted part to change its color before moving on.")
        }
    }
    private var decoration: some View {
        Path { path in
            if session.current.id == "balloon" {
                path.move(to: CGPoint(x: 120, y: 163)); path.addLine(to: CGPoint(x: 130, y: 218))
                path.move(to: CGPoint(x: 200, y: 163)); path.addLine(to: CGPoint(x: 190, y: 218))
            }
            if session.current.id == "sailboat" {
                path.move(to: CGPoint(x: 160, y: 25)); path.addLine(to: CGPoint(x: 160, y: 231))
            }
        }.stroke(.brown, lineWidth: 5)
    }
    @ViewBuilder private var details: some View {
        ZStack(alignment: .topLeading) {
            if session.current.id == "flower" {
                Image(systemName: "face.smiling.fill").font(.system(size: 63)).foregroundStyle(.yellow)
                    .position(x: 160, y: 132)
            }
            if session.current.id == "butterfly" {
                Capsule().fill(.indigo).frame(width: 20, height: 168).position(x: 160, y: 132)
                Circle().fill(.indigo).frame(width: 28, height: 28).position(x: 160, y: 45)
            }
            if ["fish", "snail", "turtle"].contains(session.current.id) {
                Circle().fill(.black).frame(width: 10, height: 10)
                    .position(x: session.current.id == "fish" ? 242 : 264, y: session.current.id == "snail" ? 134 : 117)
            }
        }
    }
}
