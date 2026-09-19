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

struct LiteracyLetterButton: View {
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
