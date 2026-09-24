import SwiftUI
import Combine

enum CountingActivity: String, CaseIterable {
    case share, trail, more, garden, tickets, towers, dots, hops, drum
    var title: String {
        switch self {
        case .share: return "Picnic Share"
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
        case .share: return "You solved ten picnic puzzles with adding and taking away. What a helpful picnic partner!"
        case .trail: return "You made every treasure pile match! Great adding by fives!"
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
        var result = quantityLevels()
        let foods = countingPictureCycle(NumberPicnicFood.bank, count: result.count)
        let animals = countingPictureCycle(TouchCountAnimal.bank, count: result.count)
        let themes = countingPictureCycle(CountingTheme.bank, count: result.count)
        for index in result.indices {
            result[index].food = foods[index]
            result[index].animal = animals[index]
            result[index].theme = themes[index]
        }
        return result
    }
    private func quantityLevels() -> [CountingLesson] {
        switch self {
        case .share:
            let additions = (1...7).flatMap { start in
                ((start + 1)...10).map { CountingLesson.picnic(start: start, goal: $0) }
            }.shuffled().prefix(5)
            let subtractions = (3...10).flatMap { start in
                (1..<start).map { CountingLesson.picnic(start: start, goal: $0) }
            }.shuffled().prefix(5)
            return (Array(additions) + Array(subtractions)).shuffled()
        case .trail:
            return stride(from: 5, through: 100, by: 5).map { goal in
                CountingLesson.treasure(start: Array(stride(from: 0, to: goal, by: 5)).randomElement()!, goal: goal)
            }.shuffled()
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
    var food = NumberPicnicFood.bank[0]
    var animal = TouchCountAnimal.bank[0]
    var theme = CountingTheme.bank[0]
    var other = 0
    var goal = 0
    var start = 0
    var variant = 0
    var fewer = false
    var choices: [Int]
    init(target: Int, other: Int = 0, goal: Int = 0, start: Int = 0, variant: Int = 0, fewer: Bool = false) {
        self.target = target; self.other = other; self.goal = goal; self.start = start; self.variant = variant; self.fewer = fewer
        choices = other > 0 ? [target, other].shuffled() : ([target] + (max(1, target - 2)...min(12, target + 2)).filter { $0 != target }.shuffled().prefix(2)).shuffled()
    }
    static func picnic(start: Int, goal: Int) -> Self {
        var lesson = Self(target: abs(goal - start), goal: goal, start: start)
        let maximum = goal > start ? 10 - start : start
        lesson.choices = ([lesson.target] + (1...maximum).filter { $0 != lesson.target }.shuffled().prefix(2)).shuffled()
        return lesson
    }
    var picnicAdds: Bool { goal > start }
    var picnicPrompt: String {
        "We have \(start). We need \(goal). How many should we \(picnicAdds ? "add" : "take away")?"
    }
    var picnicSuccess: String {
        "\(start) \(picnicAdds ? "plus" : "minus") \(target) makes \(goal). Just right for our picnic!"
    }
    static func treasure(start: Int, goal: Int) -> Self {
        precondition(start >= 0 && start < goal && goal <= 100 && start.isMultiple(of: 5) && goal.isMultiple(of: 5))
        var lesson = Self(target: goal - start, other: goal, goal: goal, start: start)
        let alternatives = stride(from: 0, through: 100, by: 5).filter { $0 != lesson.target }.shuffled().prefix(2)
        lesson.choices = ([lesson.target] + alternatives).shuffled()
        return lesson
    }
    var treasurePrompt: String {
        "We have \(start) coins. How many more will make \(goal)?"
    }
    var treasureSuccess: String {
        "\(start) plus \(target) makes \(goal). Both treasure piles match!"
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
        case .share: return lesson.picnicPrompt
        case .trail: return lesson.treasurePrompt
        case .more: return lesson.fewer ? "Which group has fewer \(lesson.food.plural)? Tap that group." : "Which group has more \(lesson.food.plural)? Tap that group."
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
        revealed = false; solved = false; feedback = ""
    }
    func clear() { guard !complete, !solved else { return }; count = 0; feedback = "" }
    func addTreasure(_ value: Int, toLeftPile: Bool) {
        guard kind == .trail, !solved, !complete, lesson.choices.contains(value) else { return }
        guard toLeftPile else { say("Drag your chest onto the left pile. That is the pile we are adding to."); return }
        choose(value)
    }
    func choose(_ value: Int) {
        guard [.share, .trail, .more, .tickets, .dots].contains(kind), !solved, !complete, lesson.choices.contains(value) else { return }
        if value == target {
            switch kind {
            case .share: win(lesson.picnicSuccess)
            case .trail: count = lesson.goal; win(lesson.treasureSuccess)
            case .more: win(lesson.fewer ? "Yes! That group has fewer \(lesson.food.plural)." : "Yes! That group has more \(lesson.food.plural).")
            case .tickets: win("One dot for each passenger. All aboard!")
            default: win("You found the twin: \(target) dots!")
            }
        } else {
            switch kind {
            case .share: say(lesson.picnicAdds ? "Count what we have. How many more will make the amount we need?" : "Count what we have. How many should we take away to leave the amount we need?")
            case .trail: say("Not quite. Try another chest. Count on by fives to make the piles match.")
            case .more: say("Count both groups carefully, then try again.")
            case .tickets: say("Match each passenger with one dot. Try another ticket.")
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
