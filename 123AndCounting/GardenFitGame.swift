import SwiftUI

struct GardenFitRound {
    let spots: [Int]
    let choices: [Int]
    static let combinations: [[Int]] = {
        var result: [[Int]] = []
        for a in 1...4 { for b in (a + 1)...5 { for c in (b + 1)...6 {
            for d in (c + 1)...7 { for e in (d + 1)...8 { result.append([a, b, c, d, e]) } }
        } } }
        return result
    }()
    static func session() -> [Self] {
        var sets = Array(combinations.shuffled().prefix(20))
        let missing = Set(1...8).subtracting(sets.flatMap { $0 })
        if !missing.isEmpty, let replacement = combinations.first(where: { missing.isSubset(of: Set($0)) }) {
            sets[sets.count - 1] = replacement
        }
        return sets.map { Self(spots: $0.shuffled(), choices: $0.shuffled()) }
    }
    static let prompt = "Match the petals! Drag each flower to its matching garden spot."
    static let completion = "Your flower gardens are blooming! You matched all the petals!"
    static func clue(_ petals: Int) -> String { "\(petals) \(petals == 1 ? "petal" : "petals"). Find the matching garden spot." }
    static func retry(_ petals: Int) -> String { "Try the spot with \(petals) \(petals == 1 ? "petal" : "petals")." }
    static func success(_ petals: Int) -> String { "A flower with \(petals) \(petals == 1 ? "petal" : "petals")! You planted it!" }
}

struct GardenFitSession {
    let rounds = GardenFitRound.session()
    private(set) var index = 0
    private(set) var planted: Set<Int> = []
    var current: GardenFitRound { rounds[min(index, rounds.count - 1)] }
    var solved: Bool { planted.count == 5 }
    var finished: Bool { index == rounds.count }
    @discardableResult mutating func plant(_ petals: Int, at spot: Int?) -> Bool {
        guard !finished, !solved, current.choices.contains(petals), !planted.contains(petals),
              let spot, current.spots.indices.contains(spot), current.spots[spot] == petals else { return false }
        planted.insert(petals)
        return true
    }
    mutating func next() {
        guard !finished, solved else { return }
        index += 1
        if !finished { planted = [] }
    }
}

private struct GardenPetalFlower: View {
    let petals: Int
    var outline = false
    var body: some View {
        ZStack {
            Capsule().fill(outline ? Color.white.opacity(0.65) : Color.green).frame(width: 4, height: 27).offset(y: 17)
            ForEach(0..<petals, id: \.self) { index in
                Ellipse().fill(outline ? Color.white.opacity(0.12) : Color.pink)
                    .overlay(Ellipse().stroke(outline ? Color.white : Color.pink.opacity(0.7), lineWidth: 1.5))
                    .frame(width: 11, height: 20).offset(y: -17)
                    .rotationEffect(.degrees(Double(index) * 360 / Double(petals)))
                    .offset(y: -5)
            }
            Circle().fill(outline ? Color.brown : Color.yellow)
                .overlay(Circle().stroke(outline ? Color.white : Color.orange, lineWidth: 1.5))
                .frame(width: 12, height: 12).offset(y: -5)
        }.frame(width: 60, height: 70)
    }
}

struct FiveFrameGardenGame: View {
    @State private var session = GardenFitSession()
    @State private var dragged: Int?
    @State private var offset = CGSize.zero
    @State private var hover: Int?
    @State private var feedback = ""
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ToddlerGameScaffold(title: "Five-Frame Garden", prompt: session.finished ? GardenFitRound.completion : GardenFitRound.prompt,
                            accent: .green, completion: session.finished, onReplay: {
            narrator.stop(); session = GardenFitSession(); resetDrag(); feedback = ""
        }) {
            Text("Garden \(min(session.index + 1, 20)) of 20").font(.headline).accessibilityIdentifier("counting.garden.level")
            Text("\(session.planted.count) of 5 flowers planted").font(.headline).accessibilityIdentifier("counting.garden.progress")
            GeometryReader { geometry in
                let width = geometry.size.width
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 24).fill(Color.green.opacity(0.18)).frame(height: 254)
                    ForEach(session.current.spots.indices, id: \.self) { index in
                        let petals = session.current.spots[index]
                        let frame = spotFrame(index, width: width)
                        VStack(spacing: 0) {
                            GardenPetalFlower(petals: petals, outline: !session.planted.contains(petals))
                            Text("\(petals)").font(.system(.headline, design: .rounded)).foregroundStyle(.white)
                        }.frame(width: frame.width, height: frame.height)
                            .background(Color.brown, in: RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(hover == index ? Color.yellow : Color.brown.opacity(0.3), lineWidth: 3))
                            .position(x: frame.midX, y: frame.midY)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Garden spot, \(petals) \(petals == 1 ? "petal" : "petals"), \(session.planted.contains(petals) ? "planted" : "empty")")
                            .accessibilityIdentifier("counting.garden.spot.\(petals)")
                    }
                    Text("Choose a flower").font(.headline).frame(width: width).position(x: width / 2, y: 280)
                    ForEach(Array(session.current.choices.enumerated()), id: \.element) { index, petals in
                        GardenPetalFlower(petals: petals)
                            .frame(width: width / 5 - 4, height: 82)
                            .background(.white, in: RoundedRectangle(cornerRadius: 14))
                            .opacity(session.planted.contains(petals) ? 0.2 : 1)
                            .contentShape(Rectangle())
                            .highPriorityGesture(DragGesture(minimumDistance: 4, coordinateSpace: .named("garden-fit"))
                                .onChanged { value in
                                    guard !session.finished, !session.planted.contains(petals) else { return }
                                    if dragged == nil { narrator.speak(GardenFitRound.clue(petals)) }
                                    dragged = petals; offset = value.translation
                                    hover = session.current.spots.indices.first { spotFrame($0, width: width).contains(value.location) }
                                }
                                .onEnded { value in
                                    let spot = session.current.spots.indices.first { spotFrame($0, width: width).contains(value.location) }
                                    resetDrag(); plant(petals, at: spot)
                                }, including: session.finished || session.planted.contains(petals) ? .none : .all)
                            .offset(dragged == petals ? offset : .zero)
                            .position(x: (CGFloat(index) + 0.5) * width / 5, y: 337)
                            .zIndex(dragged == petals ? 1 : 0)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Flower with \(petals) \(petals == 1 ? "petal" : "petals")")
                            .accessibilityValue(session.planted.contains(petals) ? "Planted" : "Ready to plant")
                            .accessibilityIdentifier("counting.garden.flower.\(petals)")
                            .accessibilityAction(named: "Plant in matching spot") { plant(petals, at: session.current.spots.firstIndex(of: petals)) }
                    }
                }.coordinateSpace(name: "garden-fit")
            }.frame(height: 382)
            if !feedback.isEmpty { Text(feedback).font(.headline).multilineTextAlignment(.center).accessibilityIdentifier("counting.garden.feedback") }
            if session.solved && !session.finished {
                ToddlerActionButton(title: session.index == 19 ? "Finish our gardens" : "Next garden", systemImage: "leaf.fill", color: .green) {
                    narrator.stop(); session.next(); resetDrag(); feedback = ""
                }.accessibilityIdentifier("counting.garden.next")
            }
        }.id(min(session.index, 19))
            .onDisappear { narrator.stop() }
    }
    private func spotFrame(_ index: Int, width: CGFloat) -> CGRect {
        let cell = min(100, width / 3 - 10)
        let x = index < 3 ? (CGFloat(index) + 0.5) * width / 3 : CGFloat(index - 2) * width / 3
        return CGRect(x: x - cell / 2, y: index < 3 ? 12 : 134, width: cell, height: 108)
    }
    private func resetDrag() { dragged = nil; offset = .zero; hover = nil }
    private func plant(_ petals: Int, at spot: Int?) {
        guard !session.finished, !session.planted.contains(petals) else { return }
        feedback = session.plant(petals, at: spot) ? GardenFitRound.success(petals) : GardenFitRound.retry(petals)
        narrator.speak(feedback)
    }
}
