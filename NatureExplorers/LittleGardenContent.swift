import Foundation

struct GardenFlower: Identifiable, Equatable {
    let id: String
    let name: String
    let petals: Int
    static let all: [Self] = [
        .init(id: "sunflower", name: "Sunflower", petals: 14),
        .init(id: "daisy", name: "Daisy", petals: 12),
        .init(id: "zinnia", name: "Zinnia", petals: 10),
        .init(id: "marigold", name: "Marigold", petals: 16),
    ]
}

enum GardenPlace: String, CaseIterable { case inside, outside }
struct GardenGrowingStep {
    let id: String
    let action: String
    let symbol: String
    let narration: String
    let growth: Int
    static func steps(for place: GardenPlace) -> [Self] {
        switch place {
        case .inside: [
            .init(id: "prepare", action: "Choose a pot", symbol: "flowerpot.fill", narration: "Let's grow inside! Choose a pot with holes underneath so extra water can drain away.", growth: 0),
            .init(id: "soil", action: "Add potting mix", symbol: "square.stack.3d.up.fill", narration: "Fill the pot with potting mix. Leave a little space at the top.", growth: 0),
            .init(id: "seed", action: "Plant the seed", symbol: "circle.fill", narration: "Tuck one seed into the soil. This is where our flower begins.", growth: 0),
            .init(id: "cover", action: "Cover gently", symbol: "hand.draw.fill", narration: "Cover the seed with a little soil. Keep it cozy, not squashed.", growth: 0),
            .init(id: "water", action: "Water gently", symbol: "drop.fill", narration: "Give the soil a gentle drink. Plants need water, but not a puddle.", growth: 0),
            .init(id: "light", action: "Find a sunny window", symbol: "sun.max.fill", narration: "Set the pot by a sunny window. Light helps our plant grow.", growth: 0),
            .init(id: "roots", action: "Let days pass", symbol: "calendar", narration: "Growing takes many days. Let's pretend time passes. Tiny roots are growing under the soil!", growth: 1),
            .init(id: "sprout", action: "Look for a sprout", symbol: "leaf.fill", narration: "Peekaboo, little sprout! A green shoot is reaching up toward the light.", growth: 2),
            .init(id: "leaves", action: "Check the soil", symbol: "drop.fill", narration: "Check the pot with a grown-up. If the soil feels dry, give it a little water. More days pass, and new leaves grow!", growth: 3),
            .init(id: "bud", action: "Keep caring", symbol: "heart.fill", narration: "Keep giving your plant light and the water it needs. After more growing time, a little flower bud appears!", growth: 4),
            .init(id: "bloom", action: "Watch it bloom", symbol: "sun.max.fill", narration: "More days pass. The petals open wide. Our flower is in full bloom! You helped it grow.", growth: 5),
        ]
        case .outside: [
            .init(id: "prepare", action: "Choose a sunny spot", symbol: "sun.max.fill", narration: "Let's grow outside! Find a sunny spot in our pretend garden.", growth: 0),
            .init(id: "soil", action: "Loosen the soil", symbol: "hand.draw.fill", narration: "Use a little trowel to loosen the garden soil. Make room for our seed and its roots.", growth: 0),
            .init(id: "seed", action: "Plant the seed", symbol: "circle.fill", narration: "Tuck one seed into the soil. This is where our flower begins.", growth: 0),
            .init(id: "cover", action: "Cover gently", symbol: "hand.draw.fill", narration: "Cover the seed with a little soil. Keep it cozy, not squashed.", growth: 0),
            .init(id: "water", action: "Water gently", symbol: "drop.fill", narration: "Give the soil a gentle drink. Plants need water, but not a puddle.", growth: 0),
            .init(id: "light", action: "Mark our garden", symbol: "flag.fill", narration: "Put a flower marker beside the seed. Now we can remember where we planted it.", growth: 0),
            .init(id: "roots", action: "Let days pass", symbol: "calendar", narration: "Growing takes many days. Let's pretend time passes. Tiny roots spread through the garden soil!", growth: 1),
            .init(id: "sprout", action: "Look for a sprout", symbol: "leaf.fill", narration: "Hello, little sprout! A green shoot is peeking up out of the garden.", growth: 2),
            .init(id: "leaves", action: "Check the garden", symbol: "drop.fill", narration: "Check the soil with a grown-up. Rain may have watered it. If it feels dry, give it a gentle drink. More days pass, and leaves grow!", growth: 3),
            .init(id: "bud", action: "Make room to grow", symbol: "hand.draw.fill", narration: "With a grown-up, clear little weeds around our flower. Keep caring as more days pass. Look, a flower bud!", growth: 4),
            .init(id: "bloom", action: "Watch it bloom", symbol: "sun.max.fill", narration: "More days pass. Our garden flower opens its petals. It is in full bloom! You helped it grow.", growth: 5),
        ]
        }
    }
}

struct LittleGardenPlay {
    static let flowerPrompt = "Which flower would you like to grow? Pick your favorite!"
    private(set) var flower: GardenFlower?
    private(set) var place: GardenPlace?
    // -1 shows the empty planting scene before the first action.
    private(set) var step = -1
    var steps: [GardenGrowingStep] { place.map { GardenGrowingStep.steps(for: $0) } ?? [] }
    var complete: Bool { place != nil && step == steps.count - 1 }
    var growth: Int { step >= 0 ? steps[step].growth : 0 }
    var nextStep: GardenGrowingStep? { place != nil && !complete ? steps[step + 1] : nil }
    var prompt: String {
        guard let flower else { return Self.flowerPrompt }
        guard let place else { return "\(flower.name)! Would you like to grow it inside in a pot, or outside in a garden?" }
        if step < 0 { return place == .inside ? "Our indoor garden is ready. Let's choose a pot for our flower." : "Our outdoor garden is ready. Let's choose a sunny planting spot." }
        return steps[step].narration
    }
    var stageName: String {
        if step < 0 { return "Ready to plant" }
        return ["Planting a seed", "Roots", "Sprout", "Leaves", "Flower bud", "Full bloom"][growth]
    }
    mutating func chooseFlower(_ value: GardenFlower) {
        guard flower == nil, GardenFlower.all.contains(value) else { return }
        flower = value
    }
    mutating func choosePlace(_ value: GardenPlace) {
        guard flower != nil, place == nil else { return }
        place = value
    }
    mutating func advance() { guard nextStep != nil else { return }; step += 1 }
    mutating func restart() { self = Self() }
    static var narration: [String] {
        var lines = [flowerPrompt]
        for flower in GardenFlower.all {
            var play = Self(); play.chooseFlower(flower); lines.append(play.prompt)
            for place in GardenPlace.allCases {
                var path = play; path.choosePlace(place); lines.append(path.prompt)
                while !path.complete { path.advance(); lines.append(path.prompt) }
            }
        }
        return Array(Set(lines)).sorted()
    }
}
