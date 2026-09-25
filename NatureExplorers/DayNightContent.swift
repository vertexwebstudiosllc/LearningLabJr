import Foundation

enum RoutineTime: String { case day, night }
enum RoutineKind: String, CaseIterable { case find, collect, sequence }
struct RoutineItem: Identifiable {
    let id: String
    let name: String
    let art: String
    static let bank: [Self] = [
        .init(id: "curtains", name: "Curtains", art: "custom"),
        .init(id: "umbrella", name: "Umbrella", art: "umbrella.fill"),
        .init(id: "ball", name: "Ball", art: "soccerball"),
        .init(id: "apple", name: "Apple", art: "asset:AppleClean"),
        .init(id: "teddy", name: "Teddy bear", art: "teddybear.fill"),
        .init(id: "pillow", name: "Pillow", art: "custom"),
        .init(id: "shoes", name: "Shoes", art: "shoe.fill"),
        .init(id: "book", name: "Book", art: "book.closed.fill"),
        .init(id: "blanket", name: "Blanket", art: "custom"),
        .init(id: "toothbrush", name: "Toothbrush", art: "custom"),
        .init(id: "crayons", name: "Crayons", art: "custom"),
        .init(id: "spoon", name: "Spoon", art: "custom"),
        .init(id: "washcloth", name: "Washcloth or towel", art: "custom"),
        .init(id: "plate", name: "Plate", art: "custom"),
        .init(id: "bottle", name: "Water bottle", art: "waterbottle.fill"),
        .init(id: "hat", name: "Sun hat", art: "custom"),
        .init(id: "cup", name: "Cup", art: "cup.and.saucer.fill"),
        .init(id: "paper", name: "Paper", art: "doc.fill"),
        .init(id: "paintbrush", name: "Paintbrush", art: "paintbrush.fill"),
        .init(id: "block", name: "Block", art: "cube.fill"),
        .init(id: "shirt", name: "Pajama top", art: "tshirt.fill"),
        .init(id: "pants", name: "Pajama pants", art: "custom"),
        .init(id: "socks", name: "Socks", art: "custom"),
        .init(id: "water", name: "Water", art: "drop.fill"),
        .init(id: "soap", name: "Soap", art: "custom"),
        .init(id: "plant", name: "Plant", art: "leaf.fill"),
        .init(id: "wateringcan", name: "Watering can", art: "custom"),
        .init(id: "sun", name: "Sunny window", art: "sun.max.fill"),
        .init(id: "adult", name: "Grown-up", art: "person.2.fill"),
        .init(id: "tree", name: "Tree", art: "tree.fill"),
        .init(id: "chair", name: "Chair", art: "chair.fill"),
        .init(id: "breathe", name: "Gentle breeze", art: "wind"),
        .init(id: "heart", name: "Quiet moment", art: "heart.fill"),
        .init(id: "wave", name: "Wave goodnight", art: "hand.wave.fill"),
        .init(id: "lamp", name: "Lamp", art: "lamp.table.fill"),
        .init(id: "bed", name: "Bed", art: "bed.double.fill"),
    ]
    static func named(_ id: String) -> Self { bank.first { $0.id == id }! }
}
struct DayNightRoutine: Identifiable {
    let id: String
    let title: String
    let time: RoutineTime
    let kind: RoutineKind
    let destination: String
    let items: [String]
    let distractors: [String]
    let instructions: [String]
    let success: String
    var choices: [String] { items + distractors }
    static let invitation = "Let us explore day and night! We can practice daytime activities and cozy bedtime routines. Every family has its own routines."
    static let bank: [Self] = [
        .init(id: "curtains", title: "Hello, daylight", time: .day, kind: .find, destination: "window", items: ["curtains"], distractors: ["umbrella", "ball"], instructions: ["It is morning! Find the curtains so we can open them and let in daylight."], success: "You opened the curtains! Daylight can help us see our room."),
        .init(id: "breakfast", title: "Breakfast time", time: .day, kind: .find, destination: "table", items: ["apple"], distractors: ["teddy", "pillow"], instructions: ["It is breakfast time! Find the apple we can eat with our morning meal."], success: "You found the apple! Families enjoy many different foods at breakfast."),
        .init(id: "shoes", title: "Ready for a walk", time: .day, kind: .find, destination: "door", items: ["shoes"], distractors: ["book", "blanket"], instructions: ["We are going for a daytime walk with a grown-up. Find the shoes for our feet."], success: "Shoes on! We can explore outside together during the day."),
        .init(id: "teeth", title: "Brush before bed", time: .night, kind: .find, destination: "sink", items: ["toothbrush"], distractors: ["crayons", "spoon"], instructions: ["It is bedtime. Find the toothbrush so a grown-up can help us brush our teeth."], success: "That is the toothbrush! We brush in the morning and before bed, with help from a grown-up."),
        .init(id: "face", title: "Wash a sleepy face", time: .night, kind: .find, destination: "sink", items: ["washcloth"], distractors: ["ball", "book"], instructions: ["We are getting ready for bed. Find the soft washcloth to help wash our face."], success: "A soft washcloth can help us get clean. We can wash our face at other times, too!"),
        .init(id: "story", title: "A bedtime story", time: .night, kind: .find, destination: "bed", items: ["book"], distractors: ["shoes", "plate"], instructions: ["It is a quiet evening. Find a book to share with a grown-up before bed."], success: "A story can help us settle down. We can enjoy books during the day, too!"),
        .init(id: "bag", title: "Pack for the park", time: .day, kind: .collect, destination: "backpack", items: ["bottle", "hat", "shoes"], distractors: ["pillow"], instructions: ["Let us pack for a daytime trip! Move the water bottle, hat, and shoes into the backpack."], success: "Our bag is ready! A grown-up can help us choose what we need outside."),
        .init(id: "lunch", title: "Set our lunch table", time: .day, kind: .collect, destination: "table", items: ["plate", "cup", "spoon"], distractors: ["teddy"], instructions: ["It is lunchtime! Move the plate, cup, and spoon onto the table."], success: "The table is ready for lunch. We helped get ready for a daytime meal!"),
        .init(id: "art", title: "Make daytime art", time: .day, kind: .collect, destination: "artbox", items: ["crayons", "paper", "paintbrush"], distractors: ["toothbrush"], instructions: ["Let us make art this afternoon! Move the crayons, paper, and paintbrush into the art tray."], success: "Our art supplies are ready! We can make colorful pictures together."),
        .init(id: "tidy", title: "Put toys away", time: .night, kind: .collect, destination: "toybox", items: ["ball", "teddy", "block"], distractors: ["cup"], instructions: ["Playtime is finished for the evening. Move the ball, teddy bear, and block into the toy box."], success: "The toys are put away! Tidying helps us get ready for a quieter evening."),
        .init(id: "pajamas", title: "Cozy pajamas", time: .night, kind: .collect, destination: "basket", items: ["shirt", "pants", "socks"], distractors: ["apple"], instructions: ["Let us choose bedtime clothes! Move the pajama top, pajama pants, and socks into the basket."], success: "Our bedtime clothes are ready! Your family can choose what feels comfortable for sleep."),
        .init(id: "bed", title: "Make a cozy bed", time: .night, kind: .collect, destination: "bed", items: ["pillow", "blanket", "teddy"], distractors: ["plate"], instructions: ["Let us make our pretend bed cozy! Move the pillow, blanket, and teddy bear onto the bed."], success: "Our pretend bed is ready. Your grown-up helps you make your own sleeping space cozy."),
        .init(id: "hands", title: "Clean hands before lunch", time: .day, kind: .sequence, destination: "sink", items: ["water", "soap", "washcloth"], distractors: [], instructions: ["Before our daytime meal, we wash our hands with a grown-up. First, choose the water to wet our hands.", "Next, choose the soap. Pretend to rub our hands together with soap.", "Now choose the towel. We rinse off the soap with water, then dry our hands."], success: "We practiced wetting, washing, rinsing, and drying our hands before a meal!"),
        .init(id: "plant", title: "Care for our plant", time: .day, kind: .sequence, destination: "window", items: ["plant", "wateringcan", "sun"], distractors: [], instructions: ["It is daytime plant care! First, choose our plant and look at its soil with a grown-up.", "Our pretend plant needs water. Choose the watering can to give it a little drink.", "Now choose the sunny window. Our plant can get the light it needs there."], success: "We cared for our plant! A grown-up can help us learn when a real plant needs water."),
        .init(id: "outing", title: "Go outside together", time: .day, kind: .sequence, destination: "door", items: ["hat", "adult", "tree"], distractors: [], instructions: ["We are going outside on a sunny day. First, choose our sun hat.", "Next, choose the grown-up. We stay together when we go outside.", "Now choose the tree. We are ready to enjoy a little nature walk together!"], success: "We got ready and stayed with our grown-up. There is so much to notice outside in the daytime!"),
        .init(id: "bath", title: "An evening wash", time: .night, kind: .sequence, destination: "bath", items: ["adult", "soap", "washcloth"], distractors: [], instructions: ["It is time for an evening wash. First, choose the grown-up who stays with us and checks the water.", "Next, choose the soap. Our grown-up helps us wash and rinse.", "Now choose the towel. Our grown-up helps us dry off."], success: "Clean and cozy! Some families wash in the evening, and some wash earlier in the day."),
        .init(id: "calm", title: "Slow down for bedtime", time: .night, kind: .sequence, destination: "bed", items: ["chair", "breathe", "heart"], distractors: [], instructions: ["It is bedtime wind-down time. First, choose the chair and sit comfortably with your grown-up.", "Next, choose the gentle breeze. Let us take an easy breath in and out together.", "Now choose the heart. Relax your hands and enjoy a quiet moment."], success: "We took a quiet pause together. Calm moments can help us get ready to rest."),
        .init(id: "goodnight", title: "Say goodnight", time: .night, kind: .sequence, destination: "bed", items: ["wave", "lamp", "bed"], distractors: [], instructions: ["We are ready for bed. First, choose the waving hand to say goodnight to our grown-up.", "Next, choose the lamp. Our grown-up can make the room dim and cozy.", "Now choose the bed. It is time to settle down and rest."], success: "Goodnight! Rest helps our bodies get ready for another day."),
    ]
    static var narration: [String] {
        [invitation] + bank.flatMap { routine in
            routine.instructions + routine.instructions.map { "Let's try again. " + $0 } + [routine.success]
        }
    }
}

struct DayNightPlay {
    let rounds: [DayNightRoutine]
    let choices: [[String]]
    private(set) var index = 0
    private(set) var collected: Set<String> = []
    private(set) var step = 0
    private(set) var selected: String?
    private(set) var needsHelp = false
    var complete: Bool { index == rounds.count }
    var current: DayNightRoutine { rounds[min(index, rounds.count - 1)] }
    var solved: Bool { current.kind == .sequence ? step == current.items.count : collected.count == current.items.count }
    var instruction: String { current.instructions[min(step, current.instructions.count - 1)] }
    var prompt: String { solved ? current.success : (needsHelp ? "Let's try again. " : "") + instruction }
    init(previousFirst: String = "", previousLevel: String = "") {
        var deck = RoutineKind.allCases.flatMap { kind in DayNightRoutine.bank.filter { $0.kind == kind }.shuffled() }
        if [previousFirst, previousLevel].contains(deck[0].id),
           let replacement = (1..<6).first(where: { ![previousFirst, previousLevel].contains(deck[$0].id) }) {
            deck.swapAt(0, replacement)
        }
        rounds = deck
        choices = deck.map { $0.choices.shuffled() }
    }
    mutating func choose(_ id: String, in level: String) {
        guard !complete, !solved, current.id == level, current.choices.contains(id) else { return }
        if current.kind == .collect {
            guard !collected.contains(id) else { return }
            selected = id; needsHelp = false
        } else {
            let expected = current.items[current.kind == .sequence ? step : 0]
            guard id == expected else { needsHelp = true; return }
            collected.insert(id); needsHelp = false
            if current.kind == .sequence { step += 1 }
        }
    }
    @discardableResult mutating func place(_ id: String, in level: String) -> Bool {
        guard !complete, !solved, current.id == level, current.kind == .collect,
              current.choices.contains(id), !collected.contains(id) else { return false }
        guard current.items.contains(id) else { needsHelp = true; selected = nil; return false }
        collected.insert(id); selected = nil; needsHelp = false
        return true
    }
    @discardableResult mutating func drop(_ payload: String) -> Bool {
        let parts = payload.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
        guard parts.count == 2 else { return false }
        return place(parts[1], in: parts[0])
    }
    mutating func advance(from level: String) {
        guard !complete, solved, current.id == level else { return }
        index += 1; collected = []; step = 0; selected = nil; needsHelp = false
    }
}
