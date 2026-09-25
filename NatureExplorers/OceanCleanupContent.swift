import Foundation

struct OceanBuddy: Identifiable, Equatable {
    let id: String
    let name: String
    let asset: String
    var greeting: String { "\(name)! Let's help our ocean friend clean ten places. Ready to begin?" }
    var farewell: String { "You helped the \(name.lowercased()) clean all ten places! Trash belongs in a bin. Ocean animals belong in their home." }
    static let bank: [Self] = [
        .init(id: "dolphin", name: "Dolphin", asset: "dolphinClean"),
        .init(id: "whale", name: "Whale", asset: "OceanClean/whale"),
        .init(id: "shark", name: "Shark", asset: "OceanClean/shark"),
        .init(id: "octopus", name: "Octopus", asset: "OceanClean/octopus"),
        .init(id: "jellyfish", name: "Jellyfish", asset: "OceanClean/jellyfish"),
        .init(id: "crab", name: "Crab", asset: "OceanClean/crab"),
        .init(id: "lobster", name: "Lobster", asset: "OceanClean/lobster"),
        .init(id: "seahorse", name: "Seahorse", asset: "OceanClean/seahorse"),
        .init(id: "squid", name: "Squid", asset: "OceanClean/squid"),
        .init(id: "stingray", name: "Stingray", asset: "OceanClean/stingray"),
        .init(id: "starfish", name: "Starfish", asset: "OceanClean/starfish"),
        .init(id: "seal", name: "Seal", asset: "OceanClean/seal"),
        .init(id: "swordfish", name: "Swordfish", asset: "OceanClean/swordfish"),
    ]
    static func choices(after previous: [String]) -> [Self] {
        let fresh = bank.filter { !previous.contains($0.id) }.shuffled()
        return Array((fresh + bank.filter { previous.contains($0.id) }.shuffled()).prefix(6))
    }
}

struct OceanLitter: Identifiable, Equatable {
    let id: String
    let name: String
    let symbol: String
    var sortingPrompt: String { "First, find each \(name.lowercased()) that matches the picture. Then we will collect the other trash." }
    var pairPrompt: String { "You found \(name.hasPrefix("Empty") ? "an" : "a") \(name.lowercased()). Find another one just like it to collect the pair." }
    static let bank: [Self] = [
        .init(id: "bottle", name: "Plastic bottle", symbol: "waterbottle.fill"),
        .init(id: "bag", name: "Plastic bag", symbol: "bag.fill"),
        .init(id: "can", name: "Empty can", symbol: "cylinder.fill"),
        .init(id: "cup", name: "Discarded cup", symbol: "cup.and.saucer.fill"),
        .init(id: "carton", name: "Empty carton", symbol: "shippingbox.fill"),
        .init(id: "wrapper", name: "Snack wrapper", symbol: "rectangle.fill"),
    ]
}

enum OceanPuzzleKind { case cleanup, sorting, pairs }
struct OceanCleanupPiece: Identifiable {
    let id: Int
    let litter: OceanLitter?
    let animal: OceanBuddy?
    var name: String { litter?.name ?? animal?.name ?? "Clear water" }
}
struct OceanCleanupRound {
    let name: String
    let kind: OceanPuzzleKind
    let pieces: [OceanCleanupPiece]
    let target: OceanLitter?
    var trashIDs: Set<Int> { Set(pieces.filter { $0.litter != nil }.map(\.id)) }
    static func make(hero: OceanBuddy) -> [Self] {
        let names = ["Bubble Bay", "Coral Corner", "Shell Shore", "Kelp Cove", "Pebble Path", "Sandy Seafloor", "Rainbow Reef", "Wavy Waters", "Blue Lagoon", "Sparkling Sea"]
        let kinds: [OceanPuzzleKind] = [.cleanup, .cleanup, .cleanup, .sorting, .sorting, .sorting, .pairs, .pairs, .pairs, .cleanup]
        var previousAnimals: Set<String> = []
        var previousTarget = ""
        return kinds.enumerated().map { index, kind in
            let types = OceanLitter.bank.shuffled()
            var trash: [OceanLitter]
            var target: OceanLitter?
            switch kind {
            case .cleanup: trash = Array(types.prefix(index < 3 ? index + 2 : 5))
            case .sorting:
                let focus = types.first { $0.id != previousTarget }!
                previousTarget = focus.id; target = focus
                trash = [focus, focus] + Array(types.filter { $0 != focus }.prefix(index == 5 ? 3 : 2))
            case .pairs:
                trash = Array(types.prefix(index == 6 ? 2 : 3)).flatMap { [$0, $0] }
            }
            let count = index < 3 ? 6 : 9
            let pool = OceanBuddy.bank.filter { $0 != hero }
            let animals = Array((pool.filter { !previousAnimals.contains($0.id) }.shuffled() + pool.filter { previousAnimals.contains($0.id) }.shuffled()).prefix(count - trash.count))
            previousAnimals = Set(animals.map(\.id))
            let raw = trash.map { OceanCleanupPiece(id: 0, litter: $0, animal: nil) } + animals.map { OceanCleanupPiece(id: 0, litter: nil, animal: $0) }
            let pieces = raw.shuffled().enumerated().map { OceanCleanupPiece(id: $0.offset, litter: $0.element.litter, animal: $0.element.animal) }
            return Self(name: names[index], kind: kind, pieces: pieces, target: target)
        }
    }
}

struct OceanCleanupPlay {
    static let choosePrompt = "Choose an ocean friend. Who would you like to help today?"
    static let cleanupPrompt = "Find the trash and tap to put it in the bin. Leave the ocean animals in their home."
    static let remainingPrompt = "Great sorting! Now collect the rest of the trash. Leave the animals swimming."
    static let pairsPrompt = "Let's collect matching pairs of trash. Tap one piece, then tap another just like it."
    static let animalHint = "That is an ocean animal. Let it stay in its home. Look for trash instead."
    static let sortingHint = "Let's find the trash that matches our picture first."
    static let pairHint = "Those pieces are different. Look for another piece like the one with the bright ring."
    static let solvedPrompt = "This place is clean! The animals can stay. Let's help in the next place."
    static let finalRoundPrompt = "The last place is clean! Let's celebrate with our ocean friend."
    let choices: [OceanBuddy]
    private(set) var hero: OceanBuddy?
    private(set) var rounds: [OceanCleanupRound] = []
    private(set) var started = false
    private(set) var index = 0
    private(set) var collected: Set<Int> = []
    private(set) var selected: Int?
    private(set) var feedback = ""
    private(set) var totalCollected = 0
    init(previousChoices: [String] = []) { choices = OceanBuddy.choices(after: previousChoices) }
    var current: OceanCleanupRound? { rounds.indices.contains(index) ? rounds[index] : nil }
    var complete: Bool { started && index == 10 }
    var solved: Bool { current.map { $0.trashIDs == collected } ?? false }
    var targetRemaining: Bool {
        guard let round = current, let target = round.target else { return false }
        return round.pieces.contains { $0.litter == target && !collected.contains($0.id) }
    }
    var prompt: String {
        guard let hero else { return Self.choosePrompt }
        if !started { return hero.greeting }
        if complete { return hero.farewell }
        if solved { return index == 9 ? Self.finalRoundPrompt : Self.solvedPrompt }
        if !feedback.isEmpty { return feedback }
        guard let round = current else { return Self.cleanupPrompt }
        switch round.kind {
        case .cleanup: return Self.cleanupPrompt
        case .sorting: return targetRemaining ? round.target!.sortingPrompt : Self.remainingPrompt
        case .pairs:
            if let selected, let piece = round.pieces.first(where: { $0.id == selected }), let litter = piece.litter { return litter.pairPrompt }
            return Self.pairsPrompt
        }
    }
    mutating func choose(_ buddy: OceanBuddy) {
        guard hero == nil, choices.contains(buddy) else { return }
        hero = buddy; rounds = OceanCleanupRound.make(hero: buddy)
    }
    mutating func begin() { guard hero != nil else { return }; started = true }
    @discardableResult mutating func pick(_ id: Int) -> Bool {
        guard started, !complete, !solved, let round = current,
              let piece = round.pieces.first(where: { $0.id == id }), !collected.contains(id) else { return false }
        guard let litter = piece.litter else { feedback = Self.animalHint; return false }
        if round.kind == .sorting && targetRemaining && litter != round.target { feedback = Self.sortingHint; return false }
        if round.kind == .pairs {
            if let first = selected {
                if first == id { selected = nil; feedback = ""; return false }
                if round.pieces.first(where: { $0.id == first })?.litter != litter { feedback = Self.pairHint; return false }
                collected.insert(first); selected = nil; totalCollected += 1
            } else { selected = id; feedback = ""; return false }
        }
        collected.insert(id); totalCollected += 1; feedback = ""; return true
    }
    mutating func next() {
        guard started, solved else { return }
        index += 1; collected = []; selected = nil; feedback = ""
    }
    static var narration: [String] {
        [choosePrompt, cleanupPrompt, remainingPrompt, pairsPrompt, animalHint, sortingHint, pairHint, solvedPrompt, finalRoundPrompt]
        + OceanBuddy.bank.flatMap { [$0.greeting, $0.farewell] }
        + OceanLitter.bank.flatMap { [$0.sortingPrompt, $0.pairPrompt] }
    }
}
