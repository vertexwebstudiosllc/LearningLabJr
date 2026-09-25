import SwiftUI

struct BridgeChoice {
    let title: String
    let response: String
}
struct BridgeCopy: Identifiable {
    let id: Int
    let title: String
    let symbol: String
    static let faces = [BridgeCopy(id: 0, title: "Smile", symbol: "face.smiling.fill"), BridgeCopy(id: 1, title: "Wink", symbol: "eye"), BridgeCopy(id: 2, title: "Surprise", symbol: "sparkles")]
    static let animals = [BridgeCopy(id: 0, title: "Bunny", symbol: "hare.fill"), BridgeCopy(id: 1, title: "Bird", symbol: "bird.fill"), BridgeCopy(id: 2, title: "Fish", symbol: "fish.fill")]
}
struct BridgeAdventure: Identifiable {
    enum Kind: String, CaseIterable { case wave, build, pass, copy, bubbles, tidy }
    let id: String
    let title: String
    let kind: Kind
    let symbol: String
    let question: String
    let choices: [BridgeChoice]
    let instruction: String
    let outcome: String
    var goal: Int { kind == .wave ? 3 : kind == .copy || kind == .tidy ? 4 : 6 }
    var copies: [BridgeCopy] { id == "animals" ? BridgeCopy.animals : BridgeCopy.faces }
    func playPrompt(turn: Int, copy: Int = 0) -> String {
        switch kind {
        case .wave: return instruction
        case .copy: return instruction + " Tap " + copies[copy].title.lowercased() + "."
        case .build, .pass, .bubbles: return instruction + (turn == 0 ? " Your turn!" : " Your friend's turn!")
        case .tidy: return instruction
        }
    }
    static let bank: [BridgeAdventure] = [
        .init(id: "hello", title: "Hello, new friend!", kind: .wave, symbol: "hand.wave.fill", question: "A new friend is here. How would you like to say hello?", choices: [
            .init(title: "Give a little wave", response: "A little wave says hello. Let us practice a friendly greeting."),
            .init(title: "Give a friendly smile", response: "A smile can say hello, too. Let us practice a friendly greeting."),
        ], instruction: "Tap to send three friendly greetings.", outcome: "You said hello! A wave or a smile can help start a friendship."),
        .init(id: "space", title: "Give a friend space", kind: .wave, symbol: "heart.fill", question: "Your friend would like to watch for now. What could you do?", choices: [
            .init(title: "Wave from here", response: "A wave from here gives your friend space to watch."),
            .init(title: "Smile and give space", response: "A smile gives your friend a welcome without asking them to join."),
        ], instruction: "Send three gentle greetings from your side. Your friend can watch.", outcome: "You gave your friend space. Friends can choose to watch or play."),
        .init(id: "tower", title: "A tower for two", kind: .build, symbol: "square.fill", question: "There are shared blocks for both of you. How could you start?", choices: [
            .init(title: "Ask to build together", response: "Your friend says yes. Let us take turns adding blocks."),
            .init(title: "Offer the first block", response: "Your friend accepts a block. Let us build together."),
        ], instruction: "Drag each block to the glowing building spot.", outcome: "You shared the blocks and built together. Each friend had a turn!"),
        .init(id: "bridge", title: "Build a little bridge", kind: .build, symbol: "rectangle.fill", question: "Your friend wants to help build a bridge. What could you say?", choices: [
            .init(title: "Let us take turns", response: "Your friend agrees. A turn for each builder!"),
            .init(title: "We can share these blocks", response: "Your friend is ready to share the building blocks."),
        ], instruction: "Drag each block to the glowing building spot.", outcome: "Two builders made a bridge together. Sharing ideas helps us play!"),
        .init(id: "ball", title: "Roll and return", kind: .pass, symbol: "soccerball", question: "You would like to play ball with your friend. How could you ask?", choices: [
            .init(title: "Want to roll the ball?", response: "Your friend says yes to a gentle rolling game."),
            .init(title: "Shall we play together?", response: "Your friend wants to play. Let us share the ball."),
        ], instruction: "Tap the ball to roll it back and forth.", outcome: "You rolled, waited, and got a turn again. That is taking turns!"),
        .init(id: "car", title: "A shared toy road", kind: .pass, symbol: "car.side.fill", question: "You both want a turn with a toy car. What is a friendly plan?", choices: [
            .init(title: "A turn for each of us", response: "Your friend agrees to take turns driving the toy car."),
            .init(title: "Let us pass it back and forth", response: "Your friend likes that plan. Let us share the toy car."),
        ], instruction: "Tap the car to send it along your shared road.", outcome: "The car went to both friends. Waiting made room for another turn."),
        .init(id: "faces", title: "Silly face twins", kind: .copy, symbol: "face.smiling.fill", question: "Your friend wants a silly face game. How could you join?", choices: [
            .init(title: "Let us copy each other", response: "Your friend makes a face. Let us find the matching silly face."),
            .init(title: "Show me a silly face", response: "Your friend has a silly face to show. Let us copy it."),
        ], instruction: "Find the picture that matches your friend.", outcome: "You copied silly faces together. Friends can share a giggle!"),
        .init(id: "animals", title: "Pretend animal pals", kind: .copy, symbol: "pawprint.fill", question: "Your friend wants to pretend to be animals. What could you say?", choices: [
            .init(title: "Let us pretend together", response: "Your friend chooses an animal. Find the matching animal picture."),
            .init(title: "You choose, then I will try", response: "Your friend chooses first. You can copy the picture or pretend along."),
        ], instruction: "Find the picture that matches your friend.", outcome: "You tried a pretend game together. Watching and tiny movements count, too."),
        .init(id: "bubbles", title: "Bubble buddies", kind: .bubbles, symbol: "circle.fill", question: "You both want to pop bubbles. What would help you share?", choices: [
            .init(title: "One for me, one for you", response: "Your friend likes taking turns with the bubbles."),
            .init(title: "Let us leave some for each other", response: "You leave bubbles for your friend. Let us take turns."),
        ], instruction: "Pop a teal bubble for you, then a purple bubble for your friend.", outcome: "You left bubbles for each other. Sharing kept the fun going!"),
        .init(id: "stars", title: "Share the sparkles", kind: .bubbles, symbol: "star.fill", question: "There are sparkly stars for both friends. How could you share?", choices: [
            .init(title: "We can take turns", response: "Your friend agrees to take turns choosing stars."),
            .init(title: "Some for you and some for me", response: "There are stars for both of you. Let us take turns."),
        ], instruction: "Tap a teal star for you, then a purple star for your friend.", outcome: "Both friends got sparkles. A fair turn can feel good!"),
        .init(id: "tidy", title: "Team tidy-up", kind: .tidy, symbol: "teddybear.fill", question: "Your friend has toys to put away. How could you help?", choices: [
            .init(title: "Can I help tidy up?", response: "Your friend says yes. Let us put the toys in the box together."),
            .init(title: "Let us each put some away", response: "Your friend likes sharing the tidy-up job."),
        ], instruction: "Drag each toy into the toy box.", outcome: "You helped tidy the shared space. Helping is a way to care for a friend."),
        .init(id: "picture", title: "Our friendship picture", kind: .tidy, symbol: "heart.fill", question: "Your friend is making a picture. How could you join?", choices: [
            .init(title: "May I add a heart?", response: "Your friend says yes. Add hearts to your shared picture."),
            .init(title: "Let us decorate together", response: "Your friend wants to decorate together. Add hearts to the picture."),
        ], instruction: "Drag each heart onto the friendship picture.", outcome: "You made a picture together. Different ideas can belong side by side."),
    ]
    static let welcome = "Choose a buddy for a friendship adventure. We can say hello, share, and play together!"
    static let retry = "Let's look at whose turn it is. Try the glowing spot."
    static let copyRetry = "Let's look again. Find the same picture as your friend."
    static let completion = "We did it together! You can play again or choose all done."
    static var narration: [String] {
        [welcome, retry, copyRetry, completion] + bank.flatMap { adventure in
            [adventure.question, adventure.outcome] + adventure.choices.flatMap { [$0.title, $0.response] }
            + (0..<2).flatMap { turn in (0..<3).map { adventure.playPrompt(turn: turn, copy: $0) } }
        }
    }
}

struct BridgePlay {
    enum Phase { case friends, choosing, ready, playing, celebration, complete }
    let adventures: [BridgeAdventure]
    private(set) var phase = Phase.friends
    private(set) var friend: TogetherFriend?
    private(set) var index = 0
    private(set) var choice = 0
    private(set) var actions = 0
    private(set) var popped = Set<Int>()
    private(set) var copySequence: [Int] = []
    private(set) var copyChoices = [0, 1, 2]
    private(set) var bubbles = Array(0..<6)
    var current: BridgeAdventure { adventures[min(index, adventures.count - 1)] }
    var turn: Int { actions % 2 }
    var bridgePieces: Int { min(12, index + (phase == .celebration ? 1 : 0)) }
    var copyTarget: Int { copySequence[min(actions, copySequence.count - 1)] }
    var token: String { current.id + ":" + String(actions) }
    var prompt: String {
        switch phase {
        case .friends: return BridgeAdventure.welcome
        case .choosing: return current.question
        case .ready: return current.choices[choice].response
        case .playing: return current.playPrompt(turn: turn, copy: copyTarget)
        case .celebration: return current.outcome
        case .complete: return BridgeAdventure.completion
        }
    }
    init(previousFirst: String = "") {
        var deck = BridgeAdventure.bank.shuffled()
        if deck[0].id == previousFirst { deck.swapAt(0, Int.random(in: 1..<deck.count)) }
        adventures = deck
        resetActions()
    }
    private mutating func resetActions() {
        actions = 0; popped = []; bubbles.shuffle(); copyChoices.shuffle()
        copySequence = Array(0..<4).map { _ in Int.random(in: 0..<3) }
        for i in 1..<copySequence.count where copySequence[i] == copySequence[i - 1] {
            copySequence[i] = (copySequence[i] + Int.random(in: 1...2)) % 3
        }
    }
    mutating func chooseFriend(_ id: String) {
        guard phase == .friends, let selected = TogetherFriend.bank.first(where: { $0.id == id }) else { return }
        friend = selected; phase = .choosing
    }
    mutating func chooseWords(_ index: Int) {
        guard phase == .choosing, current.choices.indices.contains(index) else { return }
        choice = index; phase = .ready
    }
    mutating func start() { guard phase == .ready else { return }; phase = .playing }
    @discardableResult mutating func act(_ value: Int, token: String, target: Int = 0) -> Bool {
        guard phase == .playing, token == self.token else { return false }
        let valid: Bool
        switch current.kind {
        case .wave: valid = value == 0
        case .pass: valid = value == turn
        case .copy: valid = value == copyTarget
        case .build: valid = value == actions && target == turn
        case .tidy: valid = value == actions && target == 0
        case .bubbles: valid = (0..<6).contains(value) && value % 2 == turn && !popped.contains(value)
        }
        guard valid else { return false }
        if current.kind == .bubbles { popped.insert(value) }
        actions += 1
        if actions == current.goal { phase = .celebration }
        return true
    }
    mutating func next() {
        guard phase == .celebration else { return }
        index += 1
        if index == adventures.count { phase = .complete }
        else { resetActions(); phase = .choosing }
    }
}
