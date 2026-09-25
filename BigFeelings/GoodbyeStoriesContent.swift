import SwiftUI

struct GoodbyeWords: Identifiable {
    let id: Int
    let title: String
    let symbol: String
    let fits: Bool
}
struct GoodbyeStory: Identifiable {
    enum Kind: String { case night, school, home, park, visit, bathroom }
    let id: String
    let title: String
    let kind: Kind
    let destination: String
    let symbol: String
    let movePrompt: String
    let question: String
    let retry: String
    let choices: [GoodbyeWords]
    let actionTitle: String
    let actionPrompt: String
    let outcome: String
    var goal: Int { kind == .school || kind == .bathroom ? 2 : 1 }
    static let bank: [GoodbyeStory] = [
        .init(id: "bedtime", title: "Goodnight time", kind: .night, destination: "Cozy bed", symbol: "bed.double.fill", movePrompt: "It is bedtime. Move our buddy to the cozy bed.", question: "Our buddy is ready to rest. Which words fit bedtime?", retry: "These are bedtime words. Try a goodnight message.", choices: [
            .init(id: 0, title: "Good night!", symbol: "moon.fill", fits: true),
            .init(id: 1, title: "Sweet dreams!", symbol: "star.fill", fits: true),
            .init(id: 2, title: "Have fun at school!", symbol: "backpack.fill", fits: false),
        ], actionTitle: "Dim the light", actionPrompt: "Tap the lamp to dim the light.", outcome: "Our buddy is tucked in. You practiced a gentle goodnight."),
        .init(id: "school", title: "School drop-off", kind: .school, destination: "School door", symbol: "building.2.fill", movePrompt: "Move our buddy to the school door. A trusted teacher is waiting.", question: "It is time for school. What can we say to our grown-up?", retry: "We are saying goodbye for a school day. Try words for drop-off.", choices: [
            .init(id: 0, title: "Bye! See you at pick-up time!", symbol: "clock.fill", fits: true),
            .init(id: 1, title: "Have a good day!", symbol: "sun.max.fill", fits: true),
            .init(id: 2, title: "Good night!", symbol: "moon.fill", fits: false),
        ], actionTitle: "Start pretend playtime", actionPrompt: "Tap the toys for pretend playtime with the teacher.", outcome: "Hello again! In our story, pick-up time came and the grown-up returned."),
        .init(id: "daycare", title: "Daycare goodbye", kind: .school, destination: "Playroom door", symbol: "door.left.hand.open", movePrompt: "Move our buddy to the playroom door. A trusted caregiver will stay.", question: "Our buddy is ready for daycare. Which goodbye fits?", retry: "We are starting daycare. Choose words for a daytime goodbye.", choices: [
            .init(id: 0, title: "Bye! See you later!", symbol: "hand.wave.fill", fits: true),
            .init(id: 1, title: "See you at pick-up time!", symbol: "clock.fill", fits: true),
            .init(id: 2, title: "Time to flush!", symbol: "water.waves", fits: false),
        ], actionTitle: "Explore the play corner", actionPrompt: "Tap the toys for pretend playtime with the caregiver.", outcome: "Hello again! Our buddy and grown-up are together at pretend pick-up time."),
        .init(id: "dinner", title: "Time to go home", kind: .home, destination: "Home doorway", symbol: "house.fill", movePrompt: "Dinner is ready. Move our buddy toward home, with a grown-up.", question: "It is time to leave our friends for dinner. What can we say?", retry: "We are leaving our friends for dinner. Try a friendly goodbye.", choices: [
            .init(id: 0, title: "Bye, friends! Dinner time!", symbol: "house.fill", fits: true),
            .init(id: 1, title: "Thanks for playing!", symbol: "heart.fill", fits: true),
            .init(id: 2, title: "Good morning!", symbol: "sun.max.fill", fits: false),
        ], actionTitle: "Go inside together", actionPrompt: "Tap the doorway to go inside with a grown-up.", outcome: "Our buddy went in for dinner. We can thank friends when playtime ends."),
        .init(id: "park", title: "Leaving the park", kind: .park, destination: "Park gate", symbol: "tree.fill", movePrompt: "Park playtime is ending. Move our buddy to the gate with a grown-up.", question: "What could we say as we leave the park?", retry: "Park playtime is ending. Try goodbye words for our friends.", choices: [
            .init(id: 0, title: "Bye! That was fun!", symbol: "hand.wave.fill", fits: true),
            .init(id: 1, title: "See you another day!", symbol: "heart.fill", fits: true),
            .init(id: 2, title: "Time to flush!", symbol: "water.waves", fits: false),
        ], actionTitle: "Wave at the gate", actionPrompt: "Tap the waving hand to wave goodbye together.", outcome: "You practiced leaving the park with a friendly wave and a grown-up."),
        .init(id: "visit", title: "A visit ends", kind: .visit, destination: "Front doorway", symbol: "door.left.hand.open", movePrompt: "Our visit is ending. Move our buddy to the front door with a grown-up.", question: "What could we say after a visit with someone we care about?", retry: "Our visit is ending. Choose a kind goodbye.", choices: [
            .init(id: 0, title: "Thank you for having us!", symbol: "heart.fill", fits: true),
            .init(id: 1, title: "Bye! See you another time!", symbol: "hand.wave.fill", fits: true),
            .init(id: 2, title: "Good morning!", symbol: "sun.max.fill", fits: false),
        ], actionTitle: "Send a little wave", actionPrompt: "Tap the hand for a goodbye wave. A wave is enough.", outcome: "You thanked someone and said goodbye. Hugs are always a choice."),
        .init(id: "poo", title: "Bye-bye, poo", kind: .bathroom, destination: "Handwashing spot", symbol: "hands.sparkles.fill", movePrompt: "Our buddy is done on the potty. Move them to the handwashing spot.", question: "We are finished with the potty. Which goodbye fits?", retry: "This is a potty goodbye. Try words for being all done.", choices: [
            .init(id: 0, title: "Bye-bye, poo!", symbol: "hand.wave.fill", fits: true),
            .init(id: 1, title: "All done! Time to flush!", symbol: "water.waves", fits: true),
            .init(id: 2, title: "Have fun at school!", symbol: "backpack.fill", fits: false),
        ], actionTitle: "Flush the pretend toilet", actionPrompt: "Tap the flush button and watch the water swirl.", outcome: "All done! We practiced flushing and washing hands with grown-up help."),
        .init(id: "pee", title: "Bye-bye, pee", kind: .bathroom, destination: "Handwashing spot", symbol: "hands.sparkles.fill", movePrompt: "Our buddy is done on the potty. Move them to the handwashing spot.", question: "We are finished with the potty. Which goodbye fits?", retry: "This is a potty goodbye. Try words for being all done.", choices: [
            .init(id: 0, title: "Bye-bye, pee!", symbol: "drop.fill", fits: true),
            .init(id: 1, title: "All done! Time to flush!", symbol: "water.waves", fits: true),
            .init(id: 2, title: "Good night!", symbol: "moon.fill", fits: false),
        ], actionTitle: "Flush the pretend toilet", actionPrompt: "Tap the flush button and watch the water swirl.", outcome: "All done! We practiced flushing and washing hands with grown-up help."),
    ]
    static let welcome = "Choose a pretend goodbye story. Your real grown-up stays with you while we play."
    static let pickup = "It is pretend pick-up time. Tap the door to say hello again."
    static let wash = "Now wash and dry hands with a grown-up. Tap the sink to pretend together."
    static let paused = "We can take a break. Choose another story whenever you are ready."
    static let completion = "We did it together! You can play again or choose all done."
    static var narration: [String] {
        var lines = [welcome, pickup, wash, paused, completion]
        for story in bank {
            lines.append(contentsOf: [story.title, story.movePrompt, story.question, story.retry, story.outcome])
            lines.append(contentsOf: story.choices.map(\.title))
            for choice in story.choices where choice.fits {
                lines.append(choice.title + " " + story.actionPrompt)
            }
        }
        return lines
    }
}

struct GoodbyePlay {
    enum Phase { case stories, moving, words, action, ending, paused, complete }
    private(set) var phase = Phase.stories
    private(set) var story: GoodbyeStory?
    private(set) var buddy: TogetherFriend?
    private(set) var choices: [GoodbyeWords] = []
    private(set) var selected: GoodbyeWords?
    private(set) var actions = 0
    private(set) var moved = false
    private(set) var completed = Set<String>()
    private var buddies = TogetherFriend.bank.shuffled()
    private var lastBuddy = ""
    private(set) var session = UUID()
    var dragToken: String { session.uuidString }
    var prompt: String {
        switch phase {
        case .stories: return GoodbyeStory.welcome
        case .moving: return story!.movePrompt
        case .words: return story!.question
        case .action:
            if actions == 1 { return story!.kind == .school ? GoodbyeStory.pickup : GoodbyeStory.wash }
            return selected!.title + " " + story!.actionPrompt
        case .ending: return story!.outcome
        case .paused: return GoodbyeStory.paused
        case .complete: return GoodbyeStory.completion
        }
    }
    mutating func chooseStory(_ id: String) {
        guard phase == .stories, let story = GoodbyeStory.bank.first(where: { $0.id == id }) else { return }
        if buddies.isEmpty {
            buddies = TogetherFriend.bank.shuffled()
            if buddies[0].id == lastBuddy { buddies.swapAt(0, Int.random(in: 1..<buddies.count)) }
        }
        self.story = story; buddy = buddies.removeFirst(); lastBuddy = buddy!.id
        choices = story.choices.shuffled(); selected = nil; actions = 0; moved = false; session = UUID(); phase = .moving
    }
    @discardableResult mutating func move(_ token: String) -> Bool {
        guard phase == .moving, token == dragToken else { return false }
        moved = true; phase = .words; return true
    }
    @discardableResult mutating func say(_ id: Int) -> Bool {
        guard phase == .words, let option = choices.first(where: { $0.id == id }), option.fits else { return false }
        selected = option; phase = .action; return true
    }
    @discardableResult mutating func act(_ step: Int, session: UUID) -> Bool {
        guard phase == .action, self.session == session, step == actions, let story else { return false }
        actions += 1
        if actions == story.goal { completed.insert(story.id); phase = .ending }
        return true
    }
    mutating func pause() { guard [.moving, .words, .action].contains(phase) else { return }; phase = .paused }
    mutating func stories() {
        guard [.ending, .paused].contains(phase) else { return }
        phase = .stories; story = nil; buddy = nil; choices = []; selected = nil; moved = false; actions = 0
    }
    mutating func finish() { guard [.ending, .paused].contains(phase) else { return }; phase = .complete }
}
