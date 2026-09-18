import SwiftUI
import Combine

/// No delayed state mutations: every successful round waits for a child's Next tap.
@MainActor
final class LiteracyPlay: ObservableObject {
    @Published var round = 0
    @Published var count = 0
    @Published var marked: Set<Int> = []
    @Published var selected: Int?
    @Published var revealed = false
    @Published var solved = false
    @Published var complete = false
    @Published var feedback = ""
    @Published private(set) var feedbackRevision = 0
    let total: Int

    init(total: Int = 3) {
        precondition(total > 0)
        self.total = total
    }

    // No actor-bound cleanup is needed. Avoid an executor hop during teardown.
    nonisolated deinit {}

    func say(_ text: String) { guard !complete else { return }; feedback = text; feedbackRevision += 1 }
    func win(_ text: String) { guard !complete else { return }; solved = true; say(text) }
    func advance() {
        guard solved, !complete else { return }
        if round + 1 == total { complete = true; return }
        round += 1; clear()
    }
    func replay() { round = 0; complete = false; clear() }
    private func clear() { count = 0; marked = []; selected = nil; revealed = false; solved = false; feedback = "" }
}

struct LiteracyStage<Content: View>: View {
    let title: String
    let prompt: String
    @ObservedObject var play: LiteracyPlay
    var onReplay: (() -> Void)? = nil
    var progressLabel = "Adventure"
    var nextLabel = "Next adventure"
    @ViewBuilder var content: () -> Content
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ToddlerGameScaffold(title: title, prompt: prompt, accent: .orange, completion: play.complete, onReplay: onReplay ?? play.replay) {
            VStack(spacing: 20) {
                Text("\(progressLabel) \(play.round + 1) of \(play.total)").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                content().disabled(play.solved)
                if !play.feedback.isEmpty {
                    Text(play.feedback).font(.title3.weight(.semibold)).multilineTextAlignment(.center).foregroundStyle(Color.brown)
                }
                if play.solved {
                    ToddlerActionButton(title: play.round + 1 == play.total ? "All done" : nextLabel, systemImage: "arrow.right.circle.fill", color: .orange, action: play.advance)
                }
            }
        }
        .onChange(of: play.feedbackRevision) { _, _ in
            if !play.feedback.isEmpty { narrator.speak(play.feedback) }
        }
        .onDisappear { narrator.stop() }
    }
}

private struct LiteracyPicture: Identifiable {
    let word: String
    let asset: String
    var id: String { word }
}

private struct WordPictureCard: View {
    let word: String
    let asset: String
    var selected = false
    var body: some View {
        VStack(spacing: 8) {
            ToddlerArt(asset: asset, size: 80)
            Text(word).font(.title3.weight(.bold)).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 132)
        .padding(10)
        .background(selected ? Color.orange.opacity(0.2) : Color.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.orange.opacity(0.45), lineWidth: selected ? 4 : 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(word)
    }
}

private struct LiteracyLetterButton: View {
    let letter: String
    var selected = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(letter).font(.system(size: 46, weight: .bold, design: .rounded))
                .foregroundStyle(.brown)
                .frame(maxWidth: .infinity, minHeight: 92)
                .background(selected ? Color.orange.opacity(0.25) : Color.white, in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.orange.opacity(0.5), lineWidth: 2))
        }.buttonStyle(.plain).accessibilityLabel("Letter \(letter)")
            .accessibilityValue(selected ? "Selected" : "")
    }
}

struct LetterTwinsRound {
    let letter: String
    let choices: [String]

    static func session(previousStart: String, lastShown: String) -> [LetterTwinsRound] {
        LetterDrawAlphabet.shuffled(startingAfter: previousStart, lastShown: lastShown).map { letter in
            let other = LetterDrawAlphabet.letters.filter { $0 != letter }.randomElement()!
            return LetterTwinsRound(letter: letter, choices: [letter, other].shuffled())
        }
    }
}

struct LetterTwinsGame: View {
    @StateObject private var play = LiteracyPlay(total: 26)
    @AppStorage("letterTwins.previousStartingLetter") private var previousStart = ""
    @AppStorage("letterTwins.lastShownLetter") private var lastShown = ""
    @State private var rounds: [LetterTwinsRound] = []

    var body: some View {
        VStack(spacing: 0) {
            if rounds.indices.contains(play.round) {
                let round = rounds[play.round]
                LiteracyStage(title: "Letter Twins", prompt: "This is \(round.letter). Find the letter that looks just like it.", play: play,
                              onReplay: restart, progressLabel: "Letter", nextLabel: "Next letter") {
                    VStack(spacing: 26) {
                        Text(round.letter).font(.system(size: 100, weight: .bold, design: .rounded)).foregroundStyle(.brown)
                            .frame(width: 150, height: 160).background(Color.orange.opacity(0.18), in: RoundedRectangle(cornerRadius: 28))
                            .accessibilityLabel("Find letter \(round.letter)")
                            .accessibilityIdentifier("letter-twins.target")
                        HStack(spacing: 18) {
                            ForEach(round.choices, id: \.self) { choice in
                                LiteracyLetterButton(letter: choice) {
                                    if choice == round.letter { play.win("Two matching letters. They are both \(round.letter)!") }
                                    else { play.say("Look at the lines and curves. Find the same shape.") }
                                }
                                .accessibilityIdentifier("letter-twins.choice.\(choice)")
                            }
                        }
                    }
                }
            }
        }
        .onAppear { if rounds.isEmpty { restart() } }
        .onDisappear { rounds = [] }
        .onChange(of: play.round) { _, index in
            if rounds.indices.contains(index) { lastShown = rounds[index].letter }
        }
    }

    private func restart() {
        rounds = LetterTwinsRound.session(previousStart: previousStart, lastShown: lastShown)
        previousStart = rounds[0].letter
        lastShown = previousStart
        play.replay()
    }
}

struct LiteracyVehiclePeekabooGame: View {
    @StateObject private var play = LiteracyPlay()
    private let vehicles = [LiteracyPicture(word: "fire truck", asset: "firetruck"), .init(word: "tractor", asset: "tractor"), .init(word: "car", asset: "carBlue")]
    private var target: Int { [0, 2, 1][play.round] }
    private var clue: String { ["I help firefighters. Find the fire truck.", "A family can ride in me. Find the car.", "I help on a farm. Find the tractor."][play.round] }
    var body: some View {
        LiteracyStage(title: "Vehicle Peekaboo", prompt: clue + " Tap a garage to open it.", play: play) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 126))], spacing: 14) {
                ForEach(Array(vehicles.enumerated()), id: \.element.id) { index, vehicle in
                    Button {
                        play.selected = index
                        if index == target { play.win("Peekaboo! You found the \(vehicle.word).") }
                        else { play.say("This is a \(vehicle.word). Let's look for the \(vehicles[target].word).") }
                    } label: {
                        VStack(spacing: 8) {
                            // A small picture clue keeps this a listening game rather than a random guess.
                            ToddlerArt(asset: vehicle.asset, size: play.selected == index ? 100 : 56)
                            if play.selected != index { Image(systemName: "door.garage.closed").font(.system(size: 45)).foregroundStyle(.orange) }
                            Text(vehicle.word).font(.headline)
                        }.frame(maxWidth: .infinity, minHeight: 170).padding(8).background(.white, in: RoundedRectangle(cornerRadius: 22))
                    }.buttonStyle(.plain).accessibilityLabel("Open the \(vehicle.word) garage")
                }
            }
        }
    }
}

struct PicnicWordsGame: View {
    @StateObject private var play = LiteracyPlay()
    private let foods = [LiteracyPicture(word: "apple", asset: "Apple"), .init(word: "milk", asset: "Milk"), .init(word: "sandwich", asset: "Sandwich"), .init(word: "orange", asset: "Orange")]
    private var list: [Int] { [[0, 2], [3, 1], [2, 3]][play.round] }
    private var displayed: Int { play.selected ?? 1 }
    private var current: LiteracyPicture { foods[displayed] }
    var body: some View {
        LiteracyStage(title: "Picnic Words", prompt: "Pack \(foods[list[0]].word), then \(foods[list[1]].word). Use the arrows to look through the foods.", play: play) {
            VStack(spacing: 18) {
                HStack {
                    ForEach(0..<2, id: \.self) { index in
                        VStack {
                            if index < play.count { ToddlerArt(asset: foods[list[index]].asset, size: 58) }
                            else { Image(systemName: "basket").font(.system(size: 38)).frame(height: 58) }
                            Text(index < play.count ? "Packed" : "Item \(index + 1)").font(.headline)
                        }.frame(maxWidth: .infinity).accessibilityLabel(index < play.count ? "\(foods[list[index]].word) packed" : "Picnic item \(index + 1), empty")
                    }
                }
                WordPictureCard(word: current.word, asset: current.asset)
                HStack {
                    ToddlerActionButton(title: "Previous", systemImage: "arrow.left.circle.fill", color: .orange) { browse(-1) }
                    ToddlerActionButton(title: "Next food", systemImage: "arrow.right.circle.fill", color: .orange) { browse(1) }
                }
                ToddlerActionButton(title: "Pack this food", systemImage: "basket.fill", color: .orange) {
                    if displayed == list[min(play.count, 1)] {
                        play.count += 1
                        if play.count == 2 { play.win("Your picnic is packed! Say the two food names together.") }
                        else { play.say("Packed \(current.word). Now find \(foods[list[1]].word).") }
                    } else { play.say("This is \(current.word). Look for \(foods[list[min(play.count, 1)]].word).") }
                }
            }
        }
    }
    private func browse(_ step: Int) {
        play.selected = (displayed + step + foods.count) % foods.count
        play.say(foods[displayed].word)
    }
}

struct LiteracyWordClawGame: View {
    @StateObject private var play = LiteracyPlay()
    private let toys = [LiteracyPicture(word: "ball", asset: "basketball"), .init(word: "car", asset: "carBlue"), .init(word: "rabbit", asset: "rabbit")]
    private var target: Int { [1, 0, 2][play.round] }
    var body: some View {
        LiteracyStage(title: "Word Claw", prompt: "Let's pick up the \(toys[target].word). Tap it to aim the claw. Then lower the claw.", play: play) {
            VStack(spacing: 20) {
                Image(systemName: "hand.point.down.fill").font(.system(size: 70)).foregroundStyle(.orange)
                    .accessibilityHidden(true)
                Text(play.selected.map { "Claw aimed at \(toys[$0].word)" } ?? "Choose where the claw goes")
                    .font(.headline).multilineTextAlignment(.center)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 12) {
                    ForEach(Array(toys.enumerated()), id: \.element.id) { index, toy in
                        Button { play.selected = index; play.say("Claw over the \(toy.word).") } label: {
                            WordPictureCard(word: toy.word, asset: toy.asset, selected: play.selected == index)
                        }.buttonStyle(.plain).accessibilityLabel("Aim at \(toy.word)")
                            .accessibilityValue(play.selected == index ? "Claw aimed here" : "")
                    }
                }
                ToddlerActionButton(title: "Lower the claw", systemImage: "arrow.down.circle.fill", color: .orange) {
                    guard let selected = play.selected else { return }
                    if selected == target { play.win("The claw picked up the \(toys[target].word)!") }
                    else { play.say("The claw is over the \(toys[selected].word). Aim at the \(toys[target].word).") }
                }.disabled(play.selected == nil)
            }
        }
    }
}

struct GuidedWordBuilderGame: View {
    @StateObject private var play = LiteracyPlay()
    private let words = [LiteracyPicture(word: "CAT", asset: "cat"), .init(word: "SUN", asset: "Sun"), .init(word: "DOG", asset: "dog")]
    private var current: LiteracyPicture { words[play.round] }
    private var letters: [String] { current.word.map(String.init) }
    private var choices: [String] { [letters[2], letters[0], letters[1]] }
    var body: some View {
        LiteracyStage(title: "Word Builder", prompt: "Let's build \(current.word.lowercased()). Copy the letters from left to right. Your grown-up can help.", play: play) {
            VStack(spacing: 18) {
                WordPictureCard(word: current.word, asset: current.asset)
                HStack(spacing: 12) {
                    ForEach(0..<letters.count, id: \.self) { index in
                        Text(index < play.count ? letters[index] : "·")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(Color.orange.opacity(index == play.count ? 0.25 : 0.1), in: RoundedRectangle(cornerRadius: 16))
                            .accessibilityLabel(index < play.count ? "Letter \(letters[index]) placed" : "Empty letter space \(index + 1)")
                    }
                }
                HStack(spacing: 12) {
                    ForEach(choices, id: \.self) { letter in
                        LiteracyLetterButton(letter: letter, selected: letters.prefix(play.count).contains(letter)) {
                            if letter == letters[min(play.count, 2)] {
                                play.count += 1
                                if play.count == 3 { play.win("You built \(current.word.lowercased())! \(letters.joined(separator: ", ")). \(current.word.lowercased()).") }
                                else { play.say("\(letter). Next find \(letters[play.count]).") }
                            } else { play.say("Look at the model. Find \(letters[min(play.count, 2)]) next.") }
                        }
                    }
                }
            }
        }
    }
}

struct ListeningBeginningsGame: View {
    @StateObject private var play = LiteracyPlay()
    private var anchor: LiteracyPicture { [LiteracyPicture(word: "moon", asset: "Moon"), .init(word: "sun", asset: "Sun"), .init(word: "cat", asset: "cat")][play.round] }
    private var options: [LiteracyPicture] {
        [[LiteracyPicture(word: "milk", asset: "Milk"), .init(word: "fish", asset: "fish")],
         [.init(word: "dog", asset: "dog"), .init(word: "sandwich", asset: "Sandwich")],
         [.init(word: "cow", asset: "cow"), .init(word: "rabbit", asset: "rabbit")]][play.round]
    }
    private var answer: Int { [0, 1, 0][play.round] }
    var body: some View {
        LiteracyStage(title: "Beginning Sounds", prompt: "Say \(anchor.word). Which word starts the same way: \(options[0].word) or \(options[1].word)?", play: play) {
            VStack(spacing: 22) {
                WordPictureCard(word: anchor.word, asset: anchor.asset)
                HStack(spacing: 14) {
                    ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                        Button {
                            if index == answer { play.win("\(anchor.word) and \(option.word) start with the same sound. Say them together!") }
                            else { play.say("Listen with your grown-up: \(anchor.word), \(options[answer].word). Those words start alike.") }
                        } label: { WordPictureCard(word: option.word, asset: option.asset) }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct AlphabetWindowsGame: View {
    @StateObject private var play = LiteracyPlay()
    private var letters: [String] { [["A", "B", "C"], ["D", "E", "F"], ["M", "N", "O"]][play.round] }
    private var pictures: [LiteracyPicture] {
        [[LiteracyPicture(word: "apple", asset: "Apple"), .init(word: "ball", asset: "basketball"), .init(word: "cat", asset: "cat")],
         [.init(word: "dog", asset: "dog"), .init(word: "egg", asset: "Egg"), .init(word: "fish", asset: "fish")],
         [.init(word: "moon", asset: "Moon"), .init(word: "noodles", asset: "Noodles"), .init(word: "orange", asset: "Orange")]][play.round]
    }
    var body: some View {
        LiteracyStage(title: "ABC Adventure", prompt: "Open the letter windows: \(letters.joined(separator: ", ")). Say each letter and picture word together.", play: play) {
            VStack(spacing: 18) {
                Text("\(play.marked.count) of 3 windows open").font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 124))], spacing: 16) {
                    ForEach(0..<3, id: \.self) { index in
                        Button {
                            play.marked.insert(index)
                            let phrase = "\(letters[index]) is for \(pictures[index].word)."
                            if play.marked.count == 3 { play.win(phrase + " You opened all the alphabet windows!") }
                            else { play.say(phrase) }
                        } label: {
                            VStack(spacing: 12) {
                                Text(letters[index]).font(.system(size: 42, weight: .bold, design: .rounded))
                                if play.marked.contains(index) {
                                    ToddlerArt(asset: pictures[index].asset, size: 72)
                                    Text(pictures[index].word).font(.headline)
                                } else {
                                    Image(systemName: "window.casement.closed").font(.system(size: 60)).frame(height: 96)
                                }
                            }.frame(maxWidth: .infinity, minHeight: 200)
                                .background(.white, in: RoundedRectangle(cornerRadius: 22))
                                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.orange.opacity(0.4), lineWidth: 2))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(play.marked.contains(index) ? "\(letters[index]) is for \(pictures[index].word). Hear again." : "Open letter \(letters[index]) window")
                    }
                }
            }
        }
    }
}

struct RhymeGardenGame: View {
    @StateObject private var play = LiteracyPlay()
    private var word: String { ["cat", "goat", "mouse"][play.round] }
    private var asset: String { ["cat", "goat", "mouse"][play.round] }
    private var answers: [String] { [["hat", "sun"], ["fish", "boat"], ["house", "dog"]][play.round] }
    private var answer: Int { [0, 1, 0][play.round] }
    private var emoji: [String] { [["🎩", "☀️"], ["🐟", "⛵️"], ["🏠", "🐶"]][play.round] }
    var body: some View {
        LiteracyStage(title: "Rhyme Garden", prompt: "Listen for words with the same ending. \(word), \(answers[0]). \(word), \(answers[1]). Which pair rhymes?", play: play) {
            VStack(spacing: 20) {
                WordPictureCard(word: word, asset: asset)
                HStack(spacing: 14) {
                    ForEach(0..<2, id: \.self) { index in
                        Button {
                            if index == answer { play.win("\(word) and \(answers[index]) rhyme! Their endings sound alike.") }
                            else { play.say("Say these together: \(word), \(answers[answer]). Listen to their matching endings.") }
                        } label: {
                            VStack(spacing: 8) {
                                Text(emoji[index]).font(.system(size: 60)).accessibilityHidden(true)
                                Text(answers[index]).font(.title3.bold())
                                Image(systemName: "camera.macro").font(.largeTitle).foregroundStyle(.orange)
                            }.frame(maxWidth: .infinity, minHeight: 170).padding(10).background(.white, in: RoundedRectangle(cornerRadius: 20))
                        }.buttonStyle(.plain).accessibilityLabel("\(word) and \(answers[index])")
                    }
                }
            }
        }
    }
}

struct LetterHideSeekGame: View {
    @StateObject private var play = LiteracyPlay()
    private var target: String { ["M", "S", "A"][play.round] }
    private var board: [String] { [["M", "T", "M", "S", "B", "M"], ["B", "S", "T", "S", "S", "M"], ["A", "M", "S", "A", "T", "A"]][play.round] }
    var body: some View {
        LiteracyStage(title: "Letter Hide & Seek", prompt: "Find every \(target). There are three hiding here.", play: play) {
            VStack(spacing: 18) {
                Text("Find \(target) · \(play.marked.count) of 3").font(.title.bold())
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 88))], spacing: 14) {
                    ForEach(0..<board.count, id: \.self) { index in
                        LiteracyLetterButton(letter: board[index], selected: play.marked.contains(index)) {
                            guard !play.marked.contains(index) else { return }
                            if board[index] == target {
                                play.marked.insert(index)
                                if play.marked.count == 3 { play.win("You found all three copies of \(target)!") }
                                else { play.say("Found \(target). Keep looking for another.") }
                            } else { play.say("That is \(board[index]). Look for \(target).") }
                        }
                        .overlay(alignment: .topTrailing) {
                            if play.marked.contains(index) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).padding(6).accessibilityHidden(true) }
                        }
                        .accessibilityLabel("Letter \(board[index]), \(play.marked.contains(index) ? "found" : "not selected"), position \(index + 1)")
                    }
                }
            }
        }
    }
}

struct WordBeatHopGame: View {
    @StateObject private var play = LiteracyPlay()
    private var word: String { ["cow", "rabbit", "octopus"][play.round] }
    private var spokenParts: String { ["cow", "rab, bit", "oc, to, pus"][play.round] }
    private var target: Int { play.round + 1 }
    var body: some View {
        LiteracyStage(title: "Syllable Hop", prompt: "Say \(word) with your grown-up. Clap once for each word part, then tap the hop button for each clap.", play: play) {
            VStack(spacing: 18) {
                WordPictureCard(word: word, asset: word)
                Text(["cow", "rab · bit", "oc · to · pus"][play.round]).font(.title.bold())
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < play.count ? "leaf.circle.fill" : "circle")
                            .font(.system(size: 46)).foregroundStyle(index < play.count ? .green : .gray)
                    }
                }.accessibilityLabel("\(play.count) word beats tapped")
                ToddlerActionButton(title: "Hop one word beat", systemImage: "hands.clap.fill", color: .orange) {
                    guard play.count < 3 else { return }
                    play.count += 1; play.say("\(play.count)")
                }.disabled(play.count == 3)
                ToddlerActionButton(title: "Check our word beats", systemImage: "checkmark.circle.fill", color: .orange) {
                    if play.count == target { play.win("\(word) has \(target) \(target == 1 ? "beat" : "beats"). You heard the word parts!") }
                    else { play.count = 0; play.say("Let's try together: \(spokenParts). Make \(target) \(target == 1 ? "clap" : "claps").") }
                }
                ToddlerActionButton(title: "Start the beats again", systemImage: "arrow.counterclockwise", color: .orange) { play.count = 0; play.feedback = "" }
            }
        }
    }
}
