import SwiftUI

struct SolutionTool: Identifiable {
    let id: String
    let title: String
    let symbol: String
    static let bank: [SolutionTool] = [
        .init(id: "adult", title: "Grown-up help", symbol: "person.2.fill"),
        .init(id: "repair", title: "Toy repair kit", symbol: "wrench.and.screwdriver.fill"),
        .init(id: "book", title: "Storybook", symbol: "book.closed.fill"),
        .init(id: "crayons", title: "Crayons", symbol: "pencil.tip.crop.circle.fill"),
        .init(id: "coat", title: "Warm coat", symbol: "jacket.fill"),
        .init(id: "hat", title: "Warm hat", symbol: "hat.cap.fill"),
        .init(id: "cloth", title: "Soft cloth", symbol: "square.fill"),
        .init(id: "box", title: "Storage box", symbol: "shippingbox.fill"),
        .init(id: "water", title: "Water", symbol: "drop.fill"),
        .init(id: "can", title: "Watering can", symbol: "spigot.fill"),
        .init(id: "soap", title: "Soap", symbol: "bubbles.and.sparkles.fill"),
        .init(id: "towel", title: "Towel", symbol: "rectangle.fill"),
        .init(id: "umbrella", title: "Umbrella", symbol: "umbrella.fill"),
        .init(id: "boots", title: "Rain boots", symbol: "shoe.fill"),
        .init(id: "snack", title: "Snack", symbol: "carrot.fill"),
        .init(id: "cup", title: "Drinking cup", symbol: "cup.and.saucer.fill"),
        .init(id: "blanket", title: "Cozy blanket", symbol: "bed.double.fill"),
        .init(id: "lamp", title: "Lamp", symbol: "lamp.desk.fill"),
        .init(id: "glue", title: "Glue stick", symbol: "pencil.tip"),
        .init(id: "paper", title: "Paper", symbol: "doc.fill"),
        .init(id: "basket", title: "Basket", symbol: "basket.fill"),
        .init(id: "ball", title: "Soft ball", symbol: "soccerball"),
        .init(id: "brush", title: "Hairbrush", symbol: "comb.fill"),
        .init(id: "ramp", title: "Toy ramp", symbol: "triangle.fill"),
    ]
    static func named(_ id: String) -> SolutionTool { bank.first { $0.id == id }! }
}

struct SolutionProblem: Identifiable {
    let id: String
    let title: String
    let question: String
    let before: String
    let after: String
    let setting: String
    let required: [String]
    let extras: [String]
    let resolution: String
    static let bank: [SolutionProblem] = [
        .init(id: "toy", title: "A wobbly toy", question: "The toy car has a loose wheel. Find a grown-up and a toy repair kit.", before: "car.side.hill.down.fill", after: "car.side.fill", setting: "room", required: ["adult", "repair"], extras: ["umbrella", "snack"], resolution: "You found a grown-up and a repair kit. The grown-up fixes the toy. Ready to roll!"),
        .init(id: "rain", title: "Rainy-day play", question: "Rain keeps our play inside. Find a storybook and crayons for indoor fun.", before: "cloud.rain.fill", after: "book.fill", setting: "rain", required: ["book", "crayons"], extras: ["can", "boots"], resolution: "A story and some drawing make a fun rainy day!"),
        .init(id: "winter", title: "Winter is coming", question: "It is cold outside. Find a warm coat and a hat.", before: "snowflake", after: "figure.arms.open", setting: "snow", required: ["coat", "hat"], extras: ["ball", "can"], resolution: "A coat and hat help us feel warm outside."),
        .init(id: "spill", title: "A little spill", question: "Water spilled on the table. Find a soft cloth to wipe it up.", before: "drop.fill", after: "sparkles", setting: "room", required: ["cloth"], extras: ["book", "hat", "ball"], resolution: "Wipe, wipe! The table is dry again."),
        .init(id: "toys", title: "A busy floor", question: "Toys cover the floor. Find a storage box to make a clear path.", before: "teddybear.fill", after: "shippingbox.fill", setting: "room", required: ["box"], extras: ["cup", "umbrella", "soap"], resolution: "The toys have a place, and our path is clear."),
        .init(id: "plant", title: "A thirsty plant", question: "The soil feels dry. Find a watering can and water for the plant.", before: "leaf", after: "leaf.fill", setting: "garden", required: ["can", "water"], extras: ["crayons", "blanket"], resolution: "A little water helps our plant grow."),
        .init(id: "hands", title: "Muddy hands", question: "Our hands are muddy. Find soap and water to wash them.", before: "hand.raised.fingers.spread.fill", after: "hands.sparkles.fill", setting: "garden", required: ["soap", "water"], extras: ["glue", "book"], resolution: "Rub with soap, rinse with water. Clean hands!"),
        .init(id: "puddle", title: "Puddles outside", question: "It is raining on our walk. Find an umbrella and rain boots.", before: "cloud.rain.fill", after: "umbrella.fill", setting: "rain", required: ["umbrella", "boots"], extras: ["paper", "lamp"], resolution: "An umbrella and rain boots help us enjoy a rainy walk."),
        .init(id: "hungry", title: "Snack time", question: "Our tummy feels hungry. Find a snack to eat with a grown-up.", before: "figure.child", after: "carrot.fill", setting: "room", required: ["snack"], extras: ["cloth", "brush", "ramp"], resolution: "We sit with a grown-up and enjoy a snack."),
        .init(id: "thirsty", title: "Time for a drink", question: "We feel thirsty after playing. Find water and a cup.", before: "sun.max.fill", after: "cup.and.saucer.fill", setting: "garden", required: ["water", "cup"], extras: ["hat", "glue"], resolution: "Pour some water. A drink helps when we feel thirsty."),
        .init(id: "sleepy", title: "A cozy rest", question: "Teddy is sleepy. Find a cozy blanket for a rest.", before: "teddybear.fill", after: "bed.double.fill", setting: "night", required: ["blanket"], extras: ["can", "repair", "boots"], resolution: "Teddy snuggles under a blanket for a cozy rest."),
        .init(id: "dark", title: "Too dark to read", question: "It is too dark to see our story. Find a lamp to light the page.", before: "book.closed.fill", after: "book.fill", setting: "night", required: ["lamp"], extras: ["snack", "brush", "box"], resolution: "Click! The lamp lights our story."),
        .init(id: "paper", title: "A torn picture", question: "Our paper picture tore. Find a glue stick and paper to patch it.", before: "doc", after: "doc.richtext", setting: "room", required: ["glue", "paper"], extras: ["water", "boots"], resolution: "A paper patch and glue help mend our picture."),
        .init(id: "harvest", title: "Garden gathering", question: "The carrots are ready to pick. Find a basket to carry them.", before: "carrot.fill", after: "basket.fill", setting: "garden", required: ["basket"], extras: ["lamp", "soap", "brush"], resolution: "Our carrots fit in the basket. Time to carry them inside."),
        .init(id: "play", title: "A friend wants to play", question: "Our friend wants a rolling game. Find a soft ball we can share.", before: "person.2.fill", after: "soccerball", setting: "garden", required: ["ball"], extras: ["repair", "cup", "towel"], resolution: "Roll the soft ball to a friend. Now it is their turn!"),
        .init(id: "hair", title: "Tangled hair", question: "Our hair is tangled. Find a hairbrush and a grown-up to help gently.", before: "person.fill", after: "comb.fill", setting: "room", required: ["brush", "adult"], extras: ["glue", "can"], resolution: "A grown-up helps brush gently. We can ask for a pause."),
        .init(id: "bath", title: "After a bath", question: "Our hands are clean but wet. Find a towel to dry them.", before: "hand.raised.fill", after: "hands.sparkles.fill", setting: "room", required: ["towel"], extras: ["ramp", "book", "snack"], resolution: "Pat, pat! The towel helps dry our hands."),
        .init(id: "bridge", title: "A gap in the track", question: "The toy car cannot cross a gap. Find a toy ramp to make a bridge.", before: "car.side.hill.up.fill", after: "car.side.fill", setting: "room", required: ["ramp"], extras: ["soap", "hat", "cup"], resolution: "The ramp bridges the gap. Our toy car can cross!"),
    ]
    static let tryAgain = "That is useful for another job. Listen to our problem and try another tool."
    static let found = "That can help! Find the other tool we need."
    static let completion = "We did it together! You can play again or choose all done."
    static var narration: [String] {
        bank.flatMap { [$0.question, $0.resolution] } + SolutionTool.bank.map(\.title)
        + [tryAgain, found, completion, "Open your solution toolbox."]
    }
}

struct SolutionPlay {
    let rounds: [SolutionProblem]
    private(set) var index = 0
    private(set) var selected = Set<String>()
    private(set) var choices: [String] = []
    var complete: Bool { index == rounds.count }
    var current: SolutionProblem { rounds[min(index, rounds.count - 1)] }
    var solved: Bool { Set(current.required).isSubset(of: selected) }
    init(previousFirst: String = "") {
        var deck = SolutionProblem.bank.shuffled()
        if deck[0].id == previousFirst { deck.swapAt(0, Int.random(in: 1..<deck.count)) }
        rounds = deck
        choices = (deck[0].required + deck[0].extras).shuffled()
    }
    @discardableResult mutating func choose(_ id: String, problem: String) -> Bool {
        guard !complete, !solved, current.id == problem, current.required.contains(id) else { return false }
        return selected.insert(id).inserted
    }
    mutating func next() {
        guard !complete, solved else { return }
        index += 1
        guard !complete else { return }
        selected = []
        choices = (current.required + current.extras).shuffled()
    }
}
