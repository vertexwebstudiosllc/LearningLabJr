import SwiftUI

struct SafariObject: Identifiable {
    let id: String
    let name: String
    let shape: PostShape
    let paint: String
    let detail: String
    var success: String { "The \(name.lowercased()) has a \(shape.rawValue) shape." }
    static let bank: [Self] = [
        .init(id: "clock", name: "Clock face", shape: .circle, paint: "blue", detail: "clock"),
        .init(id: "plate", name: "Round plate", shape: .circle, paint: "pink", detail: "ring"),
        .init(id: "button", name: "Button", shape: .circle, paint: "orange", detail: "holes"),
        .init(id: "window", name: "Window pane", shape: .square, paint: "sky-blue", detail: "window"),
        .init(id: "cracker", name: "Square cracker", shape: .square, paint: "ochre", detail: "holes"),
        .init(id: "square-tile", name: "Square tile", shape: .square, paint: "purple", detail: "inset"),
        .init(id: "tent", name: "Tent front", shape: .triangle, paint: "orange", detail: "tent"),
        .init(id: "sail", name: "Sail", shape: .triangle, paint: "blue", detail: "seam"),
        .init(id: "mountain", name: "Mountain peak", shape: .triangle, paint: "green", detail: "snow"),
        .init(id: "door", name: "Door", shape: .rectangle, paint: "brown", detail: "door"),
        .init(id: "book", name: "Book cover", shape: .rectangle, paint: "red", detail: "book"),
        .init(id: "phone", name: "Phone screen", shape: .rectangle, paint: "navy", detail: "phone"),
        .init(id: "egg", name: "Egg", shape: .oval, paint: "cream", detail: "shine"),
        .init(id: "mirror", name: "Oval mirror", shape: .oval, paint: "sky-blue", detail: "inset"),
        .init(id: "rug", name: "Oval rug", shape: .oval, paint: "purple", detail: "inset"),
        .init(id: "kite", name: "Kite", shape: .diamond, paint: "orange", detail: "window"),
        .init(id: "diamond-tile", name: "Diamond tile", shape: .diamond, paint: "pink", detail: "inset"),
        .init(id: "diamond-sign", name: "Diamond sign", shape: .diamond, paint: "yellow", detail: "arrow.up"),
        .init(id: "star-sticker", name: "Star sticker", shape: .star, paint: "yellow", detail: "face.smiling"),
        .init(id: "star-cookie", name: "Star cookie", shape: .star, paint: "ochre", detail: "holes"),
        .init(id: "star-ornament", name: "Star ornament", shape: .star, paint: "blue", detail: "inset"),
        .init(id: "heart-balloon", name: "Heart balloon", shape: .heart, paint: "pink", detail: "shine"),
        .init(id: "heart-cookie", name: "Heart cookie", shape: .heart, paint: "ochre", detail: "holes"),
        .init(id: "heart-card", name: "Heart card", shape: .heart, paint: "red", detail: "inset"),
        .init(id: "pentagon-badge", name: "Pentagon badge", shape: .pentagon, paint: "blue", detail: "star.fill"),
        .init(id: "pentagon-tile", name: "Pentagon tile", shape: .pentagon, paint: "green", detail: "inset"),
        .init(id: "pentagon-sign", name: "Pentagon sign", shape: .pentagon, paint: "yellow", detail: "figure.walk"),
        .init(id: "honeycomb", name: "Honeycomb cell", shape: .hexagon, paint: "ochre", detail: "inset"),
        .init(id: "hexagon-tile", name: "Hexagon tile", shape: .hexagon, paint: "purple", detail: "inset"),
        .init(id: "nut", name: "Hexagon nut", shape: .hexagon, paint: "gray", detail: "hole"),
    ]
}

struct SafariRound {
    let target: PostShape
    let objects: [SafariObject]
    var prompt: String { "Find two things with a \(target.rawValue) shape." }
    var retry: String { "Let's look again. Find something with a \(target.rawValue) shape." }
    static let completion = "Thirty safari discoveries! You found ten shapes in so many things!"
    static func session() -> [Self] {
        let pairs = Dictionary(uniqueKeysWithValues: PostShape.allCases.map { shape in
            (shape, SafariObject.bank.filter { $0.shape == shape }.shuffled())
        })
        var result: [Self] = []
        for cycle in 0..<3 {
            var shapes = PostShape.allCases.shuffled()
            if shapes.first == result.last?.target { shapes.swapAt(0, 1) }
            for shape in shapes {
                let examples = pairs[shape]!
                let matches = [examples[cycle], examples[(cycle + 1) % 3]]
                let distractors = SafariObject.bank.filter { $0.shape != shape }.shuffled().prefix(4)
                result.append(Self(target: shape, objects: (matches + distractors).shuffled()))
            }
        }
        return result
    }
}

struct SafariSession {
    let rounds = SafariRound.session()
    private(set) var index = 0
    private(set) var found: Set<String> = []
    var current: SafariRound { rounds[min(index, rounds.count - 1)] }
    var solved: Bool { found.count == 2 }
    var finished: Bool { index == rounds.count }
    @discardableResult mutating func choose(_ id: String) -> Bool {
        guard !finished, !solved, !found.contains(id), let object = current.objects.first(where: { $0.id == id }), object.shape == current.target else { return false }
        found.insert(id)
        return true
    }
    mutating func next() {
        guard !finished, solved else { return }
        index += 1
        if !finished { found = [] }
    }
}

struct ShapeSafariGame: View {
    let onReplay: () -> Void
    @State private var session = SafariSession()
    @State private var note = "Look at the outside shape of each picture."
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Shape Safari", prompt: session.finished ? SafariRound.completion : session.current.prompt, accent: .green, completion: session.finished, onReplay: onReplay) {
            Text("Level \(min(session.index + 1, 30)) of 30 · \(session.current.target.name)")
                .font(.system(.headline, design: .rounded)).accessibilityIdentifier("shapes.safari.level")
            Image(systemName: session.current.target.symbol).resizable().scaledToFit().frame(width: 64, height: 64).foregroundStyle(.green)
                .accessibilityLabel("Look for a \(session.current.target.rawValue)")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(session.current.objects) { object in
                    Button {
                        if session.choose(object.id) { note = object.success }
                        else { note = session.current.retry }
                        narrator.speak(note)
                    } label: {
                        VStack(spacing: 6) {
                            SafariIllustration(object: object).frame(height: 78)
                            Text(object.name).font(.system(.caption, design: .rounded, weight: .bold))
                                .multilineTextAlignment(.center).frame(minHeight: 32)
                        }.frame(maxWidth: .infinity).padding(8)
                            .background(.white, in: RoundedRectangle(cornerRadius: 18))
                            .overlay(alignment: .topTrailing) {
                                if session.found.contains(object.id) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).padding(6) }
                            }
                    }.buttonStyle(.plain).foregroundStyle(.primary)
                        .accessibilityLabel(object.name + (session.found.contains(object.id) ? ", found" : ""))
                        .accessibilityIdentifier("shapes.safari.object.\(object.id)")
                        .disabled(session.finished || session.solved || session.found.contains(object.id))
                }
            }
            Text("\(session.found.count) of 2 things found").font(.subheadline).accessibilityIdentifier("shapes.safari.progress")
            if session.solved && !session.finished {
                ToddlerActionButton(title: session.index == 29 ? "Finish our safari" : "Find another shape", systemImage: "magnifyingglass", color: .green) {
                    session.next(); note = "Look at the outside shape of each picture."
                }.accessibilityIdentifier("shapes.safari.next")
            }
            SCNote(text: note)
        }
    }
}

private struct SafariIllustration: View {
    let object: SafariObject
    private var width: CGFloat { object.shape == .rectangle ? 55 : object.shape == .oval ? 58 : 76 }
    var body: some View {
        ZStack {
            Image(systemName: object.shape.symbol + ".fill").resizable()
                .foregroundStyle(LabPaint.named(object.paint).color)
            detail.foregroundStyle(object.paint == "cream" || object.paint == "yellow" || object.paint == "ochre" ? Color.brown : .white)
        }.frame(width: width, height: 76)
    }
    @ViewBuilder private var detail: some View {
        switch object.detail {
        case "ring": Circle().stroke(.white, lineWidth: 3).padding(12)
        case "hole": Circle().fill(.white).frame(width: 28, height: 28)
        case "holes":
            VStack(spacing: 9) { ForEach(0..<2, id: \.self) { _ in
                HStack(spacing: 9) { ForEach(0..<2, id: \.self) { _ in Circle().frame(width: 5, height: 5) } }
            } }
        case "inset": Image(systemName: object.shape.symbol).resizable().padding(12)
        case "window":
            Rectangle().frame(width: 3, height: 54)
            Rectangle().frame(width: 54, height: 3)
        case "clock":
            Path { path in path.move(to: CGPoint(x: width / 2, y: 18)); path.addLine(to: CGPoint(x: width / 2, y: 38)); path.addLine(to: CGPoint(x: width / 2 + 16, y: 38)) }.stroke(lineWidth: 3)
        case "tent": Image(systemName: "triangle.fill").resizable().scaledToFit().frame(width: 24, height: 34).offset(y: 15)
        case "snow": Image(systemName: "triangle.fill").resizable().scaledToFit().frame(width: 23, height: 22).offset(y: -17)
        case "seam": Rectangle().frame(width: 2, height: 45).offset(y: 7)
        case "door": Circle().frame(width: 6, height: 6).offset(x: 16, y: 4)
        case "book":
            Rectangle().frame(width: 3, height: 54).offset(x: -16)
            Image(systemName: "sun.max.fill").font(.system(size: 21))
        case "phone": RoundedRectangle(cornerRadius: 3).stroke(lineWidth: 2).padding(.horizontal, 8).padding(.vertical, 10)
        case "shine": Capsule().frame(width: 8, height: 20).rotationEffect(.degrees(30)).offset(x: -12, y: -12)
        default: Image(systemName: object.detail).font(.system(size: 24))
        }
    }
}
