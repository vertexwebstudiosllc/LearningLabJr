import Foundation

struct BarnyardDiscovery: Identifiable {
    let id: String
    let asset: String
    let introduction: String
    let playPrompt: String
    var name: String { id.capitalized }
    static let prompt = "Tap the barn to slide the doors open. Tap again to meet who's inside!"
    static let bank: [Self] = [
        .init(id: "cow", asset: "FamilyClean/cow", introduction: "Cow! Moo, moo! Cows munch on grass.", playPrompt: "Can you make a gentle moo?"),
        .init(id: "pig", asset: "BarnClean/pig", introduction: "Pig! Oink, oink! A pig uses its snout to explore.", playPrompt: "Can you wiggle your nose like a pig?"),
        .init(id: "chicken", asset: "FamilyClean/chicken", introduction: "Chicken! Cluck, cluck! Chickens have feathers and two feet.", playPrompt: "Can you flap your arms like little wings?"),
        .init(id: "turkey", asset: "BarnClean/turkey", introduction: "Turkey! Look at that fan-shaped tail.", playPrompt: "Can you spread your fingers like tail feathers?"),
        .init(id: "sheep", asset: "FamilyClean/sheep", introduction: "Sheep! Baa, baa! A sheep has a woolly coat.", playPrompt: "Can you make a soft baa?"),
        .init(id: "rabbit", asset: "BarnClean/rabbit", introduction: "Rabbit! Look at those long ears. Rabbits can hop.", playPrompt: "Can you make two fingers hop on your hand?"),
        .init(id: "horse", asset: "FamilyClean/horse", introduction: "Horse! Neigh, neigh! Horses have hooves.", playPrompt: "Can you pat your knees to make a clip-clop beat?"),
        .init(id: "goat", asset: "BarnClean/goat", introduction: "Goat! Goats are curious animals that like to climb.", playPrompt: "Can you pretend your fingers are climbing a little hill?"),
        .init(id: "duck", asset: "BarnClean/duck", introduction: "Duck! Quack, quack! Ducks have wide, webbed feet for swimming.", playPrompt: "Can you paddle your hands like a swimming duck?"),
        .init(id: "cat", asset: "FamilyClean/cat", introduction: "Cat! Meow, meow! A cat has whiskers beside its nose.", playPrompt: "Can you point beside your nose where whiskers would be?"),
        .init(id: "dog", asset: "FamilyClean/dog", introduction: "Dog! Woof, woof! Some dogs help farmers look after sheep.", playPrompt: "Can you give our farm dog a friendly wave?"),
        .init(id: "calf", asset: "FamilyClean/calf", introduction: "Calf! A calf is a baby cow.", playPrompt: "Can you say hello to the little calf?"),
        .init(id: "foal", asset: "FamilyClean/foal", introduction: "Foal! A foal is a baby horse.", playPrompt: "Can you make a tiny clip-clop with your fingers?"),
        .init(id: "lamb", asset: "FamilyClean/lamb", introduction: "Lamb! A lamb is a baby sheep.", playPrompt: "Can you make a little baa for the lamb?"),
        .init(id: "chick", asset: "FamilyClean/chick", introduction: "Chick! Peep, peep! A chick is a baby chicken.", playPrompt: "Can you say peep, peep in a tiny voice?"),
        .init(id: "kitten", asset: "FamilyClean/kitten", introduction: "Kitten! A kitten is a baby cat.", playPrompt: "Can you make a little meow?"),
        .init(id: "puppy", asset: "FamilyClean/puppy", introduction: "Puppy! A puppy is a baby dog.", playPrompt: "Can you give the puppy a little woof?"),
        .init(id: "farmer", asset: "BarnClean/farmer", introduction: "Farmer! Farmers care for animals and grow food.", playPrompt: "Can you pretend to sprinkle seeds in the soil?"),
        .init(id: "tractor", asset: "BarnClean/tractor", introduction: "Tractor! Farmers drive tractors to help with heavy jobs.", playPrompt: "Can you turn a pretend steering wheel?"),
    ]
}

/// Save the unused discoveries so short visits still explore the whole collection.
struct BarnyardDeck: Codable {
    private(set) var remaining: [String] = []
    private(set) var lastID = ""
    mutating func next() -> BarnyardDiscovery {
        let ids = BarnyardDiscovery.bank.map(\.id)
        remaining = remaining.filter { ids.contains($0) }
        if remaining.isEmpty {
            remaining = ids.shuffled()
            if remaining.first == lastID { remaining.swapAt(0, 1) }
        }
        lastID = remaining.removeFirst()
        return BarnyardDiscovery.bank.first { $0.id == lastID }!
    }
}

enum BarnyardPhase: String { case closed, opening, open, introduced, closing }
struct BarnyardPlay {
    private(set) var deck: BarnyardDeck
    private(set) var current: BarnyardDiscovery
    private(set) var phase: BarnyardPhase = .closed
    var position: Int { BarnyardDiscovery.bank.count - deck.remaining.count }
    init(deck: BarnyardDeck = BarnyardDeck()) {
        var nextDeck = deck
        current = nextDeck.next(); self.deck = nextDeck
    }
    mutating func activate() {
        switch phase {
        case .closed: phase = .opening
        case .open: phase = .introduced
        case .introduced: phase = .closing
        case .opening, .closing: break
        }
    }
    mutating func finishAnimation() {
        if phase == .opening { phase = .open }
        else if phase == .closing { current = deck.next(); phase = .closed }
    }
}
