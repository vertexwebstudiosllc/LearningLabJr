import SwiftUI

struct PicnicFood: Identifiable {
    let word: String
    let asset: String
    var id: String { word }
    var basketPrompt: String { "Find \(word)." }
    var packedPrompt: String { "Packed \(word)." }
    var retry: String { "This is \(word). Check the basket labels." }

    static let bank: [PicnicFood] = [
        .init(word: "apple", asset: "AppleClean"),
        .init(word: "milk", asset: "Milk"),
        .init(word: "sandwich", asset: "Sandwich"),
        .init(word: "orange", asset: "Orange"),
        .init(word: "banana", asset: "Bananna"),
        .init(word: "grapes", asset: "Grape"),
        .init(word: "cheese", asset: "Cheese"),
        .init(word: "carrot", asset: "carrot"),
        .init(word: "bread", asset: "Bread"),
        .init(word: "pear", asset: "Pear"),
        .init(word: "strawberry", asset: "Strawberry"),
        .init(word: "watermelon", asset: "Watermelon")
    ]
}

struct PicnicRound {
    let targets: [PicnicFood]
    let choices: [PicnicFood]
    var key: String { targets.map(\.word).sorted().joined(separator: ",") }
    var prompt: String { "Pack \(targets[0].word), \(targets[1].word), and \(targets[2].word). Tap the foods in any order." }
    static let success = "Your picnic is packed! You found all three foods."

    static let lists: [[PicnicFood]] = {
        let foods = PicnicFood.bank
        return (0..<(foods.count - 2)).flatMap { a in
            ((a + 1)..<(foods.count - 1)).flatMap { b in
                ((b + 1)..<foods.count).map { c in [foods[a], foods[b], foods[c]] }
            }
        }
    }()

    static func next(recent: [String]) -> PicnicRound {
        let excluded = Set(recent.suffix(20))
        let targets = lists.filter { !excluded.contains($0.map(\.word).sorted().joined(separator: ",")) }.randomElement()!
        let ids = Set(targets.map(\.id))
        let others = PicnicFood.bank.filter { !ids.contains($0.id) }.shuffled().prefix(3)
        return PicnicRound(targets: targets, choices: (targets + Array(others)).shuffled())
    }

    func packing(_ word: String, into packed: Set<String>) -> Set<String> {
        guard targets.contains(where: { $0.id == word }) else { return packed }
        return packed.union([word])
    }
}

struct PicnicWordsGame: View {
    @StateObject private var narrator = GameNarrator()
    @AppStorage("picnicWords.recentLists") private var recentLists = ""
    @State private var current: PicnicRound?
    @State private var packed: Set<String> = []
    @State private var feedback = ""

    var body: some View {
        VStack(spacing: 0) {
            if let current {
                ToddlerGameScaffold(title: "Picnic Words", prompt: current.prompt, accent: .orange) {
                    VStack(spacing: 14) {
                        HStack(alignment: .top, spacing: 8) {
                            ForEach(current.targets) { food in
                                Button { narrator.speak(food.basketPrompt) } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: packed.contains(food.id) ? "basket.fill" : "basket")
                                            .font(.system(size: 38)).foregroundStyle(.brown)
                                            .frame(height: 46)
                                            .overlay(alignment: .topTrailing) {
                                                if packed.contains(food.id) {
                                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).background(.white, in: Circle())
                                                }
                                            }
                                        Text(food.word.capitalized).font(.subheadline.bold())
                                            .multilineTextAlignment(.center).lineLimit(2)
                                            .frame(height: 38)
                                    }.frame(maxWidth: .infinity).padding(6)
                                        .background(packed.contains(food.id) ? Color.green.opacity(0.12) : Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(food.word)
                                .accessibilityValue(packed.contains(food.id) ? "Packed" : "Empty")
                                .accessibilityHint("Hear the food to pack")
                                .accessibilityIdentifier("picnic.basket.\(food.id)")
                            }
                        }
                        Text("\(packed.count) of 3 foods packed").font(.subheadline.weight(.semibold))
                            .accessibilityIdentifier("picnic.progress")
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                            ForEach(current.choices) { food in
                                Button { pack(food, in: current) } label: {
                                    VStack(spacing: 4) {
                                        ToddlerArt(asset: food.asset, size: 58)
                                        Text(food.word.capitalized).font(.footnote.bold())
                                            .multilineTextAlignment(.center).lineLimit(2).frame(height: 32)
                                    }.frame(maxWidth: .infinity).padding(8)
                                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(packed.contains(food.id) ? Color.green : Color.orange.opacity(0.4), lineWidth: 2))
                                }
                                .buttonStyle(.plain)
                                .disabled(packed.contains(food.id) || packed.count == 3)
                                .accessibilityLabel(food.word)
                                .accessibilityValue(packed.contains(food.id) ? "Packed" : "Not packed")
                                .accessibilityIdentifier("picnic.food.\(food.id)")
                            }
                        }
                        if !feedback.isEmpty {
                            Text(feedback).font(.headline).multilineTextAlignment(.center)
                        }
                        if packed.count == 3 {
                            ToddlerActionButton(title: "Next picnic", systemImage: "arrow.right.circle.fill", color: .orange, action: nextPicnic)
                        }
                    }
                }
            }
        }
        .onAppear { if current == nil { nextPicnic() } }
        .onDisappear { current = nil; narrator.stop() }
    }

    private func pack(_ food: PicnicFood, in round: PicnicRound) {
        guard packed.count < 3, !packed.contains(food.id) else { return }
        let updated = round.packing(food.id, into: packed)
        if updated == packed { feedback = food.retry }
        else {
            packed = updated
            feedback = packed.count == 3 ? PicnicRound.success : food.packedPrompt
        }
        narrator.speak(feedback)
    }

    private func nextPicnic() {
        narrator.stop()
        let recent = recentLists.split(separator: "|").map(String.init)
        let round = PicnicRound.next(recent: recent)
        recentLists = (recent + [round.key]).suffix(20).joined(separator: "|")
        packed = []
        feedback = ""
        current = round
    }
}
