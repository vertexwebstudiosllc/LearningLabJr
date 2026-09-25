import SwiftUI

struct CozyRoutineStep: Identifiable {
    enum Kind: String { case wash, scrub, dress, pages, tap, walk, pack }
    let id: String
    let title: String
    let symbol: String
    let kind: Kind
    let clue: String
    let instruction: String
    let response: String
    var question: String { "What comes next in Teddy's plan? " + clue }
    var goal: Int { kind == .wash ? 5 : [.scrub, .pages, .walk, .pack].contains(kind) ? 3 : 1 }
    var items: [String] {
        switch id {
        case "beachbag": return ["drop.fill", "rectangle.fill", "soccerball"]
        case "picnicbag": return ["drop.fill", "carrot.fill", "rectangle.fill"]
        case "cleanup": return ["doc.fill", "doc.fill", "doc.fill"]
        case "toys": return ["teddybear.fill", "car.side.fill", "soccerball"]
        default: return [symbol, symbol, symbol]
        }
    }
    static let bank: [CozyRoutineStep] = [
        .init(id: "wash", title: "Wash and dry hands", symbol: "hands.sparkles.fill", kind: .wash, clue: "Find washing hands.", instruction: "Help Teddy wet, soap, rub, rinse, and dry.", response: "Teddy practiced washing and drying hands."),
        .init(id: "teeth", title: "Brush teeth", symbol: "mouth.fill", kind: .scrub, clue: "Find brushing teeth.", instruction: "Tap three sparkles to pretend to brush with a grown-up.", response: "We practiced pretend brushing. A grown-up helps with real brushing."),
        .init(id: "pajamas", title: "Cozy pajamas", symbol: "tshirt.fill", kind: .dress, clue: "Find cozy pajamas.", instruction: "Drag the pajamas onto Teddy.", response: "Cozy pajamas are on."),
        .init(id: "book", title: "Share a story", symbol: "book.fill", kind: .pages, clue: "Find the storybook.", instruction: "Tap the book to turn three pages together.", response: "A little story shared together."),
        .init(id: "bed", title: "Settle into bed", symbol: "bed.double.fill", kind: .tap, clue: "Find the bed.", instruction: "Tap the moon to help Teddy settle into bed.", response: "Good night, Teddy. Time for a cozy rest."),
        .init(id: "tell", title: "Ask a grown-up", symbol: "person.2.fill", kind: .tap, clue: "Find grown-up help.", instruction: "Tap the grown-up to ask for bathroom help.", response: "A trusted grown-up is here to help."),
        .init(id: "potty", title: "Try the potty", symbol: "toilet.fill", kind: .tap, clue: "Find the potty.", instruction: "Tap the potty for a pretend try. Watching counts, too.", response: "Teddy practiced a potty visit. There is no rush."),
        .init(id: "wipe", title: "Wipe with help", symbol: "doc.fill", kind: .tap, clue: "Find toilet paper.", instruction: "Tap the paper to ask a grown-up for wiping help.", response: "A grown-up helps Teddy get clean."),
        .init(id: "clothes", title: "Clothes on", symbol: "tshirt.fill", kind: .dress, clue: "Find Teddy's clothes.", instruction: "Drag the clothes onto Teddy.", response: "Teddy is dressed and comfortable."),
        .init(id: "flush", title: "Flush the toilet", symbol: "water.waves", kind: .tap, clue: "Find the flush button.", instruction: "Tap the button to pretend to flush.", response: "Whoosh! Teddy practiced flushing."),
        .init(id: "raincoat", title: "Raincoat", symbol: "jacket.fill", kind: .dress, clue: "Find the raincoat.", instruction: "Drag the raincoat onto Teddy.", response: "A raincoat helps keep Teddy dry."),
        .init(id: "boots", title: "Rain boots", symbol: "shoe.fill", kind: .dress, clue: "Find the rain boots.", instruction: "Drag the rain boots onto Teddy.", response: "Rain boots are ready for puddles."),
        .init(id: "umbrella", title: "Umbrella", symbol: "umbrella.fill", kind: .dress, clue: "Find the umbrella.", instruction: "Drag the umbrella over Teddy.", response: "An umbrella helps keep the rain off."),
        .init(id: "walk", title: "Go with a grown-up", symbol: "figure.walk", kind: .walk, clue: "Find walking together.", instruction: "Tap the glowing footprints to go with a grown-up.", response: "Teddy stays with a grown-up on the way."),
        .init(id: "warmcoat", title: "Warm coat", symbol: "jacket.fill", kind: .dress, clue: "Find the warm coat.", instruction: "Drag the warm coat onto Teddy.", response: "A warm coat is ready for the cold."),
        .init(id: "hat", title: "Hat and mittens", symbol: "hat.cap.fill", kind: .dress, clue: "Find a warm hat and mittens.", instruction: "Drag the warm hat and mittens onto Teddy.", response: "Teddy has cozy hands and a warm head."),
        .init(id: "snowboots", title: "Snow boots", symbol: "shoe.fill", kind: .dress, clue: "Find the snow boots.", instruction: "Drag the snow boots onto Teddy.", response: "Warm boots are ready for the snow."),
        .init(id: "suncream", title: "Sun protection", symbol: "sun.max.fill", kind: .scrub, clue: "Find sun protection.", instruction: "Tap the three suns. Pretend a grown-up is helping with sunscreen.", response: "A grown-up helps Teddy get ready for sunshine."),
        .init(id: "sunhat", title: "Sun hat", symbol: "hat.widebrim.fill", kind: .dress, clue: "Find the sun hat.", instruction: "Drag the sun hat onto Teddy.", response: "A sun hat gives Teddy some shade."),
        .init(id: "beachbag", title: "Pack a beach bag", symbol: "bag.fill", kind: .pack, clue: "Find the beach bag.", instruction: "Drag the water, towel, and toy into the beach bag.", response: "The beach bag has water, a towel, and a toy."),
        .init(id: "shade", title: "Rest in the shade", symbol: "beach.umbrella.fill", kind: .tap, clue: "Find a shady spot.", instruction: "Tap the beach umbrella to choose a shady place with a grown-up.", response: "A shady spot is ready. Stay with your grown-up at the beach."),
        .init(id: "breakfast", title: "Breakfast together", symbol: "carrot.fill", kind: .tap, clue: "Find breakfast.", instruction: "Tap the bowl to sit for breakfast with a grown-up.", response: "Teddy enjoys breakfast at the table."),
        .init(id: "hair", title: "Brush hair gently", symbol: "comb.fill", kind: .scrub, clue: "Find the hairbrush.", instruction: "Tap three sparkles to pretend to brush gently.", response: "A grown-up can help with tangles. Teddy can ask for a pause."),
        .init(id: "picnicbag", title: "Pack a picnic", symbol: "basket.fill", kind: .pack, clue: "Find the picnic basket.", instruction: "Drag the water, snack, and blanket into the basket.", response: "Water, a snack, and a blanket are packed."),
        .init(id: "cleanup", title: "Clean up together", symbol: "trash.fill", kind: .pack, clue: "Find tidying up.", instruction: "Drag the three wrappers into the bin.", response: "We leave our picnic spot tidy."),
        .init(id: "shoesoff", title: "Shoes off", symbol: "shoe.fill", kind: .dress, clue: "Find taking shoes off.", instruction: "Drag the shoes to their storage spot.", response: "Shoes have a place by the door."),
        .init(id: "coatoff", title: "Hang up a coat", symbol: "jacket.fill", kind: .dress, clue: "Find hanging up the coat.", instruction: "Drag the coat to its hook.", response: "The coat is ready for another day."),
        .init(id: "toys", title: "Put toys away", symbol: "shippingbox.fill", kind: .pack, clue: "Find putting toys away.", instruction: "Drag the three toys into their box.", response: "The toys are away. Our space is ready for a cozy pause."),
    ]
    static func named(_ id: String) -> CozyRoutineStep { bank.first { $0.id == id }! }
}

struct CozyRoutine: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let steps: [String]
    let introduction: String
    let outcome: String
    static let bank: [CozyRoutine] = [
        .init(id: "bedtime", title: "Bedtime", symbol: "moon.stars.fill", steps: ["wash", "teeth", "pajamas", "book", "bed"], introduction: "Help Teddy get ready for a cozy bedtime.", outcome: "Teddy is ready to rest. You practiced a bedtime path!"),
        .init(id: "bathroom", title: "Bathroom time", symbol: "toilet.fill", steps: ["tell", "potty", "wipe", "clothes", "flush", "wash"], introduction: "Practice a pretend bathroom visit with grown-up help.", outcome: "You practiced asking for help and a gentle bathroom routine."),
        .init(id: "rain", title: "A rainy day", symbol: "cloud.rain.fill", steps: ["raincoat", "boots", "umbrella", "walk"], introduction: "Help Teddy get ready for a rainy walk.", outcome: "Teddy is ready for the rain with a grown-up."),
        .init(id: "snow", title: "A snowy day", symbol: "cloud.snow.fill", steps: ["warmcoat", "hat", "snowboots", "walk"], introduction: "Help Teddy dress for a snowy outing.", outcome: "Teddy is dressed for a snowy outing with a grown-up."),
        .init(id: "beach", title: "A beach day", symbol: "beach.umbrella.fill", steps: ["suncream", "sunhat", "beachbag", "shade"], introduction: "Help Teddy get ready for a beach day with a grown-up.", outcome: "Teddy is ready for a beach day, with shade and a grown-up nearby."),
        .init(id: "morning", title: "Good morning", symbol: "sun.max.fill", steps: ["clothes", "breakfast", "teeth", "hair"], introduction: "Help Teddy start a brand-new day.", outcome: "Teddy is ready for a new day. Good morning!"),
        .init(id: "picnic", title: "A little picnic", symbol: "basket.fill", steps: ["wash", "picnicbag", "walk", "cleanup"], introduction: "Help Teddy get ready for a picnic and tidy up afterward.", outcome: "You planned a picnic and cared for the shared space."),
        .init(id: "home", title: "Coming home", symbol: "house.fill", steps: ["shoesoff", "coatoff", "wash", "toys"], introduction: "Help Teddy settle in after an outing.", outcome: "Teddy is home, clean, and ready for a cozy pause."),
    ]
    static let welcome = "Choose a path for Teddy. We can practice little steps together!"
    static let retry = "That is a step for another moment. Listen to what comes next in Teddy's plan."
    static let actionRetry = "Try the glowing spot. We can take one little step at a time."
    static let pause = "A pause is okay. You can choose a different path or try this one another time."
    static let completion = "We did it together! You can play again or choose all done."
    static var narration: [String] {
        [welcome, retry, actionRetry, pause, completion] + bank.flatMap { [$0.title, $0.introduction, $0.outcome] }
        + CozyRoutineStep.bank.flatMap { [$0.title, $0.question, $0.instruction, $0.response] }
    }
}

struct CozyRoutinePlay {
    enum Phase { case paths, introduction, choosing, acting, feedback, finished, paused, complete }
    private(set) var phase = Phase.paths
    private(set) var routine: CozyRoutine?
    private(set) var index = 0
    private(set) var actions = 0
    private(set) var used = Set<Int>()
    private(set) var choices: [String] = []
    private(set) var completed = Set<String>()
    var current: CozyRoutineStep { .named(routine?.steps[min(index, (routine?.steps.count ?? 1) - 1)] ?? "wash") }
    var token: String { (routine?.id ?? "") + ":" + String(index) + ":" + String(actions) }
    var prompt: String {
        switch phase {
        case .paths: return CozyRoutine.welcome
        case .introduction: return routine!.introduction
        case .choosing: return current.question
        case .acting: return current.instruction
        case .feedback: return current.response
        case .finished: return routine!.outcome
        case .paused: return CozyRoutine.pause
        case .complete: return CozyRoutine.completion
        }
    }
    mutating func choosePath(_ id: String) {
        guard phase == .paths, let path = CozyRoutine.bank.first(where: { $0.id == id }) else { return }
        routine = path; index = 0; actions = 0; used = []; phase = .introduction
    }
    private mutating func prepareStep() {
        actions = 0; used = []
        var symbols: Set<String> = [current.symbol]
        var alternatives: [String] = []
        for candidate in CozyRoutineStep.bank.shuffled() where candidate.kind != current.kind {
            guard symbols.insert(candidate.symbol).inserted else { continue }
            alternatives.append(candidate.id)
            if alternatives.count == 2 { break }
        }
        choices = ([current.id] + alternatives).shuffled()
        phase = .choosing
    }
    mutating func start() { guard phase == .introduction else { return }; prepareStep() }
    @discardableResult mutating func chooseStep(_ id: String) -> Bool {
        guard phase == .choosing, id == current.id else { return false }
        phase = .acting; return true
    }
    @discardableResult mutating func act(_ value: Int, token: String) -> Bool {
        guard phase == .acting, token == self.token else { return false }
        let valid: Bool
        if [.pack, .scrub].contains(current.kind) { valid = (0..<current.goal).contains(value) && !used.contains(value) }
        else { valid = value == actions }
        guard valid else { return false }
        used.insert(value); actions += 1
        if actions == current.goal { phase = .feedback }
        return true
    }
    mutating func next() {
        guard phase == .feedback, let routine else { return }
        if index == routine.steps.count - 1 { completed.insert(routine.id); phase = .finished }
        else { index += 1; prepareStep() }
    }
    mutating func pause() {
        guard [.introduction, .choosing, .acting, .feedback].contains(phase) else { return }; phase = .paused
    }
    mutating func paths() {
        guard [.finished, .paused].contains(phase) else { return }
        phase = .paths; routine = nil; index = 0; actions = 0; used = []; choices = []
    }
    mutating func finish() { guard phase == .finished || phase == .paused else { return }; phase = .complete }
}
