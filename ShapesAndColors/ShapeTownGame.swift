import SwiftUI

enum TownShape: String, CaseIterable {
    case square, rectangle, circle, oval, triangle, diamond
}

struct TownGlyph: Shape {
    let kind: TownShape
    var upsideDown = false
    func path(in rect: CGRect) -> Path {
        switch kind {
        case .square, .rectangle: return Path(rect)
        case .circle, .oval: return Path(ellipseIn: rect)
        case .triangle:
            return Path { path in
                path.move(to: CGPoint(x: rect.midX, y: upsideDown ? rect.maxY : rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: upsideDown ? rect.minY : rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: upsideDown ? rect.minY : rect.maxY))
                path.closeSubpath()
            }
        case .diamond:
            return Path { path in
                path.move(to: CGPoint(x: rect.midX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
                path.closeSubpath()
            }
        }
    }
}

struct TownPiece: Identifiable {
    let id: Int
    let shape: TownShape
    let paint: String
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    var upsideDown = false
    var color: Color { LabPaint.named(paint).color }
    var label: String { "\(paint.capitalized) \(shape.rawValue)" }
    var instruction: String { "Drag the \(paint) \(shape.rawValue) to its outline." }
    var success: String { "The \(shape.rawValue) fits!" }
    var glyph: TownGlyph { TownGlyph(kind: shape, upsideDown: upsideDown) }
    func matches(_ other: TownPiece) -> Bool {
        shape == other.shape && paint == other.paint && width == other.width && height == other.height && upsideDown == other.upsideDown
    }
    func dropFrame(boardWidth: CGFloat) -> CGRect {
        let frame = frame(boardWidth: boardWidth)
        let width = max(64, frame.width + 16)
        let height = max(64, frame.height + 16)
        return CGRect(x: frame.midX - width / 2, y: frame.midY - height / 2, width: width, height: height)
    }
    func frame(boardWidth: CGFloat) -> CGRect {
        let scale = min(boardWidth / 320, 1)
        let left = (boardWidth - 320 * scale) / 2
        return CGRect(x: left + (x - width / 2) * scale, y: (y - height / 2) * scale, width: width * scale, height: height * scale)
    }
}

struct TownPicture: Identifiable {
    let id: String
    let name: String
    let pieces: [TownPiece]
    var prompt: String { "Let's build the \(name)! Choose a shape below, then drag it to its outline." }
    var success: String { "You built the \(name)!" }
    static let retry = "Let's try again. Find an outline that matches your shape."
    static let completion = "Twenty shape pictures! Our town is ready!"
    static let bank: [TownPicture] = [
        .init(id: "house", name: "house", pieces: [
            .init(id: 0, shape: .square, paint: "orange", x: 160, y: 145, width: 110, height: 110),
            .init(id: 1, shape: .triangle, paint: "pink", x: 160, y: 62, width: 150, height: 75),
            .init(id: 2, shape: .circle, paint: "blue", x: 160, y: 128, width: 34, height: 34),
        ]),
        .init(id: "tree", name: "tree", pieces: [
            .init(id: 0, shape: .rectangle, paint: "brown", x: 160, y: 174, width: 32, height: 78),
            .init(id: 1, shape: .triangle, paint: "green", x: 160, y: 91, width: 150, height: 125),
            .init(id: 2, shape: .circle, paint: "red", x: 160, y: 110, width: 26, height: 26),
        ]),
        .init(id: "snowman", name: "snowman", pieces: [
            .init(id: 0, shape: .circle, paint: "white", x: 160, y: 170, width: 84, height: 84),
            .init(id: 1, shape: .circle, paint: "white", x: 160, y: 105, width: 64, height: 64),
            .init(id: 2, shape: .circle, paint: "white", x: 160, y: 55, width: 46, height: 46),
        ]),
        .init(id: "fish", name: "fish", pieces: [
            .init(id: 0, shape: .diamond, paint: "orange", x: 77, y: 113, width: 72, height: 72),
            .init(id: 1, shape: .oval, paint: "orange", x: 165, y: 113, width: 150, height: 82),
            .init(id: 2, shape: .circle, paint: "black", x: 211, y: 99, width: 16, height: 16),
        ]),
        .init(id: "ice-cream", name: "ice cream", pieces: [
            .init(id: 0, shape: .triangle, paint: "brown", x: 160, y: 153, width: 82, height: 110, upsideDown: true),
            .init(id: 1, shape: .circle, paint: "pink", x: 160, y: 78, width: 90, height: 90),
            .init(id: 2, shape: .circle, paint: "red", x: 160, y: 30, width: 20, height: 20),
        ]),
        .init(id: "mountains", name: "mountains", pieces: [
            .init(id: 0, shape: .triangle, paint: "purple", x: 110, y: 127, width: 145, height: 155),
            .init(id: 1, shape: .triangle, paint: "green", x: 218, y: 142, width: 125, height: 125),
            .init(id: 2, shape: .circle, paint: "yellow", x: 258, y: 40, width: 42, height: 42),
        ]),
        .init(id: "mushroom", name: "mushroom", pieces: [
            .init(id: 0, shape: .rectangle, paint: "brown", x: 160, y: 163, width: 40, height: 85),
            .init(id: 1, shape: .oval, paint: "red", x: 160, y: 96, width: 150, height: 80),
            .init(id: 2, shape: .circle, paint: "white", x: 131, y: 82, width: 25, height: 25),
        ]),
        .init(id: "tent", name: "tent", pieces: [
            .init(id: 0, shape: .triangle, paint: "orange", x: 160, y: 135, width: 180, height: 140),
            .init(id: 1, shape: .triangle, paint: "blue", x: 160, y: 165, width: 60, height: 80),
            .init(id: 2, shape: .circle, paint: "yellow", x: 265, y: 38, width: 40, height: 40),
        ]),
        .init(id: "rocket", name: "rocket", pieces: [
            .init(id: 0, shape: .rectangle, paint: "blue", x: 160, y: 130, width: 60, height: 100),
            .init(id: 1, shape: .triangle, paint: "red", x: 160, y: 50, width: 80, height: 60),
            .init(id: 2, shape: .triangle, paint: "orange", x: 115, y: 185, width: 40, height: 40),
            .init(id: 3, shape: .triangle, paint: "orange", x: 205, y: 185, width: 40, height: 40),
        ]),
        .init(id: "sailboat", name: "sailboat", pieces: [
            .init(id: 0, shape: .rectangle, paint: "brown", x: 160, y: 190, width: 170, height: 30),
            .init(id: 1, shape: .rectangle, paint: "orange", x: 160, y: 116, width: 12, height: 120),
            .init(id: 2, shape: .triangle, paint: "white", x: 112, y: 112, width: 82, height: 90),
            .init(id: 3, shape: .circle, paint: "yellow", x: 267, y: 37, width: 38, height: 38),
        ]),
        .init(id: "car", name: "car", pieces: [
            .init(id: 0, shape: .rectangle, paint: "red", x: 160, y: 130, width: 180, height: 60),
            .init(id: 1, shape: .rectangle, paint: "red", x: 150, y: 88, width: 95, height: 44),
            .init(id: 2, shape: .circle, paint: "black", x: 105, y: 174, width: 44, height: 44),
            .init(id: 3, shape: .circle, paint: "black", x: 215, y: 174, width: 44, height: 44),
        ]),
        .init(id: "bird", name: "bird", pieces: [
            .init(id: 0, shape: .oval, paint: "blue", x: 152, y: 139, width: 110, height: 70),
            .init(id: 1, shape: .circle, paint: "blue", x: 204, y: 93, width: 50, height: 50),
            .init(id: 2, shape: .diamond, paint: "orange", x: 239, y: 95, width: 34, height: 26),
            .init(id: 3, shape: .triangle, paint: "yellow", x: 147, y: 126, width: 58, height: 44),
        ]),
        .init(id: "truck", name: "truck", pieces: [
            .init(id: 0, shape: .rectangle, paint: "green", x: 112, y: 112, width: 125, height: 80),
            .init(id: 1, shape: .rectangle, paint: "blue", x: 220, y: 123, width: 66, height: 65),
            .init(id: 2, shape: .square, paint: "white", x: 222, y: 108, width: 28, height: 28),
            .init(id: 3, shape: .circle, paint: "black", x: 91, y: 177, width: 44, height: 44),
            .init(id: 4, shape: .circle, paint: "black", x: 224, y: 177, width: 44, height: 44),
        ]),
        .init(id: "train", name: "train", pieces: [
            .init(id: 0, shape: .rectangle, paint: "blue", x: 130, y: 135, width: 130, height: 80),
            .init(id: 1, shape: .rectangle, paint: "black", x: 91, y: 74, width: 25, height: 42),
            .init(id: 2, shape: .square, paint: "red", x: 221, y: 115, width: 70, height: 70),
            .init(id: 3, shape: .circle, paint: "black", x: 97, y: 184, width: 42, height: 42),
            .init(id: 4, shape: .circle, paint: "black", x: 220, y: 184, width: 42, height: 42),
        ]),
        .init(id: "robot", name: "robot", pieces: [
            .init(id: 0, shape: .square, paint: "yellow", x: 160, y: 52, width: 65, height: 65),
            .init(id: 1, shape: .rectangle, paint: "blue", x: 160, y: 135, width: 100, height: 80),
            .init(id: 2, shape: .rectangle, paint: "orange", x: 90, y: 133, width: 25, height: 65),
            .init(id: 3, shape: .rectangle, paint: "orange", x: 230, y: 133, width: 25, height: 65),
            .init(id: 4, shape: .rectangle, paint: "gray", x: 160, y: 198, width: 110, height: 24),
        ]),
        .init(id: "flower", name: "flower", pieces: [
            .init(id: 0, shape: .rectangle, paint: "green", x: 160, y: 162, width: 16, height: 100),
            .init(id: 1, shape: .oval, paint: "green", x: 193, y: 163, width: 65, height: 25),
            .init(id: 2, shape: .circle, paint: "pink", x: 121, y: 87, width: 55, height: 55),
            .init(id: 3, shape: .circle, paint: "pink", x: 199, y: 87, width: 55, height: 55),
            .init(id: 4, shape: .circle, paint: "yellow", x: 160, y: 87, width: 55, height: 55),
        ]),
        .init(id: "butterfly", name: "butterfly", pieces: [
            .init(id: 0, shape: .oval, paint: "purple", x: 115, y: 72, width: 80, height: 90),
            .init(id: 1, shape: .oval, paint: "purple", x: 205, y: 72, width: 80, height: 90),
            .init(id: 2, shape: .oval, paint: "pink", x: 122, y: 150, width: 65, height: 60),
            .init(id: 3, shape: .oval, paint: "pink", x: 198, y: 150, width: 65, height: 60),
            .init(id: 4, shape: .rectangle, paint: "black", x: 160, y: 112, width: 18, height: 138),
        ]),
        .init(id: "castle", name: "castle", pieces: [
            .init(id: 0, shape: .rectangle, paint: "gray", x: 160, y: 153, width: 150, height: 80),
            .init(id: 1, shape: .rectangle, paint: "gray", x: 70, y: 132, width: 40, height: 130),
            .init(id: 2, shape: .rectangle, paint: "gray", x: 250, y: 132, width: 40, height: 130),
            .init(id: 3, shape: .triangle, paint: "purple", x: 70, y: 47, width: 65, height: 45),
            .init(id: 4, shape: .triangle, paint: "purple", x: 250, y: 47, width: 65, height: 45),
        ]),
        .init(id: "lighthouse", name: "lighthouse", pieces: [
            .init(id: 0, shape: .rectangle, paint: "white", x: 160, y: 142, width: 65, height: 125),
            .init(id: 1, shape: .triangle, paint: "red", x: 160, y: 53, width: 90, height: 45),
            .init(id: 2, shape: .rectangle, paint: "yellow", x: 160, y: 88, width: 45, height: 18),
            .init(id: 3, shape: .rectangle, paint: "red", x: 160, y: 137, width: 65, height: 20),
            .init(id: 4, shape: .oval, paint: "gray", x: 160, y: 212, width: 160, height: 25),
        ]),
        .init(id: "windmill", name: "windmill", pieces: [
            .init(id: 0, shape: .rectangle, paint: "brown", x: 160, y: 166, width: 55, height: 100),
            .init(id: 1, shape: .triangle, paint: "red", x: 160, y: 98, width: 90, height: 50),
            .init(id: 2, shape: .rectangle, paint: "white", x: 160, y: 79, width: 144, height: 18),
            .init(id: 3, shape: .rectangle, paint: "white", x: 160, y: 79, width: 18, height: 112),
            .init(id: 4, shape: .circle, paint: "yellow", x: 160, y: 79, width: 27, height: 27),
        ]),
    ]
}

struct TownSession {
    private(set) var index = 0
    private(set) var used: Set<Int> = []
    private(set) var placed: Set<Int> = []
    var finished: Bool { index == TownPicture.bank.count }
    var picture: TownPicture { TownPicture.bank[min(index, TownPicture.bank.count - 1)] }
    var completePicture: Bool { placed.count == picture.pieces.count }
    func matchingTarget(pieceID: Int, at point: CGPoint, boardWidth: CGFloat) -> Int? {
        guard CGRect(x: 0, y: 0, width: boardWidth, height: 230).contains(point),
              !finished, !used.contains(pieceID), let source = picture.pieces.first(where: { $0.id == pieceID }) else { return nil }
        return picture.pieces.filter {
            !placed.contains($0.id) && source.matches($0) && $0.dropFrame(boardWidth: boardWidth).contains(point)
        }.min {
            hypot($0.frame(boardWidth: boardWidth).midX - point.x, $0.frame(boardWidth: boardWidth).midY - point.y) <
            hypot($1.frame(boardWidth: boardWidth).midX - point.x, $1.frame(boardWidth: boardWidth).midY - point.y)
        }?.id
    }
    @discardableResult
    mutating func place(pieceID: Int, at point: CGPoint, boardWidth: CGFloat) -> Bool {
        guard let target = matchingTarget(pieceID: pieceID, at: point, boardWidth: boardWidth) else { return false }
        used.insert(pieceID)
        placed.insert(target)
        return true
    }
    mutating func next() {
        guard !finished, completePicture else { return }
        index += 1
        if !finished { used = []; placed = [] }
    }
}

struct ShapeTownGame: View {
    let onReplay: () -> Void
    @State private var town = TownSession()
    @State private var selected: Int?
    @State private var dragging: Int?
    @State private var translation = CGSize.zero
    @State private var hovered: Int?
    @State private var note = "Pick a shape below. Slide it onto its outline."
    @StateObject private var narrator = GameNarrator()
    private var boardHeight: CGFloat { town.picture.pieces.count > 3 ? 400 : 315 }
    var body: some View {
        ToddlerGameScaffold(title: "Build a Shape Town", prompt: town.finished ? TownPicture.completion : town.picture.prompt, accent: .green, completion: town.finished, onReplay: onReplay) {
            Text("Picture \(min(town.index + 1, 20)) of 20 · \(town.picture.name.capitalized)")
                .font(.system(.headline, design: .rounded))
                .accessibilityIdentifier("shapes.town.picture")
            Text("\(town.placed.count) of \(town.picture.pieces.count) shapes placed")
                .font(.subheadline).accessibilityIdentifier("shapes.town.progress")
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 24).fill(Color(red: 0.84, green: 0.91, blue: 0.95))
                        .frame(height: 230).accessibilityHidden(true)
                    ForEach(town.picture.pieces) { piece in
                        outline(piece, width: geometry.size.width)
                    }
                    ForEach(town.picture.pieces) { piece in
                        trayPiece(piece, width: geometry.size.width)
                            .zIndex(dragging == piece.id ? 100 : 1)
                    }
                }.coordinateSpace(name: "town-board")
            }.frame(height: boardHeight)
            SCNote(text: note)
            if town.completePicture && !town.finished {
                ToddlerActionButton(title: town.index == 19 ? "Finish our town" : "Build the next picture", systemImage: "arrow.right", color: .green) {
                    town.next()
                    selected = nil
                    note = "Pick a shape below. Slide it onto its outline."
                }.accessibilityIdentifier("shapes.town.next")
            }
        }
    }
    private func outline(_ piece: TownPiece, width: CGFloat) -> some View {
        let frame = piece.frame(boardWidth: width)
        let filled = town.placed.contains(piece.id)
        return piece.glyph.fill(piece.color.opacity(filled ? 1 : 0.14))
            .overlay(piece.glyph.stroke(hovered == piece.id ? Color.green : Color.primary.opacity(filled ? 0.15 : 0.35), lineWidth: hovered == piece.id ? 4 : 2))
            .frame(width: frame.width, height: frame.height)
            .position(x: frame.midX, y: frame.midY)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(piece.label) outline, \(filled ? "filled" : "empty")")
            .accessibilityIdentifier("shapes.town.target.\(piece.id)")
            .accessibilityAction(named: "Place selected shape here") {
                guard let selected else { return }
                drop(selected, point: CGPoint(x: frame.midX, y: frame.midY), width: width)
            }
    }
    private func trayPiece(_ piece: TownPiece, width: CGFloat) -> some View {
        let cellWidth = (width - 24) / 3
        let origin = CGPoint(x: CGFloat(piece.id % 3) * (cellWidth + 12) + cellWidth / 2, y: 274 + CGFloat(piece.id / 3) * 85)
        let scale = min(52 / piece.width, 44 / piece.height)
        let used = town.used.contains(piece.id)
        return VStack(spacing: 4) {
            piece.glyph.fill(piece.color)
                .overlay(piece.glyph.stroke(Color.black.opacity(0.35), lineWidth: 1))
                .frame(width: piece.width * scale, height: piece.height * scale)
            Text(piece.shape.rawValue.capitalized).font(.system(.caption2, design: .rounded, weight: .bold))
        }.frame(width: cellWidth, height: 76)
            .background(.white, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(selected == piece.id ? Color.green : .clear, lineWidth: 3))
            .opacity(used ? 0.2 : 1)
            .contentShape(Rectangle())
            .onTapGesture {
                guard !used, !town.finished else { return }
                selected = piece.id
                narrator.speak(piece.instruction)
            }
            .highPriorityGesture(pieceDrag(piece, width: width), including: used || town.finished ? .none : .all)
            .offset(dragging == piece.id ? translation : .zero)
            .position(origin)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(piece.label), \(used ? "placed" : "tray shape")")
            .accessibilityIdentifier("shapes.town.piece.\(piece.id)")
            .accessibilityValue(used ? "placed" : "available")
            .accessibilityAction(named: "Select shape") {
                guard !used, !town.finished else { return }
                selected = piece.id
                narrator.speak(piece.instruction)
            }
    }
    private func pieceDrag(_ piece: TownPiece, width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .named("town-board"))
            .onChanged { value in
                guard !town.used.contains(piece.id), !town.finished else { return }
                selected = piece.id
                dragging = piece.id
                translation = value.translation
                hovered = town.matchingTarget(pieceID: piece.id, at: value.location, boardWidth: width)
            }
            .onEnded { value in
                dragging = nil
                translation = .zero
                hovered = nil
                drop(piece.id, point: value.location, width: width)
            }
    }
    private func drop(_ id: Int, point: CGPoint, width: CGFloat) {
        guard !town.finished, !town.used.contains(id) else { return }
        if town.place(pieceID: id, at: point, boardWidth: width) {
            selected = nil
            note = town.completePicture ? town.picture.success : town.picture.pieces[id].success
        } else { note = TownPicture.retry }
        narrator.speak(note)
    }
}
