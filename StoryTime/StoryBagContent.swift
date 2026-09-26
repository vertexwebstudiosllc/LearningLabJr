import Foundation
import Combine

struct BagSetting: Identifiable {
    let id: String
    let title: String
    let opening: String
    let art: String
    let sky: UInt
    let ground: UInt
    static let all: [BagSetting] = [
        .init(id: "castle", title: "The Wobbly Castle", opening: "Our story begins at a wobbly castle.", art: "castle", sky: 15260924, ground: 10931859),
        .init(id: "moon", title: "The Cheese Moon", opening: "Our story begins on a pretend cheese moon.", art: "moon", sky: 13950713, ground: 15388031),
        .init(id: "island", title: "Jellybean Island", opening: "Our story begins on Jellybean Island.", art: "boat", sky: 13627640, ground: 15719332),
        .init(id: "garden", title: "The Giant Garden", opening: "Our story begins in a giant garden.", art: "flower", sky: 14414289, ground: 8897936),
        .init(id: "snow", title: "The Snow Palace", opening: "Our story begins at a snowy palace.", art: "snowman", sky: 14281211, ground: 15594746),
        .init(id: "ocean", title: "The Bubble Sea", opening: "Our story begins under the pretend sea.", art: "fish", sky: 10477291, ground: 15193766),
        .init(id: "farm", title: "The Funny Farm", opening: "Our story begins at a funny farm.", art: "cow", sky: 14151419, ground: 11982471),
        .init(id: "kitchen", title: "The Teeny Kitchen", opening: "Our story begins in a teeny kitchen.", art: "bowl", sky: 16770504, ground: 14527875),
        .init(id: "forest", title: "The Whispering Woods", opening: "Our story begins in the whispering woods.", art: "tree", sky: 14348756, ground: 8565896),
        .init(id: "party", title: "The Balloon Party", opening: "Our story begins at a balloon party.", art: "balloon", sky: 16309745, ground: 14008045),
        .init(id: "space", title: "The Star Station", opening: "Our story begins at a pretend star station.", art: "rocket", sky: 13488877, ground: 10787535),
        .init(id: "beach", title: "The Sandcastle Beach", opening: "Our story begins on a sandcastle beach.", art: "castle", sky: 13626103, ground: 15519902),
    ]
}
struct BagSurprise: Identifiable {
    let id: String
    let title: String
    let art: String
    let sentence: String
    static let all: [BagSurprise] = [
        .init(id: "bunny", title: "Crowned bunny", art: "bunny", sentence: "Our friend was a bunny in a crown."),
        .init(id: "dragon", title: "Dancing dragon", art: "dragon", sentence: "Our friend was a tiny dancing dragon."),
        .init(id: "teddy", title: "Mustache teddy", art: "teddy", sentence: "Our friend was a teddy with a curly mustache."),
        .init(id: "cat", title: "Cat in a hat", art: "cat", sentence: "Our friend was a cat with a silly hat."),
        .init(id: "treasure", title: "Shiny shells", art: "treasure", sentence: "Next, our friend found a chest of shiny shells."),
        .init(id: "flower", title: "Giant flower", art: "flower", sentence: "Next, our friend watched a giant flower bloom."),
        .init(id: "tree", title: "Singing tree", art: "tree", sentence: "Next, our friend found a tree that sang a song."),
        .init(id: "bell", title: "Tiny bells", art: "bell", sentence: "Next, our friend rang tiny bells in a happy rhythm."),
        .init(id: "spoon", title: "Spoon ride", art: "spoon", sentence: "At last, everyone flew home on a giant spoon!"),
        .init(id: "boots", title: "Jelly boots", art: "boots", sentence: "At last, everyone danced in wobbly jelly boots!"),
        .init(id: "drawing", title: "Draw it", art: "pencil", sentence: "Last, our friend drew a picture of the adventure."),
        .init(id: "cup", title: "Cozy drink", art: "cup", sentence: "Last, our friend warmed up with a cozy drink."),
    ]
    static func pool(_ stage: Int) -> [BagSurprise] { Array(all[(stage * 4)..<(stage * 4 + 4)]) }
    static let instruction = "Open each bag. Pick a surprise for your silly story!"
    static let finished = "You explored every storybook setting. What wonderful stories!"
    static var narration: [String] { [instruction, finished] + BagSetting.all.map(\.opening) + all.map(\.sentence) }
}

@MainActor
final class StoryBagSession: ObservableObject {
    nonisolated deinit {}
    static let seenKey = "storyBag.seenSettings.v1"
    private let defaults: UserDefaults
    private var remaining: [BagSetting]
    @Published private(set) var setting: BagSetting?
    @Published private(set) var selected: [BagSurprise] = []
    @Published private(set) var choices: [BagSurprise] = []
    @Published private(set) var isOpen = false
    @Published private(set) var generation = UUID()
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let seen = Set(defaults.stringArray(forKey: Self.seenKey) ?? [])
        remaining = BagSetting.all.filter { !seen.contains($0.id) }.shuffled()
        deal()
    }
    var ready: Bool { selected.count == 3 }
    var lines: [String] { guard let setting else { return [] }; return [setting.opening] + selected.map(\.sentence) }
    func open() {
        guard setting != nil, !ready, !isOpen else { return }
        choices = Array(BagSurprise.pool(selected.count).shuffled().prefix(2)); isOpen = true
    }
    func choose(_ id: String, generation token: UUID) {
        guard isOpen, !ready, token == generation, let choice = choices.first(where: { $0.id == id }) else { return }
        selected.append(choice); choices = []; isOpen = false; generation = UUID()
    }
    func nextStory() { guard ready else { return }; deal() }
    private func deal() {
        setting = remaining.popLast(); selected = []; choices = []; isOpen = false; generation = UUID()
        if let setting {
            var seen = Set(defaults.stringArray(forKey: Self.seenKey) ?? [])
            seen.insert(setting.id); defaults.set(seen.sorted(), forKey: Self.seenKey)
        }
    }
}
