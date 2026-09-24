import SwiftUI
import Combine

enum CountingActivity: String, CaseIterable {
    case share, trail, more, tickets
    var title: String {
        switch self {
        case .share: return "Picnic Share"
        case .trail: return "Treasure Trail"
        case .more: return "Which Has More?"
        case .tickets: return "Ticket Train"
        }
    }
    var completion: String {
        switch self {
        case .share: return "You solved ten picnic puzzles with adding and taking away. What a helpful picnic partner!"
        case .trail: return "You made every treasure pile match! Great adding by fives!"
        case .more: return "You compared every group. You found more and fewer!"
        case .tickets: return "Every train has matching tickets. All aboard, counting explorer!"
        }
    }
    func levels() -> [CountingLesson] {
        var result = quantityLevels()
        let foods = countingPictureCycle(NumberPicnicFood.bank, count: result.count)
        let pairs = self == .more ? countingFruitPairs(count: result.count) : []
        let animals = countingPictureCycle(TouchCountAnimal.bank, count: result.count)
        let themes = countingPictureCycle(CountingTheme.bank, count: result.count)
        for index in result.indices {
            result[index].food = self == .more ? pairs[index].0 : foods[index]
            if self == .more { result[index].comparisonFood = pairs[index].1 }
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
        case .tickets: return (2...9).flatMap { n in (0..<3).map { CountingLesson(target: n, variant: $0) } }
        }
    }
}

struct CountingLesson {
    let target: Int
    var food = NumberPicnicFood.bank[0]
    var comparisonFood = NumberPicnicFood.bank[1]
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
    func comparisonFood(for amount: Int) -> NumberPicnicFood { amount == target ? food : comparisonFood }
}

@MainActor
final class CountingPlay: ObservableObject {
    let kind: CountingActivity
    @Published private(set) var levels: [CountingLesson]
    @Published private(set) var round = 0
    @Published private(set) var count = 0
    @Published private(set) var solved = false
    @Published private(set) var complete = false
    @Published private(set) var feedback = ""
    @Published private(set) var feedbackRevision = 0
    var total: Int { levels.count }
    var lesson: CountingLesson { levels[round] }
    var target: Int { lesson.target }
    init(kind: CountingActivity) { self.kind = kind; levels = kind.levels(); resetRound() }
    var prompt: String {
        switch kind {
        case .share: return lesson.picnicPrompt
        case .trail: return lesson.treasurePrompt
        case .more: return lesson.fewer ? "Which group has fewer pieces of fruit? Tap that group." : "Which group has more pieces of fruit? Tap that group."
        case .tickets: return "Choose a ticket with exactly one dot for each passenger."
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
        count = lesson.start
        solved = false; feedback = ""
    }
    func addTreasure(_ value: Int, toLeftPile: Bool) {
        guard kind == .trail, !solved, !complete, lesson.choices.contains(value) else { return }
        guard toLeftPile else { say("Drag your chest onto the left pile. That is the pile we are adding to."); return }
        choose(value)
    }
    func choose(_ value: Int) {
        guard [.share, .trail, .more, .tickets].contains(kind), !solved, !complete, lesson.choices.contains(value) else { return }
        if value == target {
            switch kind {
            case .share: win(lesson.picnicSuccess)
            case .trail: count = lesson.goal; win(lesson.treasureSuccess)
            case .more: win(lesson.fewer ? "Yes! That group has fewer pieces of fruit." : "Yes! That group has more pieces of fruit.")
            case .tickets: win("One dot for each passenger. All aboard!")
            default: break
            }
        } else {
            switch kind {
            case .share: say(lesson.picnicAdds ? "Count what we have. How many more will make the amount we need?" : "Count what we have. How many should we take away to leave the amount we need?")
            case .trail: say("Not quite. Try another chest. Count on by fives to make the piles match.")
            case .more: say("Count both groups carefully, then try again.")
            case .tickets: say("Match each passenger with one dot. Try another ticket.")
            default: break
            }
        }
    }
}
