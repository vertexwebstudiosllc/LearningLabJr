import SwiftUI

enum RescueSlot: Int, CaseIterable { case hat, outfit, tool }
enum TeddyFur: String, CaseIterable, Identifiable {
    case brown, tan, cream, gray, pink, purple
    var id: String { rawValue }
    var name: String { rawValue.capitalized }
    var color: Color {
        switch self {
        case .brown: return Color(red: 0.57, green: 0.34, blue: 0.18)
        case .tan: return Color(red: 0.79, green: 0.57, blue: 0.35)
        case .cream: return Color(red: 0.96, green: 0.87, blue: 0.67)
        case .gray: return Color(red: 0.58, green: 0.62, blue: 0.66)
        case .pink: return Color(red: 0.96, green: 0.50, blue: 0.68)
        case .purple: return Color(red: 0.66, green: 0.49, blue: 0.83)
        }
    }
    var narration: String { name + " fur for Teddy." }
}
enum TeddyIdentity: String, CaseIterable, Identifiable {
    case boy, girl
    var id: String { rawValue }
    var name: String { rawValue.capitalized + " Teddy" }
    var narration: String { name + " is ready to help!" }
}
struct RescueItem: Identifiable {
    let role: String
    let slot: RescueSlot
    let name: String
    let paint: String
    var id: String { role + "." + String(slot.rawValue) }
    var narration: String { (["Vet scrubs", "Wooden boards", "Overalls", "Reading glasses"].contains(name) ? "These are the " : "This is the ") + name.lowercased() + "." }
    var color: Color { paint == "teal" ? .teal : LabPaint.named(paint).color }
}
struct TeddyRescue: Identifiable {
    let id: String
    let title: String
    let helper: String
    let problem: String
    let names: [String]
    let action: String
    let success: String
    let paint: String
    var items: [RescueItem] { RescueSlot.allCases.map { RescueItem(role: id, slot: $0, name: names[$0.rawValue], paint: paint) } }
    func instruction(_ slot: RescueSlot) -> String { problem + " Let's dress Teddy as " + (helper == "animal shelter helper" ? "an " : "a ") + helper + ". Choose the " + names[slot.rawValue].lowercased() + "." }
    func retry(_ slot: RescueSlot) -> String { "That is for another helper. For this scene, find the " + names[slot.rawValue].lowercased() + "." }
    var ready: String { "Teddy is dressed as " + (helper == "animal shelter helper" ? "an " : "a ") + helper + "! " + action + " when you are ready." }
    static let invitation = "Let's build a helper Teddy! Choose boy or girl Teddy and a fur color. Then we will dress Teddy for twelve pretend helping adventures."
    static let bank: [Self] = [
        .init(id: "cat", title: "Cat in a tree", helper: "firefighter", problem: "A cat is stuck in our pretend tree. A firefighter can help.", names: ["Fire helmet", "Fire coat", "Ladder"], action: "Help the cat down", success: "Our pretend firefighter brought the cat down safely. The cat is back on the grass!", paint: "red"),
        .init(id: "puppy", title: "Puppy checkup", helper: "vet", problem: "A puppy needs a gentle checkup. A vet can care for animals.", names: ["Vet cap", "Vet scrubs", "Bandage"], action: "Care for the puppy", success: "Our pretend vet cared for the puppy. Teddy used gentle hands!", paint: "teal"),
        .init(id: "bridge", title: "Broken bridge", helper: "builder", problem: "Our little bridge has a gap. A builder can help repair it.", names: ["Hard hat", "Safety vest", "Wooden boards"], action: "Fix the bridge", success: "Teddy placed the missing boards. Our pretend bridge connects both sides again!", paint: "orange"),
        .init(id: "garden", title: "Thirsty flowers", helper: "gardener", problem: "These garden flowers need water. A gardener can help.", names: ["Sun hat", "Garden apron", "Watering can"], action: "Water the flowers", success: "Teddy watered the flowers. Their colorful petals are opening!", paint: "green"),
        .init(id: "bunny", title: "A picnic for Bunny", helper: "cook", problem: "Bunny is waiting for a picnic snack. A cook can prepare food.", names: ["Chef hat", "Chef apron", "Carrot basket"], action: "Bring Bunny a snack", success: "Teddy brought Bunny a basket of carrots for a pretend picnic!", paint: "white"),
        .init(id: "duck", title: "Lost duckling", helper: "park ranger", problem: "A duckling cannot find the pond. A park ranger knows the way.", names: ["Ranger hat", "Ranger jacket", "Map"], action: "Guide the duckling", success: "Teddy followed the map and helped the duckling reach the pond!", paint: "green"),
        .init(id: "beach", title: "Beach cleanup", helper: "cleanup helper", problem: "Litter is scattered on our pretend beach. A cleanup helper can care for this place.", names: ["Cleanup cap", "Cleanup vest", "Litter grabber"], action: "Clean the beach", success: "Teddy moved the pretend litter into the bin. There is room for animals to enjoy the beach!", paint: "blue"),
        .init(id: "bike", title: "Wobbly bicycle", helper: "bike mechanic", problem: "A toy bicycle has a loose wheel. A bike mechanic can help.", names: ["Mechanic cap", "Overalls", "Wrench"], action: "Fix the toy bicycle", success: "Teddy fixed the wheel on our toy bicycle. Both wheels are in place!", paint: "blue"),
        .init(id: "rain", title: "A rainy walk", helper: "rainy-day helper", problem: "A friend is waiting in the rain. Our rainy-day helper can offer an umbrella.", names: ["Rain hat", "Raincoat", "Umbrella"], action: "Offer the umbrella", success: "Our friend said yes to an umbrella. Teddy helped make a cozy rainy walk!", paint: "yellow"),
        .init(id: "kitten", title: "A cozy kitten", helper: "animal shelter helper", problem: "A kitten needs a cozy resting spot. An animal shelter helper can offer a blanket.", names: ["Cozy hat", "Shelter vest", "Blanket"], action: "Make a cozy spot", success: "Teddy made a soft resting spot. The kitten can settle on its blanket!", paint: "purple"),
        .init(id: "snow", title: "Snowy path", helper: "snow helper", problem: "Snow covers the path to a home. A grown-up snow helper can clear a way.", names: ["Winter hat", "Winter coat", "Snow shovel"], action: "Clear the pretend path", success: "Teddy cleared our pretend path. Our neighbor has a way to the door!", paint: "orange"),
        .init(id: "books", title: "Tumbled books", helper: "library helper", problem: "The library books have tumbled off their shelf. A library helper can put them back.", names: ["Reading glasses", "Cardigan", "Book cart"], action: "Put the books away", success: "Teddy put the books back on the shelf. Our reading corner is ready!", paint: "purple"),
    ]
    static var narration: [String] {
        [invitation] + TeddyFur.allCases.map(\.narration) + TeddyIdentity.allCases.map(\.narration) + bank.flatMap { scene in
            RescueSlot.allCases.flatMap { [scene.instruction($0), scene.retry($0)] } + scene.items.map(\.narration) + [scene.ready, scene.success]
        }
    }
}
struct RescueRound {
    let scene: TeddyRescue
    let choices: [[RescueItem]]
}
struct TeddyRescuePlay {
    enum Phase { case create, dress, ready, rescued }
    let rounds: [RescueRound]
    private(set) var index = 0
    private(set) var stage = 0
    private(set) var phase: Phase = .create
    private(set) var needsHelp = false
    var fur: TeddyFur = .brown
    var identity: TeddyIdentity = .boy
    var complete: Bool { index == rounds.count }
    var current: RescueRound { rounds[min(index, rounds.count - 1)] }
    var slot: RescueSlot { RescueSlot(rawValue: min(stage, 2))! }
    var equipped: [RescueItem] { complete ? current.scene.items : Array(current.scene.items.prefix(stage)) }
    var prompt: String {
        if complete { return "We did it together! You can play again or choose all done." }
        switch phase {
        case .create: return TeddyRescue.invitation
        case .dress: return needsHelp ? current.scene.retry(slot) : current.scene.instruction(slot)
        case .ready: return current.scene.ready
        case .rescued: return current.scene.success
        }
    }
    init(previousSecond: String = "") {
        var rest = Array(TeddyRescue.bank.dropFirst()).shuffled()
        if rest[0].id == previousSecond { rest.swapAt(0, 1) }
        rounds = ([TeddyRescue.bank[0]] + rest).map { scene in
            let choices = RescueSlot.allCases.map { slot in
                let others = TeddyRescue.bank.filter { $0.id != scene.id }.shuffled().prefix(2).map { $0.items[slot.rawValue] }
                return ([scene.items[slot.rawValue]] + others).shuffled()
            }
            return RescueRound(scene: scene, choices: choices)
        }
    }
    mutating func begin() { guard phase == .create, !complete else { return }; phase = .dress }
    mutating func choose(_ itemID: String, scene: String, slot expectedSlot: RescueSlot) {
        guard !complete, phase == .dress, current.scene.id == scene, slot == expectedSlot,
              let item = current.choices[stage].first(where: { $0.id == itemID }) else { return }
        guard item.role == scene else { needsHelp = true; return }
        stage += 1; needsHelp = false
        if stage == 3 { phase = .ready }
    }
    mutating func help(_ scene: String) {
        guard !complete, phase == .ready, current.scene.id == scene else { return }
        phase = .rescued
    }
    mutating func advance(_ scene: String) {
        guard !complete, phase == .rescued, current.scene.id == scene else { return }
        index += 1; stage = 0; phase = .dress; needsHelp = false
    }
}
