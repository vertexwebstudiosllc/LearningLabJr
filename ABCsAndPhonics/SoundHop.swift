import SwiftUI

struct HopWord {
    let word: String
    let asset: String
    let parts: [String]
    var beats: Int { parts.count }
    var prompt: String { "Say \(word) with your grown-up. Clap once for each word part, then tap the hop button for each clap." }
    var success: String { "\(word) has \(beats) \(beats == 1 ? "beat" : "beats"). You heard the word parts!" }
    // Read the whole word naturally; the visible parts support caregiver claps.
    var retry: String { "Let's try together: \(word). Make \(beats) \(beats == 1 ? "clap" : "claps")." }

    static let bank: [HopWord] = [
        .init(word: "cat", asset: "cat", parts: ["cat"]),
        .init(word: "dog", asset: "dog", parts: ["dog"]),
        .init(word: "cow", asset: "cow", parts: ["cow"]),
        .init(word: "pig", asset: "pig", parts: ["pig"]),
        .init(word: "hen", asset: "hen", parts: ["hen"]),
        .init(word: "duck", asset: "duck", parts: ["duck"]),
        .init(word: "fish", asset: "Fish", parts: ["fish"]),
        .init(word: "moon", asset: "Moon", parts: ["moon"]),
        .init(word: "goat", asset: "goat", parts: ["goat"]),
        .init(word: "sheep", asset: "sheep", parts: ["sheep"]),
        .init(word: "rabbit", asset: "rabbit", parts: ["rab", "bit"]),
        .init(word: "turtle", asset: "turtle", parts: ["tur", "tle"]),
        .init(word: "apple", asset: "AppleClean", parts: ["ap", "ple"]),
        .init(word: "lemon", asset: "Lemon", parts: ["lem", "on"]),
        .init(word: "pizza", asset: "Pizza", parts: ["piz", "za"]),
        .init(word: "chicken", asset: "chicken", parts: ["chick", "en"]),
        .init(word: "donkey", asset: "donkey", parts: ["don", "key"]),
        .init(word: "penguin", asset: "penguin", parts: ["pen", "guin"]),
        .init(word: "lobster", asset: "lobster", parts: ["lob", "ster"]),
        .init(word: "dolphin", asset: "dolphinClean", parts: ["dol", "phin"]),
        .init(word: "octopus", asset: "octopus", parts: ["oc", "to", "pus"]),
        .init(word: "banana", asset: "Bananna", parts: ["ba", "na", "na"]),
        .init(word: "potato", asset: "Potato", parts: ["po", "ta", "to"]),
        .init(word: "tomato", asset: "tomato", parts: ["to", "ma", "to"]),
        .init(word: "pineapple", asset: "Pineapple", parts: ["pine", "ap", "ple"]),
        .init(word: "hamburger", asset: "Hamburger", parts: ["ham", "bur", "ger"]),
        .init(word: "cucumber", asset: "Cucumber", parts: ["cu", "cum", "ber"]),
        .init(word: "volcano", asset: "Volcano", parts: ["vol", "ca", "no"]),
        .init(word: "jellyfish", asset: "jellyfish", parts: ["jel", "ly", "fish"]),
        .init(word: "basketball", asset: "basketball", parts: ["bas", "ket", "ball"]),
    ]

    static func next(recent: [String]) -> HopWord {
        let excluded = Set(recent.suffix(20))
        return bank.filter { !excluded.contains($0.word) }.randomElement()!
    }
}

struct WordBeatHopGame: View {
    @StateObject private var play = LiteracyPlay()
    @StateObject private var narrator = GameNarrator()
    @AppStorage("soundHop.recentWords") private var recentWords = ""
    @State private var current: HopWord?

    var body: some View {
        VStack(spacing: 0) {
            if let current {
                ToddlerGameScaffold(title: "Syllable Hop", prompt: current.prompt, accent: .orange) {
                    VStack(spacing: 18) {
                        VStack(spacing: 8) {
                            ToddlerArt(asset: current.asset, size: 96)
                            Text(current.word).font(.title.bold())
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(current.word)
                        .accessibilityIdentifier("sound-hop.target")
                        Text(current.parts.joined(separator: " · ")).font(.title.bold())
                        HStack(spacing: 10) {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: index < play.count ? "leaf.circle.fill" : "circle")
                                    .font(.system(size: 46)).foregroundStyle(index < play.count ? .green : .gray)
                            }
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(play.count) word beats tapped")
                        .accessibilityIdentifier("sound-hop.beats")
                        VStack(spacing: 14) {
                            ToddlerActionButton(title: "Hop one word beat", systemImage: "hands.clap.fill", color: .orange) {
                                guard !play.solved, play.count < 3 else { return }
                                play.count += 1
                                play.say("\(play.count)")
                            }.disabled(play.count == 3)
                            ToddlerActionButton(title: "Check our word beats", systemImage: "checkmark.circle.fill", color: .orange) {
                                guard !play.solved else { return }
                                if play.count == current.beats { play.win(current.success) }
                                else { play.count = 0; play.say(current.retry) }
                            }
                            ToddlerActionButton(title: "Start the beats again", systemImage: "arrow.counterclockwise", color: .orange) {
                                guard !play.solved else { return }
                                play.count = 0
                                play.feedback = ""
                                narrator.stop()
                            }
                        }.disabled(play.solved)
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

    private func nextWord() {
        let recent = recentWords.split(separator: "|").map(String.init)
        let item = HopWord.next(recent: recent)
        recentWords = (recent + [item.word]).suffix(20).joined(separator: "|")
        play.replay()
        current = item
    }
}
