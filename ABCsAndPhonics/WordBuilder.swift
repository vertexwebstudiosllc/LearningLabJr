import SwiftUI

struct WordBuilderWord {
    let word: String
    let asset: String
    var letters: [String] { word.map(String.init) }
    var prompt: String { "Let's build \(word.lowercased()). Copy the letters from left to right. Your grown-up can help." }
    var success: String { "You built \(word.lowercased())! \(letters.joined(separator: ", ")). \(word.lowercased())." }

    static let bank: [WordBuilderWord] = [
        .init(word: "CAT", asset: "cat"),
        .init(word: "DOG", asset: "dog"),
        .init(word: "SUN", asset: "Sun"),
        .init(word: "PIG", asset: "pig"),
        .init(word: "COW", asset: "cow"),
        .init(word: "HEN", asset: "hen"),
        .init(word: "EGG", asset: "Egg"),
        .init(word: "JAM", asset: "Jam"),
        .init(word: "EEL", asset: "eel"),
        .init(word: "GOAT", asset: "goat"),
        .init(word: "DUCK", asset: "duck"),
        .init(word: "FISH", asset: "Fish"),
        .init(word: "MOON", asset: "Moon"),
        .init(word: "MILK", asset: "Milk"),
        .init(word: "PEAR", asset: "Pear"),
        .init(word: "PLUM", asset: "Plum"),
        .init(word: "CORN", asset: "Corn"),
        .init(word: "LAMB", asset: "lamb"),
        .init(word: "CRAB", asset: "crab"),
        .init(word: "SEAL", asset: "seal"),
        .init(word: "STAR", asset: "Star"),
        .init(word: "KIWI", asset: "Kiwi"),
        .init(word: "SOUP", asset: "Soup"),
        .init(word: "RICE", asset: "Rice"),
        .init(word: "PEAS", asset: "Peas"),
        .init(word: "APPLE", asset: "Apple"),
        .init(word: "GRAPE", asset: "Grape"),
        .init(word: "LEMON", asset: "Lemon"),
        .init(word: "PEACH", asset: "Peach"),
        .init(word: "BREAD", asset: "Bread"),
        .init(word: "TOAST", asset: "Toast"),
        .init(word: "SHARK", asset: "shark"),
        .init(word: "SHEEP", asset: "sheep"),
        .init(word: "WHALE", asset: "whale"),
        .init(word: "HORSE", asset: "horse"),
        .init(word: "MOUSE", asset: "mouse"),
        .init(word: "GOOSE", asset: "goose"),
        .init(word: "CHICK", asset: "chick"),
        .init(word: "PIZZA", asset: "Pizza"),
        .init(word: "PASTA", asset: "Pasta"),
        .init(word: "ONION", asset: "onion"),
        .init(word: "MANGO", asset: "Mango"),
        .init(word: "LLAMA", asset: "llama"),
        .init(word: "BAGEL", asset: "Bagel"),
        .init(word: "EARTH", asset: "Earth"),
    ]

    static func next(recent: [String]) -> WordBuilderWord {
        let excluded = Set(recent.suffix(20))
        return bank.filter { !excluded.contains($0.word) }.randomElement()!
    }

    static func remembering(_ word: String, recent: [String]) -> [String] {
        Array((recent + [word]).suffix(20))
    }
}

struct GuidedWordBuilderGame: View {
    @StateObject private var play = LiteracyPlay()
    @StateObject private var narrator = GameNarrator()
    @AppStorage("wordBuilder.recentWords") private var recentWords = ""
    @State private var current: WordBuilderWord?
    @State private var choices: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            if let current {
                ToddlerGameScaffold(title: "Word Builder", prompt: current.prompt, accent: .orange) {
                    VStack(spacing: 18) {
                        VStack(spacing: 8) {
                            LiteracyVocabularyArt(word: current.word).frame(width: 96, height: 96)
                            Text(current.word).font(.title.bold())
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(current.word)
                        .accessibilityIdentifier("word-builder.target")
                        Text("\(play.count) of \(current.letters.count) letters")
                            .font(.subheadline.weight(.semibold))
                        HStack(spacing: 6) {
                            ForEach(current.letters.indices, id: \.self) { index in
                                Text(index < play.count ? current.letters[index] : "·")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .frame(maxWidth: .infinity, minHeight: 64)
                                    .background(Color.orange.opacity(index == play.count ? 0.25 : 0.1), in: RoundedRectangle(cornerRadius: 14))
                                    .accessibilityLabel(index < play.count ? "Letter \(current.letters[index]) placed" : "Empty letter space \(index + 1)")
                            }
                        }
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 8)], spacing: 8) {
                            ForEach(choices, id: \.self) { letter in
                                Button { choose(letter, in: current) } label: {
                                    Text(letter).font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundStyle(.brown)
                                        .frame(maxWidth: .infinity, minHeight: 68)
                                        .background(.orange.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Letter \(letter)")
                                .accessibilityIdentifier("word-builder.letter.\(letter)")
                                .disabled(play.solved)
                            }
                        }
                        if !play.feedback.isEmpty {
                            Text(play.feedback).font(.title3.weight(.semibold)).multilineTextAlignment(.center)
                        }
                        if play.solved {
                            ToddlerActionButton(title: "Next word", systemImage: "arrow.right.circle.fill", color: .orange, action: nextWord)
                        }
                    }
                }
            }
        }
        .onAppear { if current == nil { nextWord() } }
        .onDisappear { current = nil; narrator.stop() }
        .onChange(of: play.feedbackRevision) { _, _ in
            if !play.feedback.isEmpty { narrator.speak(play.feedback) }
        }
    }

    private func choose(_ letter: String, in item: WordBuilderWord) {
        guard !play.solved, item.letters.indices.contains(play.count) else { return }
        if letter == item.letters[play.count] {
            play.count += 1
            if play.count == item.letters.count { play.win(item.success) }
            else { play.say("\(letter). Next find \(item.letters[play.count]).") }
        } else {
            play.say("Look at the model. Find \(item.letters[play.count]) next.")
        }
    }

    private func nextWord() {
        let recent = recentWords.split(separator: "|").map(String.init)
        let item = WordBuilderWord.next(recent: recent)
        recentWords = WordBuilderWord.remembering(item.word, recent: recent).joined(separator: "|")
        choices = Array(Set(item.letters)).shuffled()
        play.replay()
        current = item
    }
}
