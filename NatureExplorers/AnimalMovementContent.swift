import Foundation

struct AnimalMove: Identifiable {
    let id: String
    let name: String
    let asset: String
    let movement: String
    let prompt: String
    static let invitation = "Let's move like animals with a grown-up! Make a little space together. You can try every move while sitting down."
    static let bank: [Self] = [
        .init(id: "rabbit", name: "Rabbit", asset: "BarnClean/rabbit", movement: "Gentle hops", prompt: "A rabbit hops! Play with your grown-up. Make little hops with your hands, or try a gentle hop together."),
        .init(id: "cat", name: "Cat", asset: "FamilyClean/cat", movement: "Slow stretches", prompt: "A cat stretches! Reach your arms out slowly, then bring them back. A little stretch feels good."),
        .init(id: "dog", name: "Dog", asset: "FamilyClean/dog", movement: "Happy wags", prompt: "A dog wags its tail! Pretend your hand is a tail. Wag it gently from side to side."),
        .init(id: "horse", name: "Horse", asset: "FamilyClean/horse", movement: "Clip-clop rhythm", prompt: "A horse trots! Pat your knees one at a time. Clip, clop, clip, clop!"),
        .init(id: "chicken", name: "Chicken", asset: "FamilyClean/chicken", movement: "Little wings", prompt: "A chicken flaps its wings! Bend your elbows and give your little wings a gentle flap."),
        .init(id: "duck", name: "Duck", asset: "BarnClean/duck", movement: "Side-to-side waddles", prompt: "A duck waddles! Sit or stand with your grown-up and gently rock from side to side."),
        .init(id: "goat", name: "Goat", asset: "BarnClean/goat", movement: "Careful steps", prompt: "A goat climbs! Pretend your fingers are little feet. Walk them slowly up your other arm."),
        .init(id: "sheep", name: "Sheep", asset: "FamilyClean/sheep", movement: "Tiny steps", prompt: "A sheep walks through the grass! Take tiny steps in place, or walk two fingers across your lap."),
        .init(id: "pig", name: "Pig", asset: "BarnClean/pig", movement: "Snout wiggles", prompt: "A pig sniffs with its snout! Wiggle your nose and take a little sniff. What a curious pig!"),
        .init(id: "turkey", name: "Turkey", asset: "BarnClean/turkey", movement: "A feather fan", prompt: "A turkey can spread its tail feathers! Spread your fingers wide like a fan, then relax your hands."),
        .init(id: "dolphin", name: "Dolphin", asset: "dolphinClean", movement: "Ocean waves", prompt: "A dolphin swims through the water! Move one hand up and down like a gentle ocean wave."),
        .init(id: "crab", name: "Crab", asset: "OceanClean/crab", movement: "Sideways steps", prompt: "A crab can walk sideways! Walk your fingers sideways across your lap, or take little side steps with your grown-up."),
        .init(id: "octopus", name: "Octopus", asset: "OceanClean/octopus", movement: "Wiggly arms", prompt: "An octopus moves its arms! Wiggle your fingers and slowly wave your arms through our pretend ocean."),
        .init(id: "seal", name: "Seal", asset: "OceanClean/seal", movement: "Swimming flippers", prompt: "A seal swims with flippers! Keep your elbows close and gently sweep your hands through pretend water."),
        .init(id: "jellyfish", name: "Jellyfish", asset: "OceanClean/jellyfish", movement: "Open and close", prompt: "A jellyfish squeezes its body to swim! Open your hands wide, then gently close them. Open and close!"),
        .init(id: "stingray", name: "Stingray", asset: "OceanClean/stingray", movement: "Gentle glides", prompt: "A stingray glides through the sea! Hold your arms out a little and move them softly up and down."),
    ]
}

/// Each animal appears once per session; the opening animal also differs from the last one seen.
struct AnimalMovementPlay {
    let animals: [AnimalMove]
    private(set) var index = 0
    var complete: Bool { index == animals.count }
    var current: AnimalMove { animals[min(index, animals.count - 1)] }
    init(previousAnimal: String = "") {
        var deck = AnimalMove.bank.shuffled()
        if deck.first?.id == previousAnimal { deck.swapAt(0, Int.random(in: 1..<deck.count)) }
        animals = deck
    }
    mutating func advance(from animalID: String) {
        guard !complete, current.id == animalID else { return }
        index += 1
    }
}
