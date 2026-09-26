import SwiftUI

struct GardenRhyme {
    let word: String
    let asset: String
    let picture: String
    let rhyme: String
    let rhymePicture: String
    var success: String { "\(word) and \(rhyme) rhyme! Their endings sound alike." }
    var retry: String { "Say these together: \(word), \(rhyme). Listen to their matching endings." }

    static let bank: [GardenRhyme] = [
        .init(word: "cat", asset: "cat", picture: "🐱", rhyme: "hat", rhymePicture: "🎩"),
        .init(word: "goat", asset: "goat", picture: "🐐", rhyme: "boat", rhymePicture: "⛵"),
        .init(word: "mouse", asset: "mouse", picture: "🐭", rhyme: "house", rhymePicture: "🏠"),
        .init(word: "dog", asset: "dog", picture: "🐶", rhyme: "log", rhymePicture: "🪵"),
        .init(word: "sun", asset: "Sun", picture: "☀️", rhyme: "bun", rhymePicture: "🥯"),
        .init(word: "pig", asset: "pig", picture: "🐷", rhyme: "wig", rhymePicture: "👩‍🦱"),
        .init(word: "hen", asset: "hen", picture: "🐔", rhyme: "pen", rhymePicture: "🖊️"),
        .init(word: "duck", asset: "duck", picture: "🦆", rhyme: "truck", rhymePicture: "🚚"),
        .init(word: "fish", asset: "Fish", picture: "🐟", rhyme: "dish", rhymePicture: "🍽️"),
        .init(word: "moon", asset: "Moon", picture: "🌙", rhyme: "spoon", rhymePicture: "🥄"),
        .init(word: "pear", asset: "Pear", picture: "🍐", rhyme: "bear", rhymePicture: "🐻"),
        .init(word: "corn", asset: "Corn", picture: "🌽", rhyme: "horn", rhymePicture: "📯"),
        .init(word: "seal", asset: "seal", picture: "🦭", rhyme: "wheel", rhymePicture: "🛞"),
        .init(word: "star", asset: "Star", picture: "⭐", rhyme: "car", rhymePicture: "🚗"),
        .init(word: "rice", asset: "Rice", picture: "🍚", rhyme: "mice", rhymePicture: "🐁🐁"),
        .init(word: "peas", asset: "Peas", picture: "🫛", rhyme: "cheese", rhymePicture: "🧀"),
        .init(word: "grape", asset: "Grape", picture: "🍇", rhyme: "cape", rhymePicture: "🦸"),
        .init(word: "peach", asset: "Peach", picture: "🍑", rhyme: "beach", rhymePicture: "🏖️"),
        .init(word: "bread", asset: "Bread", picture: "🍞", rhyme: "bed", rhymePicture: "🛏️"),
        .init(word: "sheep", asset: "sheep", picture: "🐑", rhyme: "jeep", rhymePicture: "🚙"),
        .init(word: "whale", asset: "whale", picture: "🐳", rhyme: "snail", rhymePicture: "🐌"),
        .init(word: "crab", asset: "crab", picture: "🦀", rhyme: "cab", rhymePicture: "🚕"),
        .init(word: "clam", asset: "clam", picture: "🦪", rhyme: "jam", rhymePicture: "🫙"),
        .init(word: "lime", asset: "Lime", picture: "🍋‍🟩", rhyme: "time", rhymePicture: "🕰️"),
        .init(word: "plum", asset: "Plum", picture: "🟣", rhyme: "drum", rhymePicture: "🥁"),
        .init(word: "toast", asset: "Toast", picture: "🍞", rhyme: "ghost", rhymePicture: "👻"),
        .init(word: "shark", asset: "shark", picture: "🦈", rhyme: "park", rhymePicture: "🏞️"),
        .init(word: "chick", asset: "chick", picture: "🐥", rhyme: "brick", rhymePicture: "🧱"),
        .init(word: "goose", asset: "goose", picture: "🪿", rhyme: "moose", rhymePicture: "🫎"),
        .init(word: "beef", asset: "Beef", picture: "🥩", rhyme: "leaf", rhymePicture: "🍃"),
    ]
}

struct GardenRhymeChoice: Identifiable {
    let word: String
    let picture: String
    var id: String { word }
}

struct GardenRhymeRound {
    let pair: GardenRhyme
    let choices: [GardenRhymeChoice]
    var prompt: String { "Listen for words with the same ending. \(pair.word), \(choices[0].word). \(pair.word), \(choices[1].word). Which pair rhymes?" }

    static func make(pair: GardenRhyme) -> GardenRhymeRound {
        // Offset reviewed against the word bank so the other choice cannot rhyme.
        let index = GardenRhyme.bank.firstIndex { $0.word == pair.word }!
        let other = GardenRhyme.bank[(index + 11) % GardenRhyme.bank.count]
        return GardenRhymeRound(pair: pair, choices: [
            GardenRhymeChoice(word: pair.rhyme, picture: pair.rhymePicture),
            GardenRhymeChoice(word: other.word, picture: other.picture)
        ].shuffled())
    }

    static func next(recent: [String]) -> GardenRhymeRound {
        let excluded = Set(recent.suffix(20))
        return make(pair: GardenRhyme.bank.filter { !excluded.contains($0.word) }.randomElement()!)
    }
}

struct RhymeGardenGame: View {
    @StateObject private var play = LiteracyPlay()
    @StateObject private var narrator = GameNarrator()
    @AppStorage("rhymeGarden.recentPairs") private var recentPairs = ""
    @State private var current: GardenRhymeRound?

    var body: some View {
        VStack(spacing: 0) {
            if let current {
                ToddlerGameScaffold(title: "Rhyme Garden", prompt: current.prompt, accent: .orange) {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            LiteracyVocabularyArt(word: current.pair.word).frame(width: 96, height: 96)
                            Text(current.pair.word).font(.title.bold())
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(current.pair.word)
                        .accessibilityIdentifier("rhyme-garden.target")
                        HStack(spacing: 14) {
                            ForEach(current.choices) { choice in
                                Button {
                                    guard !play.solved else { return }
                                    if choice.word == current.pair.rhyme { play.win(current.pair.success) }
                                    else { play.say(current.pair.retry) }
                                } label: {
                                    VStack(spacing: 8) {
                                        Text(choice.picture).font(.system(size: 60)).accessibilityHidden(true)
                                        Text(choice.word).font(.title3.bold())
                                        Image(systemName: "camera.macro")
                                            .font(.largeTitle).foregroundStyle(play.solved && choice.word == current.pair.rhyme ? .green : .orange)
                                    }.frame(maxWidth: .infinity, minHeight: 170).padding(10)
                                        .background(.white, in: RoundedRectangle(cornerRadius: 20))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("\(current.pair.word) and \(choice.word)")
                                .accessibilityIdentifier("rhyme-garden.choice.\(choice.word)")
                                .disabled(play.solved)
                            }
                        }
                        if !play.feedback.isEmpty {
                            Text(play.feedback).font(.title3.weight(.semibold)).multilineTextAlignment(.center)
                        }
                        if play.solved {
                            ToddlerActionButton(title: "Next rhyme", systemImage: "arrow.right.circle.fill", color: .orange, action: nextPair)
                        }
                    }
                }
            }
        }
        .onAppear { if current == nil { nextPair() } }
        .onDisappear { current = nil; narrator.stop() }
        .onChange(of: play.feedbackRevision) { _, _ in
            if !play.feedback.isEmpty { narrator.speak(play.feedback) }
        }
    }

    private func nextPair() {
        let recent = recentPairs.split(separator: "|").map(String.init)
        let round = GardenRhymeRound.next(recent: recent)
        recentPairs = (recent + [round.pair.word]).suffix(20).joined(separator: "|")
        play.replay()
        current = round
    }
}
