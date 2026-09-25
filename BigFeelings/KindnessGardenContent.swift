import SwiftUI

struct KindGardenChoice: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let isCaring: Bool
    let response: String
}
struct KindGardenStory: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let question: String
    let choices: [KindGardenChoice]
    static let bank: [Self] = [
        .init(id: "shovel", title: "One playground shovel", symbol: "beach.umbrella.fill", question: "You and a friend both want the playground shovel. Which choice helps?", choices: [
            .init(id: "shovel.care", title: "Ask for a turn", symbol: "bubble.left.fill", isCaring: true, response: "Asking for a turn lets both friends have time to play. Our pretend garden grows!"),
            .init(id: "shovel.unkind", title: "Grab the shovel", symbol: "hand.raised.fill", isCaring: false, response: "Grabbing takes the shovel from your friend. Try asking for a turn."),
        ]),
        .init(id: "crayons", title: "Sharing crayons", symbol: "pencil", question: "Your friend wants a crayon from the shared box. Which choice helps?", choices: [
            .init(id: "crayons.care", title: "Offer a crayon", symbol: "pencil", isCaring: true, response: "Offering a crayon helps your friend join the drawing. Our pretend garden grows!"),
            .init(id: "crayons.unkind", title: "Hide all the crayons", symbol: "eye.slash.fill", isCaring: false, response: "Hiding all the crayons keeps your friend from drawing. Try offering one."),
        ]),
        .init(id: "slide", title: "Waiting at the slide", symbol: "figure.play", question: "A friend is having a turn on the slide. Which choice helps?", choices: [
            .init(id: "slide.care", title: "Wait for my turn", symbol: "clock.fill", isCaring: true, response: "Waiting gives your friend space to finish their turn. Our pretend garden grows!"),
            .init(id: "slide.unkind", title: "Push past my friend", symbol: "hand.raised.fill", isCaring: false, response: "Pushing can hurt someone. Give your friend space and wait for your turn."),
        ]),
        .init(id: "ball", title: "A game of catch", symbol: "soccerball", question: "Your friend is ready to play catch with you. Which choice helps?", choices: [
            .init(id: "ball.care", title: "Pass the ball gently", symbol: "arrow.right", isCaring: true, response: "A gentle pass shares the fun with your friend. Our pretend garden grows!"),
            .init(id: "ball.unkind", title: "Keep every turn", symbol: "lock.fill", isCaring: false, response: "Keeping every turn leaves your friend waiting. Try sharing a turn."),
        ]),
        .init(id: "puzzle", title: "A puzzle together", symbol: "puzzlepiece.fill", question: "You and a friend are making a puzzle. Which choice helps?", choices: [
            .init(id: "puzzle.care", title: "Offer a puzzle piece", symbol: "puzzlepiece.fill", isCaring: true, response: "Offering a piece helps you build the puzzle together. Our pretend garden grows!"),
            .init(id: "puzzle.unkind", title: "Scatter the pieces", symbol: "arrow.up.and.down.and.arrow.left.and.right", isCaring: false, response: "Scattering the pieces makes the puzzle harder for your friend. Try offering a piece."),
        ]),
        .init(id: "blocks", title: "Blocks on the floor", symbol: "square.stack.3d.up.fill", question: "Playtime is finished and blocks cover the floor. Which choice helps?", choices: [
            .init(id: "blocks.care", title: "Help put blocks away", symbol: "basket.fill", isCaring: true, response: "Helping tidy makes a clear space for everyone. Our pretend garden grows!"),
            .init(id: "blocks.unkind", title: "Kick blocks around", symbol: "figure.walk", isCaring: false, response: "Kicking the blocks spreads them around. Try placing them in the basket."),
        ]),
        .init(id: "spill", title: "A little water spill", symbol: "drop.fill", question: "Some water spilled beside the table. Which choice helps?", choices: [
            .init(id: "spill.care", title: "Tell my grown-up", symbol: "bubble.left.fill", isCaring: true, response: "Telling your grown-up helps them make the floor safe and dry. Our pretend garden grows!"),
            .init(id: "spill.unkind", title: "Splash it farther", symbol: "drop.fill", isCaring: false, response: "Splashing spreads the water. Let your grown-up know about the spill."),
        ]),
        .init(id: "books", title: "Books need a shelf", symbol: "books.vertical.fill", question: "The picture books are on the floor after story time. Which choice helps?", choices: [
            .init(id: "books.care", title: "Put books on the shelf", symbol: "books.vertical.fill", isCaring: true, response: "Putting books away helps everyone find them next time. Our pretend garden grows!"),
            .init(id: "books.unkind", title: "Tear a book page", symbol: "scissors", isCaring: false, response: "Tearing a page damages the book. Try handling the pages gently."),
        ]),
        .init(id: "drawing", title: "A friend shares a drawing", symbol: "paintpalette.fill", question: "Your friend shows you a drawing they made. Which choice helps?", choices: [
            .init(id: "drawing.care", title: "Say thanks for showing me", symbol: "bubble.left.fill", isCaring: true, response: "Thanking your friend welcomes what they wanted to share. Our pretend garden grows!"),
            .init(id: "drawing.unkind", title: "Scribble on their drawing", symbol: "pencil.slash", isCaring: false, response: "Scribbling on someone else's drawing can upset them. Ask before adding marks."),
        ]),
        .init(id: "tower", title: "A friend builds a tower", symbol: "building.2.fill", question: "Your friend is carefully building a block tower. Which choice helps?", choices: [
            .init(id: "tower.care", title: "Ask if I can help", symbol: "questionmark.bubble.fill", isCaring: true, response: "Asking gives your friend a choice about building together. Our pretend garden grows!"),
            .init(id: "tower.unkind", title: "Knock their tower down", symbol: "arrow.down", isCaring: false, response: "Knocking the tower down ruins your friend's work. Ask before joining their game."),
        ]),
        .init(id: "join", title: "Someone wants to join", symbol: "person.2.fill", question: "A friend asks to join your pretend picnic. There is room. Which choice helps?", choices: [
            .init(id: "join.care", title: "Make a place for them", symbol: "person.2.fill", isCaring: true, response: "Making a place welcomes your friend into the picnic. Our pretend garden grows!"),
            .init(id: "join.unkind", title: "Laugh and shut them out", symbol: "hand.raised.fill", isCaring: false, response: "Laughing at your friend can hurt their feelings. Try welcoming them kindly."),
        ]),
        .init(id: "thanks", title: "A helping hand", symbol: "gift.fill", question: "Your grown-up helps you find your missing shoe. Which choice helps?", choices: [
            .init(id: "thanks.care", title: "Say or sign thank you", symbol: "hand.wave.fill", isCaring: true, response: "Saying or signing thank you shows you noticed their help. Our pretend garden grows!"),
            .init(id: "thanks.unkind", title: "Throw the shoe at them", symbol: "arrow.up.right", isCaring: false, response: "Throwing a shoe can hurt someone. Try thanking them for helping."),
        ]),
        .init(id: "hug", title: "A friend says no hug", symbol: "heart.fill", question: "Your friend says they do not want a hug. Which choice helps?", choices: [
            .init(id: "hug.care", title: "Offer a friendly wave", symbol: "hand.wave.fill", isCaring: true, response: "A wave respects your friend's choice. Hugs are always a choice. Our pretend garden grows!"),
            .init(id: "hug.unkind", title: "Hug them anyway", symbol: "figure.arms.open", isCaring: false, response: "Hugging after someone says no ignores their choice. Try a friendly wave instead."),
        ]),
        .init(id: "space", title: "A quiet moment", symbol: "leaf.fill", question: "Your friend asks for a little quiet space. Which choice helps?", choices: [
            .init(id: "space.care", title: "Give them some space", symbol: "arrow.left.and.right", isCaring: true, response: "Giving space listens to what your friend needs. Our pretend garden grows!"),
            .init(id: "space.unkind", title: "Shout beside their ear", symbol: "speaker.wave.3.fill", isCaring: false, response: "Shouting beside their ear can feel uncomfortable. Try giving them quiet space."),
        ]),
        .init(id: "turn", title: "The shared toy truck", symbol: "truck.box.fill", question: "You finished your turn with a shared toy truck. Your friend is waiting. Which choice helps?", choices: [
            .init(id: "turn.care", title: "Offer the next turn", symbol: "arrow.right", isCaring: true, response: "Offering the next turn lets your friend enjoy the truck too. Our pretend garden grows!"),
            .init(id: "turn.unkind", title: "Hide the shared truck", symbol: "eye.slash.fill", isCaring: false, response: "Hiding the shared truck keeps your friend from their turn. Try passing it over."),
        ]),
        .init(id: "sorry", title: "An accidental bump", symbol: "person.2.fill", question: "You accidentally bump your friend's arm. Which choice helps?", choices: [
            .init(id: "sorry.care", title: "Ask if they are okay", symbol: "questionmark.bubble.fill", isCaring: true, response: "Checking on your friend shows you care. A grown-up can help if needed. Our pretend garden grows!"),
            .init(id: "sorry.unkind", title: "Bump them again", symbol: "hand.raised.fill", isCaring: false, response: "Bumping again could hurt. Pause and check how your friend feels."),
        ]),
        .init(id: "pet", title: "Gentle hands for a cat", symbol: "pawprint.fill", question: "A grown-up says you may gently pet the cat. Which choice helps?", choices: [
            .init(id: "pet.care", title: "Use gentle hands", symbol: "hand.raised.fill", isCaring: true, response: "Gentle hands help care for the cat. Listen to your grown-up and give the cat space if it moves away. Our pretend garden grows!"),
            .init(id: "pet.unkind", title: "Pull the cat's tail", symbol: "arrow.left", isCaring: false, response: "Pulling a tail hurts the cat. Keep gentle hands and listen to your grown-up."),
        ]),
        .init(id: "flowers", title: "A thirsty garden", symbol: "camera.macro", question: "Your grown-up says the flowers need water. Which choice helps?", choices: [
            .init(id: "flowers.care", title: "Help water the flowers", symbol: "drop.fill", isCaring: true, response: "Helping water the flowers gives them a drink. Our pretend garden grows!"),
            .init(id: "flowers.unkind", title: "Pull out the flowers", symbol: "arrow.up", isCaring: false, response: "Pulling out the flowers damages them. Try helping your grown-up water them."),
        ]),
        .init(id: "litter", title: "A wrapper at the picnic", symbol: "trash.fill", question: "Your snack wrapper is left on the picnic blanket. Which choice helps?", choices: [
            .init(id: "litter.care", title: "Put my wrapper in the bin", symbol: "trash.fill", isCaring: true, response: "Putting your wrapper in the bin helps keep the picnic place clean. Our pretend garden grows!"),
            .init(id: "litter.unkind", title: "Drop it on the grass", symbol: "leaf.fill", isCaring: false, response: "Dropping the wrapper leaves litter behind. Try using the bin."),
        ]),
        .init(id: "snail", title: "A tiny garden visitor", symbol: "leaf.fill", question: "You see a tiny snail beside the garden path. Which choice helps?", choices: [
            .init(id: "snail.care", title: "Watch and give it space", symbol: "eye.fill", isCaring: true, response: "Watching gently gives the little snail space to move. Our pretend garden grows!"),
            .init(id: "snail.unkind", title: "Poke the snail", symbol: "hand.point.up.left.fill", isCaring: false, response: "Poking can hurt a tiny animal. Try watching without touching."),
        ]),
        .init(id: "dropped", title: "Dropped crayons", symbol: "pencil", question: "Your friend drops some crayons on the floor. Which choice helps?", choices: [
            .init(id: "dropped.care", title: "Offer to help pick them up", symbol: "hand.raised.fill", isCaring: true, response: "Offering help makes picking up easier for your friend. Our pretend garden grows!"),
            .init(id: "dropped.unkind", title: "Kick them farther away", symbol: "figure.walk", isCaring: false, response: "Kicking the crayons away makes more work. Try offering to help pick them up."),
        ]),
        .init(id: "listen", title: "A friend is talking", symbol: "ear.fill", question: "Your friend is telling you about their toy. Which choice helps?", choices: [
            .init(id: "listen.care", title: "Listen for my turn to talk", symbol: "ear.fill", isCaring: true, response: "Listening gives your friend a turn to share their story. Our pretend garden grows!"),
            .init(id: "listen.unkind", title: "Shout over their words", symbol: "speaker.wave.3.fill", isCaring: false, response: "Shouting over your friend makes it hard to hear them. Try listening for your turn."),
        ]),
        .init(id: "blanket", title: "A pretend sleepy teddy", symbol: "moon.fill", question: "Your teddy is ready for a pretend nap. Which choice helps?", choices: [
            .init(id: "blanket.care", title: "Make a cozy spot", symbol: "moon.fill", isCaring: true, response: "Making a cozy spot is a caring way to play with your teddy. Our pretend garden grows!"),
            .init(id: "blanket.unkind", title: "Throw teddy across the room", symbol: "arrow.up.right", isCaring: false, response: "Throwing teddy across the room could hit someone. Try making a cozy resting spot."),
        ]),
        .init(id: "painting", title: "Ask before borrowing", symbol: "paintbrush.fill", question: "Your friend is using a paintbrush you would like to borrow. Which choice helps?", choices: [
            .init(id: "painting.care", title: "Ask to use it next", symbol: "questionmark.bubble.fill", isCaring: true, response: "Asking to use it next respects your friend's turn. Our pretend garden grows!"),
            .init(id: "painting.unkind", title: "Snatch the paintbrush", symbol: "hand.raised.fill", isCaring: false, response: "Snatching interrupts your friend's painting. Try asking for the next turn."),
        ]),
    ]
}
struct KindGardenRound {
    let story: KindGardenStory
    let choices: [KindGardenChoice]
}
struct KindGardenPlay {
    enum Phase { case welcome, choosing, feedback, complete }
    let rounds: [KindGardenRound]
    private(set) var phase: Phase = .welcome
    private(set) var index = 0
    private(set) var flowers = 3
    private(set) var previousFlowers = 3
    private(set) var selected: KindGardenChoice?
    private(set) var triedUnkind = false
    var current: KindGardenRound { rounds[min(index, rounds.count - 1)] }
    var prompt: String {
        switch phase {
        case .welcome: return Self.invitation
        case .choosing: return triedUnkind ? Self.retry : current.story.question
        case .feedback: return selected!.response
        case .complete: return Self.completion
        }
    }
    var feedbackTitle: String {
        if selected?.isCaring == true { return "The garden grew!" }
        return flowers < previousFlowers ? "A flower faded" : "The garden is resting"
    }
    init(previousFirst: String = "") {
        var stories = KindGardenStory.bank.shuffled()
        if stories[0].id == previousFirst { stories.swapAt(0, 1) }
        rounds = stories.prefix(12).map { KindGardenRound(story: $0, choices: $0.choices.shuffled()) }
    }
    mutating func start() {
        guard phase == .welcome else { return }
        phase = .choosing
    }
    mutating func choose(_ id: String, story: String) {
        guard phase == .choosing, story == current.story.id,
              let choice = current.choices.first(where: { $0.id == id }),
              choice.isCaring || !triedUnkind else { return }
        previousFlowers = flowers
        flowers = min(15, max(0, flowers + (choice.isCaring ? 1 : -1)))
        selected = choice; triedUnkind = triedUnkind || !choice.isCaring; phase = .feedback
    }
    mutating func tryAgain() {
        guard phase == .feedback, selected?.isCaring == false else { return }
        selected = nil; phase = .choosing
    }
    mutating func next(_ story: String) {
        guard phase == .feedback, current.story.id == story else { return }
        index += 1; selected = nil; triedUnkind = false
        phase = index == rounds.count ? .complete : .choosing
    }
    static let invitation = "This is our pretend kindness garden. Caring choices help flowers grow. Unhelpful choices make flowers fade. We can always try a caring choice. Let's explore together!"
    static let retry = "Let's try the other choice. We can practice kindness."
    static let completion = "We did it together! You can play again or choose all done."
    static var narration: [String] {
        [invitation, retry, completion] + KindGardenStory.bank.flatMap { [$0.question] + $0.choices.flatMap { [$0.title, $0.response] } }
    }
}
