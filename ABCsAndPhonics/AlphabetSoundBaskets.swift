import SwiftUI

struct SoundBasketItem: Identifiable {
    let letter: String
    let word: String
    let asset: String?
    var id: String { letter }

    static let alphabet: [SoundBasketItem] = [
        .init(letter: "A", word: "apple", asset: "AppleClean"),
        .init(letter: "B", word: "basketball", asset: "basketball"),
        .init(letter: "C", word: "cat", asset: "cat"),
        .init(letter: "D", word: "dog", asset: "dog"),
        .init(letter: "E", word: "egg", asset: "Egg"),
        .init(letter: "F", word: "fish", asset: "Fish"),
        .init(letter: "G", word: "goat", asset: "goat"),
        .init(letter: "H", word: "horse", asset: "horse"),
        .init(letter: "I", word: "ice cream", asset: nil),
        .init(letter: "J", word: "jellyfish", asset: "jellyfish"),
        .init(letter: "K", word: "kiwi", asset: "Kiwi"),
        .init(letter: "L", word: "lemon", asset: "Lemon"),
        .init(letter: "M", word: "moon", asset: "Moon"),
        .init(letter: "N", word: "noodles", asset: "Noodles"),
        .init(letter: "O", word: "orange", asset: "Orange"),
        .init(letter: "P", word: "pig", asset: "pig"),
        .init(letter: "Q", word: "quilt", asset: nil),
        .init(letter: "R", word: "rabbit", asset: "rabbit"),
        .init(letter: "S", word: "sun", asset: "Sun"),
        .init(letter: "T", word: "turtle", asset: "turtle"),
        .init(letter: "U", word: "umbrella", asset: nil),
        .init(letter: "V", word: "volleyball", asset: "volleyball"),
        .init(letter: "W", word: "whale", asset: "whale"),
        .init(letter: "X", word: "x-ray", asset: nil),
        .init(letter: "Y", word: "yogurt", asset: "Yogurt"),
        .init(letter: "Z", word: "zucchini", asset: "Zucchini")
    ]

    var prompt: String { "This is \(word). Tap each basket to hear its letter. Drag the picture to the letter that starts \(word)." }
    var success: String { "You matched \(word)! \(word.capitalized) starts with the letter \(letter)." }
}

struct SoundBasketRound {
    let item: SoundBasketItem
    let choices: [String]
    let dragID = UUID().uuidString

    static func session(previousStart: String, lastShown: String) -> [SoundBasketRound] {
        LetterDrawAlphabet.shuffled(startingAfter: previousStart, lastShown: lastShown).map { letter in
            let item = SoundBasketItem.alphabet.first { $0.letter == letter }!
            let other = LetterDrawAlphabet.letters.filter { $0 != letter }.randomElement()!
            return SoundBasketRound(item: item, choices: [letter, other].shuffled())
        }
    }

    func matches(_ draggedIDs: [String], basket: String) -> Bool {
        draggedIDs == [dragID] && basket == item.letter
    }
}

struct LiteracySoundBasketsGame: View {
    @StateObject private var play = LiteracyPlay(total: 26)
    @AppStorage("soundBaskets.previousStartingLetter") private var previousStart = ""
    @AppStorage("soundBaskets.lastShownLetter") private var lastShown = ""
    @State private var rounds: [SoundBasketRound] = []
    @State private var highlighted: String?
    @State private var dragOffset = CGSize.zero
    @GestureState private var dragging = false

    var body: some View {
        VStack(spacing: 0) {
            if rounds.indices.contains(play.round) {
                let round = rounds[play.round]
                LiteracyStage(title: "Sound Baskets", prompt: round.item.prompt, play: play,
                              onReplay: restart, progressLabel: "Letter", nextLabel: "Next letter") {
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        ZStack(alignment: .topLeading) {
                            ForEach(Array(round.choices.enumerated()), id: \.element) { index, letter in
                                let frame = SoundBasketDropLayout.frame(index: index, width: width)
                                basket(letter, round: round).frame(width: frame.width, height: frame.height)
                                    .position(x: frame.midX, y: frame.midY)
                            }
                            Text(round.item.word.capitalized).font(.title2.bold())
                                .frame(width: width).position(x: width / 2, y: 147)
                            SoundBasketPicture(item: round.item).frame(width: 120, height: 120)
                                .padding(8).contentShape(Rectangle())
                                .highPriorityGesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("sound-basket-board"))
                                    .updating($dragging) { _, active, _ in active = true }
                                    .onChanged { value in
                                        guard !play.solved else { return }
                                        dragOffset = value.translation
                                        highlighted = SoundBasketDropLayout.target(at: value.location, width: width).map { round.choices[$0] }
                                    }.onEnded { value in
                                        dragOffset = .zero; highlighted = nil
                                        if let index = SoundBasketDropLayout.target(at: value.location, width: width) {
                                            _ = drop([round.dragID], into: round.choices[index], round: round)
                                        }
                                    })
                                .offset(dragOffset).position(x: width / 2, y: 68)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("Picture of \(round.item.word)")
                                .accessibilityIdentifier("sound-baskets.picture")
                                .accessibilityHint("Drag straight to a basket. Or use the Place in basket accessibility actions.")
                                .accessibilityAction(named: Text("Place in \(round.choices[0]) basket")) { _ = drop([round.dragID], into: round.choices[0], round: round) }
                                .accessibilityAction(named: Text("Place in \(round.choices[1]) basket")) { _ = drop([round.dragID], into: round.choices[1], round: round) }
                        }.coordinateSpace(name: "sound-basket-board")
                    }.frame(height: 345).id(round.dragID)
                }.scrollDisabled(dragging)
            }
        }
        .onChange(of: dragging) { _, active in if !active { dragOffset = .zero; highlighted = nil } }
        .onAppear(perform: restart)
        .onChange(of: play.round) { _, index in
            highlighted = nil; dragOffset = .zero
            if rounds.indices.contains(index) { lastShown = rounds[index].item.letter }
        }
    }

    private func basket(_ letter: String, round: SoundBasketRound) -> some View {
        Button {
            play.say("Words that start with the letter \(letter).")
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Image(systemName: "basket.fill")
                        .resizable().scaledToFit()
                        .foregroundStyle(Color.orange.opacity(0.65))
                    Text(letter).font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.top, 25)
                }.frame(height: 115)
                Label("Hear letter", systemImage: "speaker.wave.2.fill").font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            .padding(12)
            .background(highlighted == letter ? Color.orange.opacity(0.3) : .white, in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(.orange, lineWidth: highlighted == letter ? 4 : 2))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Letter \(letter) basket")
        .accessibilityIdentifier("sound-baskets.basket.\(letter)")
        .accessibilityHint("Tap to hear the letter. Drop the matching picture here.")
        .dropDestination(for: String.self) { items, _ in
            drop(items, into: letter, round: round)
        } isTargeted: { targeted in
            if targeted { highlighted = letter }
            else if highlighted == letter { highlighted = nil }
        }
    }

    private func drop(_ items: [String], into letter: String, round: SoundBasketRound) -> Bool {
        guard !play.solved, !play.complete, rounds.indices.contains(play.round),
              rounds[play.round].dragID == round.dragID, items == [round.dragID] else { return false }
        highlighted = nil
        if round.matches(items, basket: letter) { play.win(round.item.success) }
        else { play.say("Let's try the other basket. Tap its letter and listen.") }
        return true
    }

    private func restart() {
        rounds = SoundBasketRound.session(previousStart: previousStart, lastShown: lastShown)
        previousStart = rounds[0].item.letter
        lastShown = previousStart
        highlighted = nil
        play.replay()
    }
}

enum SoundBasketDropLayout {
    static func frame(index: Int, width: CGFloat) -> CGRect {
        let basketWidth = (width - 16) / 2
        return CGRect(x: CGFloat(index) * (basketWidth + 16), y: 175, width: basketWidth, height: 165)
    }
    static func target(at point: CGPoint, width: CGFloat) -> Int? {
        (0..<2).filter { frame(index: $0, width: width).insetBy(dx: -8, dy: -12).contains(point) }
            .min { abs(frame(index: $0, width: width).midX - point.x) < abs(frame(index: $1, width: width).midX - point.x) }
    }
}

/// Clean cutouts and native pictures keep every object free of baked-in backgrounds.
struct SoundBasketPicture: View {
    let item: SoundBasketItem
    static let cleanAssets = ["C": "FamilyClean/cat", "D": "FamilyClean/dog", "G": "BarnClean/goat", "H": "FamilyClean/horse", "J": "OceanClean/jellyfish", "M": "SpaceClean/Moon", "P": "BarnClean/pig", "R": "BarnClean/rabbit", "S": "SpaceClean/Sun", "W": "OceanClean/whale"]
    static let foodLetters: Set<String> = ["A", "E", "K", "L", "N", "O", "Y", "Z"]
    var body: some View {
        GeometryReader { geometry in
            content.frame(width: 130, height: 130)
                .scaleEffect(min(geometry.size.width, geometry.size.height) / 130)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }.accessibilityElement(children: .ignore)
    }
    @ViewBuilder private var content: some View {
        if let asset = Self.cleanAssets[item.letter] {
            Image(asset).resizable().scaledToFit()
        } else if Self.foodLetters.contains(item.letter) {
            LiteracyFoodArt(food: item.word)
        } else if item.letter == "B" || item.letter == "V" {
            Image(systemName: item.letter == "B" ? "basketball.fill" : "volleyball.fill")
                .resizable().scaledToFit().foregroundStyle(item.letter == "B" ? .orange : .blue)
        } else if item.letter == "F" {
            HuntItemArt(item: HuntItem.named("fish"))
        } else if item.letter == "T" {
            Image(systemName: "tortoise.fill").resizable().scaledToFit().foregroundStyle(.green)
        } else {
            switch item.letter {
            case "I":
                ZStack {
                    Path { p in
                        p.move(to: CGPoint(x: 35, y: 55)); p.addLine(to: CGPoint(x: 95, y: 55))
                        p.addLine(to: CGPoint(x: 65, y: 128)); p.closeSubpath()
                    }.fill(Color.orange.opacity(0.7))
                    Circle().fill(.pink).frame(width: 70, height: 70).offset(y: -25)
                    Circle().fill(.red).frame(width: 15, height: 15).offset(y: -57)
                }
            case "Q":
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3), spacing: 3) {
                    ForEach(0..<9) { index in
                        RoundedRectangle(cornerRadius: 3).fill([Color.orange, .teal, .pink][index % 3])
                            .overlay(Image(systemName: index.isMultiple(of: 2) ? "star.fill" : "heart.fill").foregroundStyle(.white))
                            .frame(height: 34)
                    }
                }.padding(6).background(.indigo, in: RoundedRectangle(cornerRadius: 8))
            case "U":
                Image(systemName: "umbrella.fill").resizable().scaledToFit().foregroundStyle(.purple)
            default:
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.12, green: 0.24, blue: 0.36))
                    RoundedRectangle(cornerRadius: 4).fill(.white).frame(width: 8, height: 90)
                    VStack(spacing: 8) {
                        ForEach(0..<5) { index in
                            Capsule().stroke(.white.opacity(0.9), lineWidth: 5)
                                .frame(width: CGFloat(85 - index * 7), height: 12)
                        }
                    }
                }.padding(5)
            }
        }
    }
}
