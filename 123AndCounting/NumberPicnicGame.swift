import SwiftUI

struct NumberPicnicFood: Identifiable {
    let id: String
    let asset: String
    let plural: String
    static let bank: [Self] = [
        .init(id: "apple", asset: "Apple", plural: "apples"),
        .init(id: "orange", asset: "Orange", plural: "oranges"),
        .init(id: "strawberry", asset: "Strawberry", plural: "strawberries")
    ]
    var prompt: String { "Count the \(plural). Choose their number." }
    var retry: String { "Let's count the \(plural) one at a time, then choose their number." }
}

struct NumberPicnicRound {
    let count: Int
    let food: NumberPicnicFood
    let choices: [Int]
    var key: String { "\(count):\(food.id)" }
    var success: String { "You counted \(count) \(food.plural)!" }
    static let completion = "What a picnic! You counted groups from three all the way to ten!"
    static func session() -> [Self] {
        var rounds: [Self] = []
        for count in 3...10 {
            var foods = NumberPicnicFood.bank.shuffled()
            if count == 3 {
                foods = [NumberPicnicFood.bank[0]] + NumberPicnicFood.bank.dropFirst().shuffled()
            } else if foods.first?.id == rounds.last?.food.id { foods.swapAt(0, 1) }
            for food in foods {
                let alternatives = (max(1, count - 2)...min(12, count + 2)).filter { $0 != count }.shuffled().prefix(2)
                rounds.append(Self(count: count, food: food, choices: ([count] + alternatives).shuffled()))
            }
        }
        return rounds
    }
}

struct NumberPicnicSession {
    let rounds = NumberPicnicRound.session()
    private(set) var index = 0
    private(set) var solved = false
    var current: NumberPicnicRound { rounds[min(index, rounds.count - 1)] }
    var finished: Bool { index == rounds.count }
    @discardableResult mutating func choose(_ number: Int) -> Bool {
        guard !finished, !solved, current.choices.contains(number), number == current.count else { return false }
        solved = true
        return true
    }
    mutating func next() {
        guard !finished, solved else { return }
        index += 1
        if !finished { solved = false }
    }
}

struct NumberPicnicGame: View {
    @State private var session = NumberPicnicSession()
    @State private var feedback = "Take your time. Count each piece of fruit once."
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Number Picnic", prompt: session.finished ? NumberPicnicRound.completion : session.current.food.prompt, accent: .indigo, completion: session.finished, onReplay: {
            session = NumberPicnicSession()
            feedback = "Take your time. Count each piece of fruit once."
        }) {
            Text("Round \(min(session.index + 1, session.rounds.count)) of \(session.rounds.count)")
                .font(.system(.headline, design: .rounded)).accessibilityIdentifier("counting.picnic.round")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 14) {
                ForEach(0..<session.current.count, id: \.self) { index in
                    GeometryReader { geometry in
                        ToddlerArt(asset: session.current.food.asset, size: min(60, geometry.size.width))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }.aspectRatio(1, contentMode: .fit)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(session.current.food.id.capitalized)
                        .accessibilityIdentifier("counting.picnic.fruit.\(index)")
                }
            }.padding(12).frame(maxWidth: 460)
                .background(.white, in: RoundedRectangle(cornerRadius: 24))
            HStack(spacing: 10) {
                ForEach(session.current.choices, id: \.self) { number in
                    Button {
                        if session.choose(number) { feedback = session.current.success }
                        else { feedback = session.current.food.retry }
                        narrator.speak(feedback)
                    } label: {
                        VStack(spacing: 10) {
                            Text("\(number)").font(.system(size: 36, weight: .bold, design: .rounded))
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(8), spacing: 4), count: 5), spacing: 4) {
                                ForEach(0..<number, id: \.self) { _ in Circle().fill(.indigo).frame(width: 8, height: 8) }
                            }.frame(height: 32, alignment: .top)
                        }.frame(maxWidth: .infinity, minHeight: 114)
                            .background(session.solved && number == session.current.count ? Color.indigo.opacity(0.16) : .white, in: RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.indigo.opacity(0.35), lineWidth: 2))
                    }.buttonStyle(.plain).foregroundStyle(.indigo)
                        .accessibilityLabel("\(number)")
                        .accessibilityIdentifier("counting.picnic.answer.\(number)")
                        .disabled(session.solved || session.finished)
                }
            }
            Text(feedback).font(.system(.title3, design: .rounded, weight: .medium)).multilineTextAlignment(.center)
                .accessibilityIdentifier("counting.picnic.feedback")
            if session.solved && !session.finished {
                ToddlerActionButton(title: session.index == session.rounds.count - 1 ? "Finish our picnic" : "Next picnic round", systemImage: "arrow.right.circle.fill", color: .indigo) {
                    session.next()
                    feedback = "Take your time. Count each piece of fruit once."
                }.accessibilityIdentifier("counting.picnic.next")
            }
        }
    }
}
