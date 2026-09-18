import SwiftUI

struct BeginningSoundsPair {
    let letter: String
    let word: String
    let asset: String?
    let matchingWord: String
    let matchingAsset: String?

    // Match the spoken beginning as well as the written letter: ice cream/ice
    // cube use long I, and orange/orca both begin with "or". X uses x-ray names.
    static let alphabet: [BeginningSoundsPair] = [
        .init(letter: "A", word: "apple", asset: "AppleClean", matchingWord: "alpaca", matchingAsset: "alpaca"),
        .init(letter: "B", word: "basketball", asset: "basketball", matchingWord: "broccoli", matchingAsset: "Broccoli"),
        .init(letter: "C", word: "cat", asset: "cat", matchingWord: "cow", matchingAsset: "cow"),
        .init(letter: "D", word: "dog", asset: "dog", matchingWord: "duck", matchingAsset: "duck"),
        .init(letter: "E", word: "egg", asset: "Egg", matchingWord: "excavator", matchingAsset: "excavator"),
        .init(letter: "F", word: "fish", asset: "Fish", matchingWord: "football", matchingAsset: "football"),
        .init(letter: "G", word: "goat", asset: "goat", matchingWord: "grape", matchingAsset: "Grape"),
        .init(letter: "H", word: "horse", asset: "horse", matchingWord: "hamburger", matchingAsset: "Hamburger"),
        .init(letter: "I", word: "ice cream", asset: nil, matchingWord: "ice cube", matchingAsset: nil),
        .init(letter: "J", word: "jellyfish", asset: "jellyfish", matchingWord: "jam", matchingAsset: "Jam"),
        .init(letter: "K", word: "kiwi", asset: "Kiwi", matchingWord: "krill", matchingAsset: "krill"),
        .init(letter: "L", word: "lemon", asset: "Lemon", matchingWord: "lobster", matchingAsset: "lobster"),
        .init(letter: "M", word: "moon", asset: "Moon", matchingWord: "milk", matchingAsset: "Milk"),
        .init(letter: "N", word: "noodles", asset: "Noodles", matchingWord: "nest", matchingAsset: nil),
        .init(letter: "O", word: "orange", asset: "Orange", matchingWord: "orca", matchingAsset: "orca"),
        .init(letter: "P", word: "pig", asset: "pig", matchingWord: "pizza", matchingAsset: "Pizza"),
        .init(letter: "Q", word: "quilt", asset: nil, matchingWord: "queen", matchingAsset: nil),
        .init(letter: "R", word: "rabbit", asset: "rabbit", matchingWord: "rooster", matchingAsset: "rooster"),
        .init(letter: "S", word: "sun", asset: "Sun", matchingWord: "soup", matchingAsset: "Soup"),
        .init(letter: "T", word: "turtle", asset: "turtle", matchingWord: "tomato", matchingAsset: "tomato"),
        .init(letter: "U", word: "umbrella", asset: nil, matchingWord: "undershirt", matchingAsset: nil),
        .init(letter: "V", word: "volleyball", asset: "volleyball", matchingWord: "volcano", matchingAsset: "Volcano"),
        .init(letter: "W", word: "watermelon", asset: "Watermelon", matchingWord: "walrus", matchingAsset: "walrus"),
        .init(letter: "X", word: "x-ray", asset: nil, matchingWord: "x-ray hand", matchingAsset: nil),
        .init(letter: "Y", word: "yogurt", asset: "Yogurt", matchingWord: "yellow truck", matchingAsset: "truckYellow"),
        .init(letter: "Z", word: "zucchini", asset: "Zucchini", matchingWord: "zipper", matchingAsset: nil)
    ]

    var success: String { "\(word) and \(matchingWord) start with the same sound. Say them together!" }
    var retry: String { "Listen with your grown-up: \(word), \(matchingWord). Those words start alike." }
}

struct BeginningSoundsChoice: Identifiable {
    let word: String
    let asset: String?
    var id: String { word }
}

struct BeginningSoundsSessionRound {
    let pair: BeginningSoundsPair
    let choices: [BeginningSoundsChoice]
    var prompt: String { "Say \(pair.word). Which word starts the same way: \(choices[0].word) or \(choices[1].word)?" }

    static func session(previousStart: String, lastShown: String) -> [BeginningSoundsSessionRound] {
        LetterDrawAlphabet.shuffled(startingAfter: previousStart, lastShown: lastShown).map { letter in
            let pair = BeginningSoundsPair.alphabet.first { $0.letter == letter }!
            // A different distractor for each target prevents learning a fixed
            // "always avoid this picture" shortcut instead of listening.
            let index = BeginningSoundsPair.alphabet.firstIndex { $0.letter == letter }!
            let other = BeginningSoundsPair.alphabet[(index + 7) % BeginningSoundsPair.alphabet.count]
            let distractor = BeginningSoundsChoice(word: other.word, asset: other.asset)
            return BeginningSoundsSessionRound(pair: pair, choices: [
                BeginningSoundsChoice(word: pair.matchingWord, asset: pair.matchingAsset), distractor
            ].shuffled())
        }
    }
}

struct ListeningBeginningsGame: View {
    @StateObject private var play = LiteracyPlay(total: 26)
    @AppStorage("beginningSounds.previousStartingLetter") private var previousStart = ""
    @AppStorage("beginningSounds.lastShownLetter") private var lastShown = ""
    @State private var rounds: [BeginningSoundsSessionRound] = []

    var body: some View {
        VStack(spacing: 0) {
            if rounds.indices.contains(play.round) {
                let round = rounds[play.round]
                LiteracyStage(title: "Beginning Sounds", prompt: round.prompt, play: play,
                              onReplay: restart, progressLabel: "Letter", nextLabel: "Next letter") {
                    VStack(spacing: 22) {
                        picture(word: round.pair.word, asset: round.pair.asset, letter: round.pair.letter)
                            .accessibilityIdentifier("beginning-sounds.target")
                        HStack(spacing: 14) {
                            ForEach(round.choices) { choice in
                                Button {
                                    if choice.word == round.pair.matchingWord { play.win(round.pair.success) }
                                    else { play.say(round.pair.retry) }
                                } label: {
                                    picture(word: choice.word, asset: choice.asset, letter: String(choice.word.prefix(1)).uppercased())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(choice.word)
                                .accessibilityIdentifier("beginning-sounds.choice.\(choice.word)")
                            }
                        }
                    }
                }
            }
        }
        .onAppear { if rounds.isEmpty { restart() } }
        .onDisappear { rounds = [] }
        .onChange(of: play.round) { _, index in
            if rounds.indices.contains(index) { lastShown = rounds[index].pair.letter }
        }
    }

    private func picture(word: String, asset: String?, letter: String) -> some View {
        VStack(spacing: 8) {
            BeginningSoundsArt(word: word, asset: asset, letter: letter)
                .frame(width: 96, height: 96)
            Text(word.capitalized).font(.title3.bold()).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 145)
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.orange.opacity(0.4), lineWidth: 2))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(word)
    }

    private func restart() {
        rounds = BeginningSoundsSessionRound.session(previousStart: previousStart, lastShown: lastShown)
        previousStart = rounds[0].pair.letter
        lastShown = previousStart
        play.replay()
    }
}

struct BeginningSoundsArt: View {
    let word: String
    let asset: String?
    let letter: String

    var body: some View {
        if let asset {
            ToddlerArt(asset: asset, size: 96)
        } else {
            switch word {
            case "ice cube":
                RoundedRectangle(cornerRadius: 18).fill(.cyan.opacity(0.45))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.blue, lineWidth: 3))
                    .overlay(Image(systemName: "sparkles").font(.system(size: 42)).foregroundStyle(.white))
                    .padding(10).rotationEffect(.degrees(-8))
            case "nest":
                ZStack {
                    Ellipse().fill(.brown).frame(width: 94, height: 50).offset(y: 15)
                    HStack(spacing: -5) {
                        ForEach(0..<3) { _ in Ellipse().fill(Color(red: 0.75, green: 0.9, blue: 0.94)).frame(width: 26, height: 36) }
                    }
                    ForEach(0..<4) { index in
                        Capsule().fill(.orange.opacity(0.6)).frame(width: 82, height: 4)
                            .rotationEffect(.degrees(index.isMultiple(of: 2) ? 12 : -12)).offset(y: CGFloat(15 + index * 5))
                    }
                }
            case "queen":
                ZStack {
                    Ellipse().fill(.brown).frame(width: 65, height: 78).offset(y: 9)
                    Circle().fill(Color(red: 0.85, green: 0.61, blue: 0.43)).frame(width: 49).offset(y: 10)
                    HStack(spacing: 15) { Circle().frame(width: 5); Circle().frame(width: 5) }.offset(y: 5)
                    Image(systemName: "crown.fill").font(.system(size: 48)).foregroundStyle(.yellow).offset(y: -27)
                    Capsule().fill(.brown).frame(width: 13, height: 3).offset(y: 22)
                }
            case "undershirt":
                Image(systemName: "tshirt.fill").resizable().scaledToFit().foregroundStyle(.teal).padding(6)
            case "x-ray hand":
                RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.12, green: 0.24, blue: 0.36))
                    .overlay(Image(systemName: "hand.raised.fill").resizable().scaledToFit().foregroundStyle(.white.opacity(0.9)).padding(15))
            case "zipper":
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(.indigo).frame(width: 58)
                    Rectangle().fill(.gray).frame(width: 5)
                    VStack(spacing: 4) {
                        ForEach(0..<9) { index in
                            Rectangle().fill(.white).frame(width: 24, height: 4).offset(x: index.isMultiple(of: 2) ? -4 : 4)
                        }
                    }
                    RoundedRectangle(cornerRadius: 4).fill(.orange).frame(width: 20, height: 27).offset(y: -22)
                }.padding(4)
            default:
                SoundBasketPicture(item: .init(letter: letter, word: word, asset: nil))
                    .frame(width: 130, height: 130).scaleEffect(96.0 / 130.0)
                    .frame(width: 96, height: 96)
            }
        }
    }
}
