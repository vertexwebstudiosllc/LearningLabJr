import Foundation

struct DetectiveAnimal: Identifiable {
    let id: String
    let name: String
    let asset: String
    let clues: [String]
    var success: String { "You found the \(name.lowercased())! Great noticing, nature detective!" }
    var fullClues: String { clues.joined(separator: " ") }
    var retry: String { "Let's look again. " + fullClues }
    static let invitation = "Let's be nature detectives! Listen to the clues and choose an animal or insect. Tap another clue whenever you need a little help."
    static let bank: [Self] = [
        .init(id: "rabbit", name: "Rabbit", asset: "BarnClean/rabbit", clues: ["I have soft fur.", "My ears are long.", "I move with little hops."]),
        .init(id: "cat", name: "Cat", asset: "FamilyClean/cat", clues: ["I have whiskers and soft fur.", "I can purr when I feel comfortable.", "I say meow."]),
        .init(id: "dog", name: "Dog", asset: "FamilyClean/dog", clues: ["I have fur and a tail.", "I can wag my tail and sniff with my nose.", "I say woof."]),
        .init(id: "cow", name: "Cow", asset: "FamilyClean/cow", clues: ["I am a big farm animal.", "I eat grass and have hooves.", "I say moo."]),
        .init(id: "sheep", name: "Sheep", asset: "FamilyClean/sheep", clues: ["My coat is fluffy wool.", "I have hooves and eat grass.", "I say baa."]),
        .init(id: "horse", name: "Horse", asset: "FamilyClean/horse", clues: ["I am a big animal with hooves.", "I have a mane and a long tail.", "My hooves can make a clip-clop sound when I trot."]),
        .init(id: "chicken", name: "Chicken", asset: "FamilyClean/chicken", clues: ["I am a bird with feathers.", "I have a beak and scratch the ground to find food.", "I cluck, and a hen lays eggs."]),
        .init(id: "duck", name: "Duck", asset: "BarnClean/duck", clues: ["I am a bird that can swim.", "My webbed feet help me paddle.", "Many of us make a quacking sound."]),
        .init(id: "pig", name: "Pig", asset: "BarnClean/pig", clues: ["I am a farm animal with hooves.", "I use my snout to sniff and explore.", "I say oink."]),
        .init(id: "turkey", name: "Turkey", asset: "BarnClean/turkey", clues: ["I am a large bird.", "I can spread my tail feathers like a fan.", "A male makes a gobble-gobble sound."]),
        .init(id: "goat", name: "Goat", asset: "BarnClean/goat", clues: ["I have hooves and can climb.", "Many of us have horns and a little beard.", "I am a farm animal that says maa."]),
        .init(id: "dolphin", name: "Dolphin", asset: "dolphinClean", clues: ["I swim in the ocean.", "I come to the surface to breathe air.", "I have a long snout, flippers, and a curved fin on my back."]),
        .init(id: "octopus", name: "Octopus", asset: "OceanClean/octopus", clues: ["I live in the ocean and have a soft body.", "My arms have little suckers.", "I have eight arms."]),
        .init(id: "crab", name: "Crab", asset: "OceanClean/crab", clues: ["I have a hard shell.", "I have two claws.", "Many of us scuttle sideways near the sea."]),
        .init(id: "seahorse", name: "Seahorse", asset: "OceanClean/seahorse", clues: ["I am a small ocean fish.", "I have a curled tail that can hold onto things.", "My head looks a little like a tiny horse."]),
        .init(id: "whale", name: "Whale", asset: "OceanClean/whale", clues: ["I am a large ocean animal.", "I breathe air through a blowhole on top of my head.", "My wide tail moves up and down as I swim."]),
        .init(id: "seal", name: "Seal", asset: "OceanClean/seal", clues: ["I swim in the ocean and also rest out of the water.", "I have flippers and smooth-looking fur.", "I have long whiskers around my nose."]),
        .init(id: "shark", name: "Shark", asset: "OceanClean/shark", clues: ["I am an ocean fish.", "I breathe using gills.", "I have a pointed fin on my back and rows of teeth."]),
        .init(id: "starfish", name: "Sea star", asset: "OceanClean/starfish", clues: ["I live in the ocean.", "Little tube feet help me move slowly.", "My body looks like a star."]),
        .init(id: "jellyfish", name: "Jellyfish", asset: "OceanClean/jellyfish", clues: ["I live in the ocean and have a soft body.", "My body can look like a floating umbrella.", "Tentacles hang below me as I drift and swim."]),
        .init(id: "butterfly", name: "Butterfly", asset: "DetectiveClean/butterfly", clues: ["I am an insect with six legs.", "I have broad, colorful wings.", "I flutter from flower to flower."]),
        .init(id: "bee", name: "Bee", asset: "DetectiveClean/bee", clues: ["I am a flying insect.", "I have a fuzzy body and visit flowers for nectar and pollen.", "I can buzz, and the one in our picture has yellow and dark stripes."]),
        .init(id: "ladybug", name: "Ladybug", asset: "DetectiveClean/ladybug", clues: ["I am a small beetle with six legs.", "My rounded back has hard wing covers.", "The one in our picture is red with black spots."]),
        .init(id: "ant", name: "Ant", asset: "DetectiveClean/ant", clues: ["I am a small insect with six legs.", "I have bent antennae and a narrow waist.", "You may see many of us walking together in a line."]),
    ]
    static var narration: [String] {
        [invitation] + bank.flatMap { animal in
            (1...animal.clues.count).map { "Here is a clue! " + animal.clues.prefix($0).joined(separator: " ") } + [animal.retry, animal.success]
        }
    }
}
struct DetectiveRound {
    let animal: DetectiveAnimal
    let choices: [DetectiveAnimal]
}
struct NatureDetectivePlay {
    let rounds: [DetectiveRound]
    private(set) var index = 0
    private(set) var clueCount = 1
    private(set) var solved = false
    private(set) var needsHelp = false
    var complete: Bool { index == rounds.count }
    var current: DetectiveRound { rounds[min(index, rounds.count - 1)] }
    var prompt: String {
        if solved { return current.animal.success }
        if needsHelp { return current.animal.retry }
        return "Here is a clue! " + current.animal.clues.prefix(clueCount).joined(separator: " ")
    }
    init(previousFirst: String = "", previousAnimal: String = "") {
        var deck = DetectiveAnimal.bank.shuffled()
        if [previousFirst, previousAnimal].contains(deck[0].id),
           let other = deck.indices.dropFirst().first(where: { ![previousFirst, previousAnimal].contains(deck[$0].id) }) {
            deck.swapAt(0, other)
        }
        var previousChoices: Set<String> = []
        rounds = deck.map { animal in
            let candidates = DetectiveAnimal.bank.filter { $0.id != animal.id && !previousChoices.contains($0.id) }.shuffled()
            let choices = ([animal] + candidates.prefix(2)).shuffled()
            previousChoices = Set(choices.map(\.id))
            return DetectiveRound(animal: animal, choices: choices)
        }
    }
    mutating func revealClue(in animalID: String) {
        guard !complete, !solved, current.animal.id == animalID else { return }
        clueCount = min(clueCount + 1, current.animal.clues.count)
        needsHelp = false
    }
    mutating func choose(_ answer: String, for animalID: String) {
        guard !complete, !solved, current.animal.id == animalID,
              current.choices.contains(where: { $0.id == answer }) else { return }
        if answer == animalID { solved = true; needsHelp = false }
        else { clueCount = current.animal.clues.count; needsHelp = true }
    }
    mutating func advance(from animalID: String) {
        guard !complete, solved, current.animal.id == animalID else { return }
        index += 1; clueCount = 1; solved = false; needsHelp = false
    }
}
