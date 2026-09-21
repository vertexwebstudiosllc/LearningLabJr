import SwiftUI
import Combine

enum CountingActivity: String, CaseIterable {
    case share, sheep, trail, more, garden, tickets, towers, dots, hops, drum
    var title: String {
        switch self {
        case .share: return "Picnic Share"
        case .sheep: return "Sleepy Sheep"
        case .trail: return "Treasure Trail"
        case .more: return "Which Has More?"
        case .garden: return "Five-Frame Garden"
        case .tickets: return "Ticket Train"
        case .towers: return "Twin Towers"
        case .dots: return "Dot Detective"
        case .hops: return "Frog Hops"
        case .drum: return "Counting Drum"
        }
    }
    var completion: String {
        switch self {
        case .share: return "You shared the picnic fairly. Every friend got the same amount!"
        case .sheep: return "Every flock is tucked in. You counted down all the way to zero!"
        case .trail: return "You followed all the counting trails, from one all the way to ten!"
        case .more: return "You compared every group. You found more and fewer!"
        case .garden: return "Your gardens are blooming. You made groups from one to ten!"
        case .tickets: return "Every train has matching tickets. All aboard, counting explorer!"
        case .towers: return "Your towers match! You used adding and taking away to build them!"
        case .dots: return "You found every dot twin. What careful looking and remembering!"
        case .hops: return "The frog finished every hopping trip. Thanks for counting along!"
        case .drum: return "You echoed all the counting beats. What a musical adventure!"
        }
    }
    func levels() -> [CountingLesson] {
        switch self {
        case .share:
            return (2...6).flatMap { n in (0..<2).map { CountingLesson(target: n, variant: $0) } }
                + (2...6).flatMap { n in (0..<2).map { CountingLesson(target: n, amount: 2, variant: $0) } }
        case .sheep: return (2...10).flatMap { n in (0..<2).map { CountingLesson(target: n, variant: $0) } }
        case .trail: return (3...10).flatMap { n in (0..<3).map { CountingLesson(target: n, variant: $0) } }
        case .more:
            let pairs = [(1,3),(2,4),(2,5),(3,5),(3,6),(4,6),(4,7),(5,7),(6,7),(7,8)]
            return (0..<2).flatMap { mode in pairs.enumerated().map { index, pair in
                CountingLesson(target: mode == 0 ? pair.1 : pair.0, other: mode == 0 ? pair.0 : pair.1, variant: index, fewer: mode == 1)
            } }
        case .garden: return (1...10).flatMap { n in
            [CountingLesson(target: n), CountingLesson(target: n, start: n == 10 ? 9 : n + 1, variant: 1)]
        }
        case .tickets: return (2...9).flatMap { n in (0..<3).map { CountingLesson(target: n, variant: $0) } }
        case .towers: return (2...10).flatMap { n in
            [CountingLesson(target: n), CountingLesson(target: n, start: n + 1, variant: 1)]
        }
        case .dots: return (1...6).flatMap { n in (0..<3).map { CountingLesson(target: n, variant: $0) } }
        case .hops: return (2...9).flatMap { n in (0..<3).map { CountingLesson(target: n, variant: $0) } }
        case .drum: return (1...6).flatMap { n in (0..<3).map { CountingLesson(target: n, variant: $0) } }
        }
    }
}

struct CountingLesson {
    let target: Int
    var other = 0
    var amount = 1
    var start = 0
    var variant = 0
    var fewer = false
    var choices: [Int]
    var stones: [Int]
    init(target: Int, other: Int = 0, amount: Int = 1, start: Int = 0, variant: Int = 0, fewer: Bool = false) {
        self.target = target; self.other = other; self.amount = amount; self.start = start; self.variant = variant; self.fewer = fewer
        choices = other > 0 ? [target, other].shuffled() : ([target] + (max(1, target - 2)...min(12, target + 2)).filter { $0 != target }.shuffled().prefix(2)).shuffled()
        stones = Array(1...target).shuffled()
    }
    var gardenSize: Int { max(target, start) <= 5 ? 5 : 10 }
}

@MainActor
final class CountingPlay: ObservableObject {
    let kind: CountingActivity
    @Published private(set) var levels: [CountingLesson]
    @Published private(set) var round = 0
    @Published private(set) var count = 0
    @Published private(set) var marked: Set<Int> = []
    @Published private(set) var servings: [Int: Int] = [:]
    @Published var revealed = false
    @Published private(set) var solved = false
    @Published private(set) var complete = false
    @Published private(set) var feedback = ""
    @Published private(set) var feedbackRevision = 0
    var total: Int { levels.count }
    var lesson: CountingLesson { levels[round] }
    var target: Int { lesson.target }
    var limit: Int { min(12, target + 2) }
    init(kind: CountingActivity) { self.kind = kind; levels = kind.levels(); resetRound() }
    var prompt: String {
        switch kind {
        case .share: return lesson.amount == 1 ? "Give one apple to every plate. Tap an empty plate." : "Give two apples to every plate. Tap each plate until it has two."
        case .sheep: return "Tap each sheep to tuck it in. How many are still awake?"
        case .trail: return "Follow the counting stones. Start at one."
        case .more: return lesson.fewer ? "Which group has fewer oranges? Tap that group." : "Which group has more oranges? Tap that group."
        case .garden: return "Plant \(target) \(target == 1 ? "flower" : "flowers"). Tap a space to plant. Tap a flower to take it out."
        case .tickets: return "Choose a ticket with exactly one dot for each passenger."
        case .towers: return "Build a tower the same height as mine. Add or take away blocks."
        case .dots: return "Look at the clue dots. Hide the clue when you are ready, then find its twin."
        case .hops: return "Help the frog make \(target) hops. Then tap All hopped."
        case .drum: return "Listen to my counting beats. Tap the drum the same number of times."
        }
    }
    func say(_ text: String) { guard !complete else { return }; feedback = text; feedbackRevision += 1 }
    private func win(_ text: String) { guard !complete, !solved else { return }; solved = true; say(text) }
    func advance() {
        guard solved, !complete else { return }
        if round + 1 == total { complete = true; return }
        round += 1; resetRound()
    }
    func replay() { levels = kind.levels(); round = 0; complete = false; resetRound() }
    private func resetRound() {
        count = lesson.start; marked = kind == .garden ? Set(0..<lesson.start) : []
        servings = [:]; revealed = false; solved = false; feedback = ""
    }
    func clear() { guard !complete, !solved else { return }; count = 0; feedback = "" }
    func serve(_ index: Int) {
        guard kind == .share, !solved, !complete, (0..<target).contains(index) else { return }
        let current = servings[index, default: 0]
        guard current < lesson.amount else { say("This plate has enough. Find a plate that needs more."); return }
        servings[index] = current + 1
        if servings.count == target && servings.values.allSatisfy({ $0 == lesson.amount }) { win("Everyone has the same amount. What fair sharing!") }
        else { say(current == 0 ? "One apple for this friend." : "Two apples for this friend.") }
    }
    func tuck(_ index: Int) {
        guard kind == .sheep, !solved, !complete, (0..<target).contains(index), marked.insert(index).inserted else { return }
        let left = target - marked.count
        if left == 0 { win("No sheep awake. All the sheep are asleep. Good night!") }
        else { say("\(left) \(left == 1 ? "sheep is" : "sheep are") still awake.") }
    }
    func stone(_ value: Int) {
        guard kind == .trail, !solved, !complete, lesson.stones.contains(value), value > count else { return }
        guard value == count + 1 else { say("Look for \(count + 1). Count the dots on the stones."); return }
        count += 1
        if count == target { win("You followed every counting stone. Treasure found!") }
        else { say("\(value). Next comes \(value + 1).") }
    }
    func choose(_ value: Int) {
        guard [.more, .tickets, .dots].contains(kind), !solved, !complete, lesson.choices.contains(value) else { return }
        if value == target {
            switch kind {
            case .more: win(lesson.fewer ? "Yes! That group has fewer oranges." : "Yes! That group has more oranges.")
            case .tickets: win("One dot for each passenger. All aboard!")
            default: win("You found the twin: \(target) dots!")
            }
        } else {
            switch kind {
            case .more: say("Count both groups carefully, then try again.")
            case .tickets: say("Match each rabbit with one dot. Try another ticket.")
            default: say("You can peek at the clue again. Look for the same dots.")
            }
        }
    }
    func plant(_ index: Int) {
        guard kind == .garden, !solved, !complete, (0..<lesson.gardenSize).contains(index) else { return }
        if marked.contains(index) { marked.remove(index) } else { marked.insert(index) }
        say("\(marked.count) \(marked.count == 1 ? "flower" : "flowers")")
    }
    func changeBlocks(_ delta: Int) {
        guard kind == .towers, !solved, !complete, abs(delta) == 1, (0...12).contains(count + delta) else { return }
        count += delta; say("\(count) \(count == 1 ? "block" : "blocks")")
    }
    func tap() {
        guard [.hops, .drum].contains(kind), !solved, !complete, count < limit else { return }
        count += 1; say("\(count)")
    }
    func check() {
        guard !solved, !complete else { return }
        switch kind {
        case .garden:
            if marked.count == target { win("Exactly \(target) \(target == 1 ? "flower" : "flowers"). Your garden is growing!") }
            else { say(marked.count < target ? "Add another flower, then count again." : "Take out a flower, then count again.") }
        case .towers:
            if count == target { win("Both towers have \(target) blocks. They are the same height!") }
            else { say(count < target ? "Your tower is shorter. Add a block." : "Your tower is taller. Take one block away.") }
        case .hops:
            if count == target { win("\(target) hops! The frog reached the pond.") }
            else if count < target { say("Make one more hop, then count again.") }
            else { count = 0; say("Let's start the hops again.") }
        case .drum:
            if count == target { win("\(target) beats. You echoed my drum!") }
            else { count = 0; say("Let's listen again, then tap along.") }
        default: break
        }
    }
}
