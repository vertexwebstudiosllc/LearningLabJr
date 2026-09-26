import Foundation

struct ImaginationAction: Identifiable, Equatable {
    let id: String
    let theme: String
    let title: String
    let sentence: String
    let art: String
    let children: [String]
}

enum ImaginationStories {
    static let welcome = "Let's make a pretend story! Choose any picture for what happens first."
    static let review = "You made a story! Tap a page to hear it, or read all three pages together."
    static let firstQuestion = "What happens first?"
    static let nextQuestion = "What happens next?"
    static let lastQuestion = "What happens last?"
    static let labels = ["First", "Next", "Last"]
    static let questions = [firstQuestion, nextQuestion, lastQuestion]
    static let roots = ["space.first", "island.first", "castle.first", "garden.first", "music.first", "snow.first"]
    static let actions: [ImaginationAction] = [
        .init(id: "space.first", theme: "space", title: "Fly a pretend rocket", sentence: "First, our friend flew a pretend rocket to the moon.", art: "rocket", children: ["space.next0", "space.next1", "space.next2"]),
        .init(id: "space.next0", theme: "space", title: "Meet a moon bunny", sentence: "Next, our friend met a bunny on the moon.", art: "bunny", children: ["space.last0", "space.last1", "space.last2"]),
        .init(id: "space.next1", theme: "space", title: "Paint a star", sentence: "Next, our friend painted a bright purple star.", art: "star", children: ["space.last1", "space.last2", "space.last3"]),
        .init(id: "space.next2", theme: "space", title: "Play space music", sentence: "Next, our friend played a song for the stars.", art: "guitar", children: ["space.last0", "space.last2", "space.last3"]),
        .init(id: "space.last0", theme: "space", title: "Have a space picnic", sentence: "Last, our friend shared a picnic under the stars.", art: "basket", children: []),
        .init(id: "space.last1", theme: "space", title: "Wave to Earth", sentence: "Last, our friend waved hello to Earth.", art: "earth", children: []),
        .init(id: "space.last2", theme: "space", title: "Rest in the rocket", sentence: "Last, our friend curled up in the cozy rocket.", art: "rocket", children: []),
        .init(id: "space.last3", theme: "space", title: "Bring home a star drawing", sentence: "Last, our friend brought a star drawing home.", art: "star", children: []),
        .init(id: "island.first", theme: "island", title: "Sail to a pretend island", sentence: "First, our friend sailed to a little pretend island.", art: "boat", children: ["island.next0", "island.next1", "island.next2"]),
        .init(id: "island.next0", theme: "island", title: "Meet a friendly crab", sentence: "Next, our friend met a crab who loved to wave.", art: "crab", children: ["island.last0", "island.last1", "island.last2"]),
        .init(id: "island.next1", theme: "island", title: "Find a treasure chest", sentence: "Next, our friend found a chest of shiny shells.", art: "treasure", children: ["island.last1", "island.last2", "island.last3"]),
        .init(id: "island.next2", theme: "island", title: "Build a sandcastle", sentence: "Next, our friend built a tall sandcastle.", art: "castle", children: ["island.last0", "island.last2", "island.last3"]),
        .init(id: "island.last0", theme: "island", title: "Have a beach picnic", sentence: "Last, our friend shared a picnic on the beach.", art: "basket", children: []),
        .init(id: "island.last1", theme: "island", title: "Wave to the waves", sentence: "Last, our friend waved goodbye to the waves.", art: "wave", children: []),
        .init(id: "island.last2", theme: "island", title: "Sail home", sentence: "Last, our friend sailed home with a happy smile.", art: "boat", children: []),
        .init(id: "island.last3", theme: "island", title: "Tell an island story", sentence: "Last, our friend told a story about the island.", art: "book", children: []),
        .init(id: "castle.first", theme: "castle", title: "Visit a pretend castle", sentence: "First, our friend visited a colorful pretend castle.", art: "castle", children: ["castle.next0", "castle.next1", "castle.next2"]),
        .init(id: "castle.next0", theme: "castle", title: "Make a crown", sentence: "Next, our friend made a crown with shiny stars.", art: "crown", children: ["castle.last0", "castle.last1", "castle.last2"]),
        .init(id: "castle.next1", theme: "castle", title: "Meet a friendly dragon", sentence: "Next, our friend met a friendly little dragon.", art: "dragon", children: ["castle.last1", "castle.last2", "castle.last3"]),
        .init(id: "castle.next2", theme: "castle", title: "Throw a silly dance party", sentence: "Next, our friend started a silly castle dance.", art: "music", children: ["castle.last0", "castle.last2", "castle.last3"]),
        .init(id: "castle.last0", theme: "castle", title: "Share a royal picnic", sentence: "Last, our friend shared a picnic in the castle.", art: "basket", children: []),
        .init(id: "castle.last1", theme: "castle", title: "Wave from the tower", sentence: "Last, our friend waved from the castle tower.", art: "flag", children: []),
        .init(id: "castle.last2", theme: "castle", title: "Draw the adventure", sentence: "Last, our friend drew a picture of the adventure.", art: "pencil", children: []),
        .init(id: "castle.last3", theme: "castle", title: "Read a cozy castle story", sentence: "Last, our friend read a cozy story in the castle.", art: "book", children: []),
        .init(id: "garden.first", theme: "garden", title: "Plant a pretend seed", sentence: "First, our friend planted a tiny pretend seed.", art: "seed", children: ["garden.next0", "garden.next1", "garden.next2"]),
        .init(id: "garden.next0", theme: "garden", title: "Grow a giant flower", sentence: "Next, our friend watched a giant flower bloom.", art: "flower", children: ["garden.last0", "garden.last1", "garden.last2"]),
        .init(id: "garden.next1", theme: "garden", title: "Meet a talking butterfly", sentence: "Next, our friend met a butterfly that could talk.", art: "butterfly", children: ["garden.last1", "garden.last2", "garden.last3"]),
        .init(id: "garden.next2", theme: "garden", title: "Find a singing tree", sentence: "Next, our friend found a tree that sang a song.", art: "tree", children: ["garden.last0", "garden.last2", "garden.last3"]),
        .init(id: "garden.last0", theme: "garden", title: "Have a garden picnic", sentence: "Last, our friend shared a picnic in the garden.", art: "basket", children: []),
        .init(id: "garden.last1", theme: "garden", title: "Sing a garden song", sentence: "Last, our friend sang a song to the garden.", art: "music", children: []),
        .init(id: "garden.last2", theme: "garden", title: "Paint the garden", sentence: "Last, our friend painted the magical garden.", art: "pencil", children: []),
        .init(id: "garden.last3", theme: "garden", title: "Rest under a leaf", sentence: "Last, our friend rested under a big cozy leaf.", art: "leaf", children: []),
        .init(id: "music.first", theme: "music", title: "Start a pretend band", sentence: "First, our friend started a band with toy instruments.", art: "drum", children: ["music.next0", "music.next1", "music.next2"]),
        .init(id: "music.next0", theme: "music", title: "Make a teddy dance", sentence: "Next, our friend played a tune for a dancing teddy.", art: "teddy", children: ["music.last0", "music.last1", "music.last2"]),
        .init(id: "music.next1", theme: "music", title: "Ring tiny bells", sentence: "Next, our friend rang tiny bells in a happy rhythm.", art: "bell", children: ["music.last1", "music.last2", "music.last3"]),
        .init(id: "music.next2", theme: "music", title: "Lead a silly parade", sentence: "Next, our friend led a silly musical parade.", art: "flag", children: ["music.last0", "music.last2", "music.last3"]),
        .init(id: "music.last0", theme: "music", title: "Take a big bow", sentence: "Last, our friend took a bow after the music.", art: "crown", children: []),
        .init(id: "music.last1", theme: "music", title: "Share a happy clap", sentence: "Last, our friend clapped for everyone in the band.", art: "clap", children: []),
        .init(id: "music.last2", theme: "music", title: "Sing a soft goodbye", sentence: "Last, our friend sang a soft goodbye song.", art: "music", children: []),
        .init(id: "music.last3", theme: "music", title: "Put the instruments away", sentence: "Last, our friend put the instruments away together.", art: "box", children: []),
        .init(id: "snow.first", theme: "snow", title: "Explore pretend snow", sentence: "First, our friend went exploring in pretend snow.", art: "snowflake", children: ["snow.next0", "snow.next1", "snow.next2"]),
        .init(id: "snow.next0", theme: "snow", title: "Build a snow friend", sentence: "Next, our friend built a friendly snow person.", art: "snowman", children: ["snow.last0", "snow.last1", "snow.last2"]),
        .init(id: "snow.next1", theme: "snow", title: "Find tiny footprints", sentence: "Next, our friend followed tiny footprints in the snow.", art: "paw", children: ["snow.last1", "snow.last2", "snow.last3"]),
        .init(id: "snow.next2", theme: "snow", title: "Make a snow crown", sentence: "Next, our friend made a sparkly crown from pretend snow.", art: "crown", children: ["snow.last0", "snow.last2", "snow.last3"]),
        .init(id: "snow.last0", theme: "snow", title: "Warm up with a drink", sentence: "Last, our friend warmed up with a cozy drink.", art: "cup", children: []),
        .init(id: "snow.last1", theme: "snow", title: "Wave goodbye to the snow", sentence: "Last, our friend waved goodbye to the snowy world.", art: "wave", children: []),
        .init(id: "snow.last2", theme: "snow", title: "Draw a snowy picture", sentence: "Last, our friend drew a picture of the snowy day.", art: "pencil", children: []),
        .init(id: "snow.last3", theme: "snow", title: "Read under a blanket", sentence: "Last, our friend read a story under a cozy blanket.", art: "book", children: []),
    ]
    static func action(_ id: String) -> ImaginationAction { actions.first { $0.id == id }! }
    static var narration: [String] { [welcome, review] + questions + actions.map(\.sentence) }
}

struct ImaginationPlay {
    enum Phase { case choosing, story, reading, complete }
    private(set) var phase = Phase.choosing
    private(set) var selected: [String] = []
    private(set) var choices: [String]
    private(set) var page = 0
    private(set) var generation = UUID()
    var stage: Int { selected.count }
    var story: [ImaginationAction] { selected.map(ImaginationStories.action) }
    var prompt: String {
        if phase == .reading { return story[page].sentence }
        if phase == .story { return story.last!.sentence }
        return selected.last.map { ImaginationStories.action($0).sentence } ?? ImaginationStories.welcome
    }
    init(previousFirst: String? = nil, rootOrder: [String] = ImaginationStories.roots.shuffled()) {
        precondition(rootOrder.count == 6 && Set(rootOrder) == Set(ImaginationStories.roots))
        let pool = rootOrder.filter { $0 != previousFirst }
        choices = Array(pool.prefix(3))
    }
    @discardableResult mutating func choose(_ id: String, generation token: UUID) -> Bool {
        guard phase == .choosing, token == generation, choices.contains(id), selected.count < 3 else { return false }
        selected.append(id); generation = UUID()
        if selected.count == 3 { phase = .story; choices = [] }
        else { choices = ImaginationStories.action(id).children.shuffled() }
        return true
    }
    mutating func read(_ index: Int = 0) {
        guard [.story, .reading].contains(phase), story.indices.contains(index) else { return }
        page = index; phase = .reading
    }
    mutating func nextPage() { guard phase == .reading, page < 2 else { return }; page += 1 }
    mutating func previousPage() { guard phase == .reading, page > 0 else { return }; page -= 1 }
    mutating func closeBook() { guard phase == .reading else { return }; phase = .story }
    mutating func finish() { guard [.story, .reading].contains(phase) else { return }; phase = .complete }
}
