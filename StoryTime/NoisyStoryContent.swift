import SwiftUI
import Combine

struct NoisySound: Identifiable {
    let id: String
    let art: String
    let name: String
    let line: String
    static let all: [NoisySound] = [
        .init(id: "duck", art: "duck", name: "Duck", line: "Duck. Quack, quack!"),
        .init(id: "cow", art: "cow", name: "Cow", line: "Cow. Moo, moo!"),
        .init(id: "rain", art: "cloud", name: "Rain", line: "Pitter patter, pitter patter. Rain taps on the leaves."),
        .init(id: "puddle", art: "water", name: "Puddle", line: "Splish, splash!"),
        .init(id: "bell", art: "bell", name: "Bell", line: "Ding, ding!"),
        .init(id: "drum", art: "drum", name: "Drum", line: "Boom, boom!"),
        .init(id: "guitar", art: "guitar", name: "Guitar", line: "Strum, strum!"),
        .init(id: "dog", art: "dog", name: "Dog", line: "Woof, woof!"),
        .init(id: "cat", art: "cat", name: "Cat", line: "Meow, meow!"),
        .init(id: "boat", art: "boat", name: "Boat", line: "Toot, toot!"),
        .init(id: "train", art: "train", name: "Train", line: "Choo, choo!"),
        .init(id: "rocket", art: "rocket", name: "Rocket", line: "Whoosh!"),
        .init(id: "leaf", art: "leaf", name: "Leaves", line: "Rustle, rustle!"),
        .init(id: "apple", art: "apple", name: "Apple", line: "Crunch, crunch!"),
        .init(id: "boots", art: "boots", name: "Footsteps", line: "Clip, clop!"),
        .init(id: "spoon", art: "spoon", name: "Spoon", line: "Clink, clink!"),
        .init(id: "bubbles", art: "bubbles", name: "Bubbles", line: "Pop, pop!"),
        .init(id: "snow", art: "snowman", name: "Snow", line: "Scrunch, scrunch!"),
        .init(id: "yawn", art: "teddy", name: "Sleepy teddy", line: "Yawn! Good night."),
        .init(id: "clap", art: "clap", name: "Clapping", line: "Clap, clap!"),
    ]
    static func named(_ id: String) -> NoisySound { all.first { $0.id == id }! }
}
struct NoisyPage {
    let text: String
    let sounds: [String]
}
struct NoisyAdventure: Identifiable {
    let id: String
    let title: String
    let art: String
    let color: UInt
    let pages: [NoisyPage]
    static let choosePrompt = "Choose a noisy story. Tap both pictures on each page."
    static let anotherPrompt = "The end! Choose a new noisy story."
    static let all: [NoisyAdventure] = [
        .init(id: "farm", title: "Farm Friends", art: "cow", color: 14479055, pages: [
            .init(text: "Duck visits Cow.", sounds: ["duck", "cow"]),
            .init(text: "Rain sends the friends home.", sounds: ["rain", "duck"]),
        ]),
        .init(id: "band", title: "The Little Band", art: "drum", color: 16771004, pages: [
            .init(text: "A band begins to play.", sounds: ["drum", "guitar"]),
            .init(text: "A bell ends the happy song.", sounds: ["bell", "clap"]),
        ]),
        .init(id: "rain", title: "Puddle Walk", art: "cloud", color: 14281978, pages: [
            .init(text: "Rain makes little puddles.", sounds: ["rain", "puddle"]),
            .init(text: "Boots splash all the way home.", sounds: ["boots", "puddle"]),
        ]),
        .init(id: "pets", title: "A Pet Parade", art: "dog", color: 16310250, pages: [
            .init(text: "Dog invites Cat to a parade.", sounds: ["dog", "cat"]),
            .init(text: "The friends march past a bell.", sounds: ["boots", "bell"]),
        ]),
        .init(id: "harbor", title: "Harbor Hello", art: "boat", color: 13889773, pages: [
            .init(text: "A boat comes to the harbor.", sounds: ["boat", "puddle"]),
            .init(text: "Duck welcomes the boat home.", sounds: ["duck", "boat"]),
        ]),
        .init(id: "train", title: "Train to the Farm", art: "train", color: 16115919, pages: [
            .init(text: "The train leaves the station.", sounds: ["bell", "train"]),
            .init(text: "Cow greets the arriving train.", sounds: ["cow", "train"]),
        ]),
        .init(id: "space", title: "Rocket Bedtime", art: "rocket", color: 14671350, pages: [
            .init(text: "Teddy launches a toy rocket.", sounds: ["rocket", "clap"]),
            .init(text: "Teddy parks it and gets sleepy.", sounds: ["rocket", "yawn"]),
        ]),
        .init(id: "picnic", title: "Windy Picnic", art: "apple", color: 14938829, pages: [
            .init(text: "Leaves rustle at our picnic.", sounds: ["leaf", "apple"]),
            .init(text: "We finish our snack together.", sounds: ["apple", "clap"]),
        ]),
        .init(id: "soup", title: "Soup for Teddy", art: "spoon", color: 16769734, pages: [
            .init(text: "We stir soup in a pretend pot.", sounds: ["spoon", "bubbles"]),
            .init(text: "Teddy eats, then gets sleepy.", sounds: ["spoon", "yawn"]),
        ]),
        .init(id: "snow", title: "Snowy Footsteps", art: "snowman", color: 14478586, pages: [
            .init(text: "We walk through crunchy snow.", sounds: ["boots", "snow"]),
            .init(text: "Our snowman gets a cheer.", sounds: ["snow", "clap"]),
        ]),
        .init(id: "party", title: "Bubble Party", art: "bubbles", color: 16244208, pages: [
            .init(text: "Bubbles float past the band.", sounds: ["bubbles", "drum"]),
            .init(text: "The last bubble pops. Hooray!", sounds: ["bubbles", "clap"]),
        ]),
        .init(id: "bedtime", title: "Cozy Rainy Night", art: "teddy", color: 14737139, pages: [
            .init(text: "Rain taps as Cat settles down.", sounds: ["rain", "cat"]),
            .init(text: "Teddy yawns. Everyone rests.", sounds: ["yawn", "rain"]),
        ]),
    ]
    static var narration: [String] { [choosePrompt, anotherPrompt] + all.flatMap { $0.pages.map(\.text) } + NoisySound.all.map(\.line) }
}

@MainActor
final class NoisyStorySession: ObservableObject {
    nonisolated deinit {}
    private let defaults: UserDefaults
    private var completed: Set<String> = []
    private var last: String?
    @Published private(set) var choices: [NoisyAdventure] = []
    @Published private(set) var story: NoisyAdventure?
    @Published private(set) var page = 0
    @Published private(set) var heard: Set<String> = []
    @Published private(set) var caption = ""
    @Published private(set) var finishedCount = 0
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults; last = defaults.string(forKey: "noisyStory.lastCompleted")
        refreshChoices()
    }
    var current: NoisyPage? { story?.pages[page] }
    var ready: Bool { guard let current else { return false }; return Set(current.sounds).isSubset(of: heard) }
    var prompt: String { current?.text ?? (finishedCount == 0 ? NoisyAdventure.choosePrompt : NoisyAdventure.anotherPrompt) }
    func choose(_ id: String) {
        guard story == nil, let choice = choices.first(where: { $0.id == id }) else { return }
        story = choice; page = 0; heard = []; caption = ""
    }
    @discardableResult func hear(_ id: String) -> String? {
        guard current?.sounds.contains(id) == true else { return nil }
        heard.insert(id); caption = NoisySound.named(id).line; return caption
    }
    func next() {
        guard let story, ready else { return }
        if page + 1 < story.pages.count { page += 1; heard = []; caption = "" }
        else {
            completed.insert(story.id); last = story.id; defaults.set(story.id, forKey: "noisyStory.lastCompleted")
            finishedCount += 1; self.story = nil; heard = []; caption = ""; refreshChoices()
        }
    }
    func returnToChoices() { story = nil; heard = []; caption = "" }
    private func refreshChoices() {
        var pool = NoisyAdventure.all.filter { !completed.contains($0.id) && $0.id != last }
        if pool.isEmpty {
            completed = []; pool = NoisyAdventure.all.filter { $0.id != last }
        }
        choices = pool.shuffled()
    }
}
