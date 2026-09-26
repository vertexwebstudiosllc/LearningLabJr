import SwiftUI
import Combine

struct SentenceChallenge: Identifiable {
    let id: String
    let prompt: String
    let completed: String
    let answer: String
    let choices: [String]
    static let finished = "You explored every sentence in this collection. Wonderful listening!"
    static let retry = "Let’s listen again. Which picture finishes the sentence?"
    static let all: [SentenceChallenge] = [
        .init(id: "sentence-01", prompt: "When I am thirsty, I drink from a…", completed: "When I am thirsty, I drink from a cup.", answer: "cup", choices: ["cup", "book", "boots"]),
        .init(id: "sentence-02", prompt: "When it rains, I stay dry under an…", completed: "When it rains, I stay dry under an umbrella.", answer: "umbrella", choices: ["umbrella", "spoon", "guitar"]),
        .init(id: "sentence-03", prompt: "To read a story, I open a…", completed: "To read a story, I open a book.", answer: "book", choices: ["book", "mitten", "carrot"]),
        .init(id: "sentence-04", prompt: "To eat my soup, I use a…", completed: "To eat my soup, I use a spoon.", answer: "spoon", choices: ["spoon", "kite", "leaf"]),
        .init(id: "sentence-05", prompt: "To keep my feet dry in puddles, I wear…", completed: "To keep my feet dry in puddles, I wear boots.", answer: "boots", choices: ["boots", "flower", "clock"]),
        .init(id: "sentence-06", prompt: "To keep my hand warm, I put on a…", completed: "To keep my hand warm, I put on a mitten.", answer: "mitten", choices: ["mitten", "boat", "apple"]),
        .init(id: "sentence-07", prompt: "To help a thirsty plant, I use a…", completed: "To help a thirsty plant, I use a watering can.", answer: "watering", choices: ["watering", "teddy", "bell"]),
        .init(id: "sentence-08", prompt: "The animal that says moo is a…", completed: "The animal that says moo is a cow.", answer: "cow", choices: ["cow", "cat", "duck"]),
        .init(id: "sentence-09", prompt: "The animal that says meow is a…", completed: "The animal that says meow is a cat.", answer: "cat", choices: ["cat", "hen", "dog"]),
        .init(id: "sentence-10", prompt: "The animal that says woof is a…", completed: "The animal that says woof is a dog.", answer: "dog", choices: ["dog", "bunny", "cow"]),
        .init(id: "sentence-11", prompt: "The animal that says quack is a…", completed: "The animal that says quack is a duck.", answer: "duck", choices: ["duck", "cat", "butterfly"]),
        .init(id: "sentence-12", prompt: "The animal with long ears that hops is a…", completed: "The animal with long ears that hops is a bunny.", answer: "bunny", choices: ["bunny", "fish", "cow"]),
        .init(id: "sentence-13", prompt: "An animal with fins that swims is a…", completed: "An animal with fins that swims is a fish.", answer: "fish", choices: ["fish", "dog", "hen"]),
        .init(id: "sentence-14", prompt: "The insect with colorful wings is a…", completed: "The insect with colorful wings is a butterfly.", answer: "butterfly", choices: ["butterfly", "cow", "crab"]),
        .init(id: "sentence-15", prompt: "A plant with a tall trunk is a…", completed: "A plant with a tall trunk is a tree.", answer: "tree", choices: ["tree", "spoon", "boat"]),
        .init(id: "sentence-16", prompt: "A colorful bloom in the garden is a…", completed: "A colorful bloom in the garden is a flower.", answer: "flower", choices: ["flower", "train", "clock"]),
        .init(id: "sentence-17", prompt: "A green part growing on a branch is a…", completed: "A green part growing on a branch is a leaf.", answer: "leaf", choices: ["leaf", "cup", "bell"]),
        .init(id: "sentence-18", prompt: "For a crunchy orange vegetable, I choose a…", completed: "For a crunchy orange vegetable, I choose a carrot.", answer: "carrot", choices: ["carrot", "drum", "mitten"]),
        .init(id: "sentence-19", prompt: "For a crunchy fruit snack, I choose an…", completed: "For a crunchy fruit snack, I choose an apple.", answer: "apple", choices: ["apple", "hammer", "star"]),
        .init(id: "sentence-20", prompt: "I can pour my cereal into a…", completed: "I can pour my cereal into a bowl.", answer: "bowl", choices: ["bowl", "boots", "kite"]),
        .init(id: "sentence-21", prompt: "To make a ding sound, I ring a…", completed: "To make a ding sound, I ring a bell.", answer: "bell", choices: ["bell", "leaf", "cup"]),
        .init(id: "sentence-22", prompt: "To make a tapping beat, I play a…", completed: "To make a tapping beat, I play a drum.", answer: "drum", choices: ["drum", "apple", "umbrella"]),
        .init(id: "sentence-23", prompt: "To strum some music, I play a…", completed: "To strum some music, I play a guitar.", answer: "guitar", choices: ["guitar", "bucket", "clock"]),
        .init(id: "sentence-24", prompt: "To carry sand at the beach, I fill a…", completed: "To carry sand at the beach, I fill a bucket.", answer: "bucket", choices: ["bucket", "book", "lamp"]),
        .init(id: "sentence-25", prompt: "To travel on the water, I ride in a…", completed: "To travel on the water, I ride in a sailboat.", answer: "boat", choices: ["boat", "train", "tree"]),
        .init(id: "sentence-26", prompt: "To travel along the tracks, I ride in a…", completed: "To travel along the tracks, I ride in a train.", answer: "train", choices: ["train", "boat", "flower"]),
        .init(id: "sentence-27", prompt: "To fly into space, astronauts ride in a…", completed: "To fly into space, astronauts ride in a rocket.", answer: "rocket", choices: ["rocket", "tractor", "bowl"]),
        .init(id: "sentence-28", prompt: "The planet where we live is…", completed: "The planet where we live is Earth.", answer: "earth", choices: ["earth", "moon", "star"]),
        .init(id: "sentence-29", prompt: "A bright shape that twinkles in the night sky is a…", completed: "A bright shape that twinkles in the night sky is a star.", answer: "star", choices: ["star", "carrot", "spoon"]),
        .init(id: "sentence-30", prompt: "To see in a dark room, I turn on a…", completed: "To see in a dark room, I turn on a lamp.", answer: "lamp", choices: ["lamp", "book", "guitar"]),
        .init(id: "sentence-31", prompt: "To see what time it is, I look at a…", completed: "To see what time it is, I look at a clock.", answer: "clock", choices: ["clock", "flower", "boots"]),
        .init(id: "sentence-32", prompt: "To pack clothes for a trip, I use a…", completed: "To pack clothes for a trip, I use a suitcase.", answer: "suitcase", choices: ["suitcase", "spoon", "bell"]),
        .init(id: "sentence-33", prompt: "For a soft cuddle, I hug my…", completed: "For a soft cuddle, I hug my teddy bear.", answer: "teddy", choices: ["teddy", "hammer", "rocket"]),
        .init(id: "sentence-34", prompt: "To fly something on a windy day, I hold the string of a…", completed: "To fly something on a windy day, I hold the string of a kite.", answer: "kite", choices: ["kite", "bowl", "tree"]),
        .init(id: "sentence-35", prompt: "To roll something to a friend, I use a…", completed: "To roll something to a friend, I use a ball.", answer: "ball", choices: ["ball", "book", "mitten"]),
        .init(id: "sentence-36", prompt: "To make a chilly snow friend, we build a…", completed: "To make a chilly snow friend, we build a snowman.", answer: "snowman", choices: ["snowman", "flower", "guitar"]),
    ]
}

@MainActor
final class SentenceSession: ObservableObject {
    nonisolated deinit {}
    static let historyKey = "finishSentence.seen.v1"
    private let defaults: UserDefaults
    private var remaining: [SentenceChallenge]
    @Published private(set) var current: SentenceChallenge?
    @Published private(set) var choices: [String] = []
    @Published private(set) var solved = false
    @Published private(set) var shown = 0
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let seen = Set(defaults.stringArray(forKey: Self.historyKey) ?? [])
        remaining = SentenceChallenge.all.filter { !seen.contains($0.id) }.shuffled()
        shown = SentenceChallenge.all.filter { seen.contains($0.id) }.count
        deal()
    }
    @discardableResult func select(_ id: String) -> Bool {
        guard let current, !solved, choices.contains(id), id == current.answer else { return false }
        solved = true; return true
    }
    func next() { guard solved else { return }; deal() }
    private func deal() {
        solved = false
        current = remaining.popLast()
        choices = current?.choices.shuffled() ?? []
        if let current {
            // Remember when shown, so leaving midway cannot repeat a prompt later.
            var seen = Set(defaults.stringArray(forKey: Self.historyKey) ?? [])
            seen.insert(current.id); defaults.set(seen.sorted(), forKey: Self.historyKey)
            shown += 1
        }
    }
}

struct FinishSentenceGame: View {
    @StateObject private var session = SentenceSession()
    @StateObject private var narrator = GameNarrator()
    @Environment(\.dismiss) private var dismiss
    @State private var retry = false
    private var prompt: String {
        guard let current = session.current else { return SentenceChallenge.finished }
        return session.solved ? HuntItem.named(current.answer).name : current.prompt
    }
    var body: some View {
        ToddlerGameScaffold(title: "Finish My Sentence", prompt: prompt, accent: .purple,
                            completion: false, onReplay: {}, scrollToTopOnPromptChange: true) {
            if let current = session.current {
                Text("Sentence \(session.shown) of \(SentenceChallenge.all.count)").font(.subheadline.bold())
                    .accessibilityIdentifier("sentence.progress")
                Image(systemName: "text.bubble.fill").font(.system(size: 48)).foregroundStyle(.purple)
                Text(session.solved ? current.completed : current.prompt)
                    .font(.system(.title2, design: .rounded, weight: .bold)).multilineTextAlignment(.center)
                    .accessibilityIdentifier("sentence.prompt.\(current.id)")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 125))], spacing: 14) {
                    ForEach(session.choices, id: \.self) { id in
                        Button {
                            guard !session.solved else { return }
                            narrator.stop()
                            if session.select(id) { retry = false }
                            else { retry = true; narrator.speak(SentenceChallenge.retry) }
                        } label: {
                            VStack(spacing: 10) {
                                SentencePicture(id: id).frame(width: 85, height: 85)
                                Text(HuntItem.named(id).name).font(.headline)
                                if session.solved && id == current.answer {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                }
                            }.frame(maxWidth: .infinity, minHeight: 145).padding(10)
                                .background(session.solved && id == current.answer ? Color.green.opacity(0.12) : .white, in: RoundedRectangle(cornerRadius: 22))
                                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.purple.opacity(0.25), lineWidth: 2))
                        }.buttonStyle(.plain).disabled(session.solved)
                            .accessibilityIdentifier("sentence.choice.\(id)")
                    }
                }
                if retry { Text(SentenceChallenge.retry).font(.headline).multilineTextAlignment(.center) }
                if session.solved {
                    ToddlerActionButton(title: "Next sentence", systemImage: "arrow.right", color: .purple) {
                        narrator.stop(); retry = false; session.next()
                    }.accessibilityIdentifier("sentence.next")
                }
            } else {
                Image(systemName: "checkmark.seal.fill").font(.system(size: 85)).foregroundStyle(.green)
                Text("All sentences explored!").font(.title2.bold()).accessibilityIdentifier("sentence.finished")
                Text("You have seen all 36 sentences. Your progress is saved so they won’t repeat.")
                    .multilineTextAlignment(.center)
                ToddlerActionButton(title: "All done", systemImage: "checkmark", color: .purple) { dismiss() }
            }
        }.onDisappear { narrator.stop() }
    }
}

struct SentencePicture: View {
    let id: String
    var body: some View {
        // Use a vector ball rather than the legacy raster asset.
        if id == "ball" {
            Image(systemName: "basketball.fill").resizable().scaledToFit().foregroundStyle(.orange)
        } else { HuntItemArt(item: HuntItem.named(id)) }
    }
}
