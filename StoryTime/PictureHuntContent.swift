import SwiftUI

struct HuntItem: Identifiable {
    let id: String
    let name: String
    let asset: String?
    let symbol: String
    let color: Color
    static let bank: [HuntItem] = [
        .init(id: "bunny", name: "Bunny", asset: "BarnClean/rabbit", symbol: "hare.fill", color: .pink),
        .init(id: "apple", name: "Apple", asset: "AppleClean", symbol: "apple.logo", color: .red),
        .init(id: "cup", name: "Cup", asset: nil, symbol: "cup.and.saucer.fill", color: .orange),
        .init(id: "cow", name: "Cow", asset: "FamilyClean/cow", symbol: "pawprint.fill", color: .brown),
        .init(id: "tractor", name: "Tractor", asset: "BarnClean/tractor", symbol: "car.fill", color: .green),
        .init(id: "hen", name: "Hen", asset: "FamilyClean/chicken", symbol: "bird.fill", color: .orange),
        .init(id: "teddy", name: "Teddy bear", asset: nil, symbol: "teddybear.fill", color: .brown),
        .init(id: "book", name: "Book", asset: nil, symbol: "book.closed.fill", color: .teal),
        .init(id: "moon", name: "Moon", asset: "SpaceClean/Moon", symbol: "moon.fill", color: .yellow),
        .init(id: "crab", name: "Crab", asset: "OceanClean/crab", symbol: "fish.fill", color: .red),
        .init(id: "bucket", name: "Bucket", asset: nil, symbol: "", color: .orange),
        .init(id: "boat", name: "Sailboat", asset: nil, symbol: "sailboat.fill", color: .pink),
        .init(id: "rocket", name: "Rocket", asset: "SpaceClean/Rocket", symbol: "paperplane.fill", color: .red),
        .init(id: "earth", name: "Earth", asset: "SpaceClean/Earth", symbol: "globe.americas.fill", color: .blue),
        .init(id: "star", name: "Star", asset: nil, symbol: "star.fill", color: .yellow),
        .init(id: "butterfly", name: "Butterfly", asset: "DetectiveClean/butterfly", symbol: "butterfly.fill", color: .orange),
        .init(id: "flower", name: "Flower", asset: nil, symbol: "camera.macro", color: .pink),
        .init(id: "watering", name: "Watering can", asset: nil, symbol: "", color: .teal),
        .init(id: "umbrella", name: "Umbrella", asset: nil, symbol: "umbrella.fill", color: .purple),
        .init(id: "boots", name: "Boots", asset: nil, symbol: "", color: .yellow),
        .init(id: "cloud", name: "Cloud", asset: nil, symbol: "cloud.rain.fill", color: .blue),
        .init(id: "drum", name: "Drum", asset: nil, symbol: "", color: .orange),
        .init(id: "guitar", name: "Guitar", asset: nil, symbol: "", color: .brown),
        .init(id: "bell", name: "Bell", asset: nil, symbol: "bell.fill", color: .yellow),
        .init(id: "carrot", name: "Carrot", asset: nil, symbol: "carrot.fill", color: .orange),
        .init(id: "bowl", name: "Bowl", asset: nil, symbol: "", color: .teal),
        .init(id: "spoon", name: "Spoon", asset: nil, symbol: "", color: .purple),
        .init(id: "seal", name: "Seal", asset: "OceanClean/seal", symbol: "pawprint.fill", color: .gray),
        .init(id: "snowman", name: "Snowman", asset: nil, symbol: "", color: .blue),
        .init(id: "mitten", name: "Mitten", asset: nil, symbol: "", color: .red),
        .init(id: "cat", name: "Cat", asset: "FamilyClean/cat", symbol: "cat.fill", color: .orange),
        .init(id: "lamp", name: "Lamp", asset: nil, symbol: "lamp.desk.fill", color: .yellow),
        .init(id: "duck", name: "Duck", asset: "BarnClean/duck", symbol: "bird.fill", color: .yellow),
        .init(id: "fish", name: "Fish", asset: "OceanClean/swordfish", symbol: "fish.fill", color: .blue),
        .init(id: "leaf", name: "Leaf", asset: nil, symbol: "leaf.fill", color: .green),
        .init(id: "dog", name: "Dog", asset: "FamilyClean/dog", symbol: "dog.fill", color: .brown),
        .init(id: "gift", name: "Gift", asset: nil, symbol: "gift.fill", color: .purple),
        .init(id: "balloon", name: "Balloon", asset: nil, symbol: "balloon.fill", color: .red),
        .init(id: "kite", name: "Kite", asset: nil, symbol: "", color: .purple),
        .init(id: "ball", name: "Ball", asset: "basketball", symbol: "basketball.fill", color: .orange),
        .init(id: "tree", name: "Tree", asset: nil, symbol: "tree.fill", color: .green),
        .init(id: "hammer", name: "Hammer", asset: nil, symbol: "hammer.fill", color: .orange),
        .init(id: "wrench", name: "Wrench", asset: nil, symbol: "wrench.fill", color: .blue),
        .init(id: "toolbox", name: "Toolbox", asset: nil, symbol: "", color: .red),
        .init(id: "train", name: "Train", asset: nil, symbol: "tram.fill", color: .red),
        .init(id: "suitcase", name: "Suitcase", asset: nil, symbol: "suitcase.fill", color: .brown),
        .init(id: "clock", name: "Clock", asset: nil, symbol: "clock.fill", color: .teal),
    ]
    static func named(_ id: String) -> HuntItem { bank.first { $0.id == id }! }
}

struct HuntStory: Identifiable {
    let id: String
    let title: String
    let story: String
    let targets: [String]
    let decoys: [String]
    var prompt: String { story + " Find three things in the picture." }
    static let found = "You found something from our story! What else can you see?"
    static let retry = "That one is not in this picture. Look at the story and try again."
    static let success = "You found all three things! Ready for another story?"
    static let bank: [HuntStory] = [
        .init(id: "picnic", title: "Bunny’s picnic", story: "Bunny brought an apple and a cup to the picnic.", targets: ["bunny", "apple", "cup"], decoys: ["cow", "book", "balloon"]),
        .init(id: "farm", title: "A busy farm", story: "The cow watches a tractor while the hen pecks nearby.", targets: ["cow", "tractor", "hen"], decoys: ["bunny", "cup", "rocket"]),
        .init(id: "bedtime", title: "A cozy goodnight", story: "Teddy has a bedtime book. The moon peeks through the window.", targets: ["teddy", "book", "moon"], decoys: ["tractor", "crab", "carrot"]),
        .init(id: "beach", title: "A day at the beach", story: "A crab finds a bucket on the sand. A sailboat floats nearby.", targets: ["crab", "bucket", "boat"], decoys: ["teddy", "guitar", "lamp"]),
        .init(id: "space", title: "A space adventure", story: "A rocket flies past Earth. A bright star shines far away.", targets: ["rocket", "earth", "star"], decoys: ["hen", "bucket", "mitten"]),
        .init(id: "garden", title: "The little garden", story: "A butterfly visits a flower beside the watering can.", targets: ["butterfly", "flower", "watering"], decoys: ["train", "spoon", "dog"]),
        .init(id: "rain", title: "A rainy walk", story: "Rain falls from a cloud. An umbrella and boots keep us dry.", targets: ["umbrella", "boots", "cloud"], decoys: ["cow", "gift", "wrench"]),
        .init(id: "music", title: "A tiny concert", story: "The drum, guitar, and bell are ready for a cheerful concert.", targets: ["drum", "guitar", "bell"], decoys: ["duck", "apple", "boots"]),
        .init(id: "kitchen", title: "Soup for supper", story: "A carrot, a bowl, and a spoon are ready for soup time.", targets: ["carrot", "bowl", "spoon"], decoys: ["rocket", "leaf", "teddy"]),
        .init(id: "snow", title: "A snowy hello", story: "Seal meets a snowman. A red mitten rests in the snow.", targets: ["seal", "snowman", "mitten"], decoys: ["tractor", "cup", "butterfly"]),
        .init(id: "library", title: "Cat’s quiet corner", story: "Cat curls up beside a book while a little lamp glows.", targets: ["cat", "book", "lamp"], decoys: ["crab", "carrot", "kite"]),
        .init(id: "ocean", title: "A seaside swim", story: "Duck watches a fish swim past a floating leaf.", targets: ["duck", "fish", "leaf"], decoys: ["guitar", "bucket", "clock"]),
        .init(id: "birthday", title: "A birthday surprise", story: "Dog finds a wrapped gift and a bright balloon at the party.", targets: ["dog", "gift", "balloon"], decoys: ["cow", "spoon", "moon"]),
        .init(id: "park", title: "A breezy park", story: "A kite flies above the park. A ball rests beside a tree.", targets: ["kite", "ball", "tree"], decoys: ["teddy", "bowl", "rocket"]),
        .init(id: "workshop", title: "The little workshop", story: "A hammer and a wrench wait beside the toolbox. Let’s build!", targets: ["hammer", "wrench", "toolbox"], decoys: ["bunny", "balloon", "leaf"]),
        .init(id: "station", title: "Ready for a trip", story: "The train waits by the station clock. A suitcase is ready to go.", targets: ["train", "suitcase", "clock"], decoys: ["crab", "flower", "umbrella"]),
    ]
    static var narration: [String] {
        bank.map(\.prompt) + HuntItem.bank.map(\.name) + [found, retry, success]
    }
}

struct PictureHuntPlay {
    let rounds: [HuntStory]
    private(set) var index = 0
    private(set) var found = Set<String>()
    private(set) var choices: [String]
    private(set) var complete = false
    var current: HuntStory { rounds[index] }
    var solved: Bool { found.count == 3 }
    init(avoiding recent: [String] = []) {
        var deck = HuntStory.bank.shuffled()
        if let first = deck.firstIndex(where: { !recent.contains($0.id) }) { deck.swapAt(0, first) }
        rounds = deck
        choices = (deck[0].targets + deck[0].decoys).shuffled()
    }
    @discardableResult mutating func select(_ id: String) -> Bool {
        guard !complete, !solved, choices.contains(id), current.targets.contains(id), !found.contains(id) else { return false }
        found.insert(id); return true
    }
    mutating func next() {
        guard solved, !complete else { return }
        if index == rounds.count - 1 { complete = true; return }
        index += 1; found = []
        choices = (current.targets + current.decoys).shuffled()
    }
}
