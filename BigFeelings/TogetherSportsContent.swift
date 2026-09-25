import SwiftUI

enum TogetherSport: String, CaseIterable, Identifiable {
    case soccer, basketball, catchBall, tennis, bowling, hockey
    var id: String { rawValue }
    var name: String {
        switch self {
        case .soccer: return "Soccer"
        case .basketball: return "Basketball"
        case .catchBall: return "Play catch"
        case .tennis: return "Tennis"
        case .bowling: return "Bowling"
        case .hockey: return "Hockey"
        }
    }
    var action: String {
        switch self {
        case .soccer: return "Pass the soccer ball"
        case .basketball: return "Bounce the basketball"
        case .catchBall: return "Toss the soft ball"
        case .tennis: return "Tap the tennis ball"
        case .bowling: return "Roll the bowling ball"
        case .hockey: return "Slide the puck"
        }
    }
    var prompt: String { action + " to your friend. Then we will wait for a turn back." }
    var chooseFriend: String { name + "! Who would you like to play with? Every friend can play every game." }
    var color: Color {
        switch self {
        case .soccer: return .green
        case .basketball: return .orange
        case .catchBall: return .pink
        case .tennis: return .yellow
        case .bowling: return .purple
        case .hockey: return .blue
        }
    }
}

struct TogetherFriend: Identifiable {
    enum Hair { case curls, short, long, bun, headscarf }
    let id: String
    let name: String
    let skin: UInt
    let hair: UInt
    let style: Hair
    let shirt: UInt
    var wheelchair = false
    var glasses = false
    var hearingAid = false
    var introduction: String { "This is " + name + ". Would you like to play together?" }
    var ready: String { name + " says, yes! Let's take turns." }
    var waiting: String { "Now it is " + name + "'s turn. Let's watch and wait." }
    var thanks: String { name + " says, thank you for playing with me!" }
    var appearance: String {
        name + (wheelchair ? ", using a wheelchair" : "") + (glasses ? ", wearing glasses" : "") + (hearingAid ? ", wearing a hearing aid" : "")
    }
    static let bank: [Self] = [
        .init(id: "maya", name: "Maya", skin: 0x70452F, hair: 0x292222, style: .curls, shirt: 0xDA4779),
        .init(id: "leo", name: "Leo", skin: 0xEFBF99, hair: 0x9A542E, style: .short, shirt: 0x2F82BA, glasses: true),
        .init(id: "amina", name: "Amina", skin: 0xB17A52, hair: 0x855BB0, style: .headscarf, shirt: 0x239C92),
        .init(id: "kai", name: "Kai", skin: 0xE0A879, hair: 0x27242C, style: .short, shirt: 0xDDA62C, wheelchair: true),
        .init(id: "zoe", name: "Zoe", skin: 0xF3CFAE, hair: 0xC0662D, style: .bun, shirt: 0x775CB4, hearingAid: true),
        .init(id: "noah", name: "Noah", skin: 0x986546, hair: 0x362B29, style: .curls, shirt: 0x418F61),
        .init(id: "mei", name: "Mei", skin: 0xEBC3A0, hair: 0x29242C, style: .long, shirt: 0xCA6571),
        .init(id: "sam", name: "Sam", skin: 0xC89364, hair: 0x694129, style: .short, shirt: 0x448EAB),
    ]
}

struct TogetherKindWords: Identifiable {
    let id: String
    let title: String
    let spoken: String
    let response: String
    static let bank: [Self] = [
        .init(id: "ready", title: "Ready for another turn?", spoken: "Ready for another turn?", response: "Your friend says yes. Asking helps us play together!"),
        .init(id: "nice", title: "That was a kind pass!", spoken: "That was a kind pass!", response: "A friendly word can help someone feel welcome."),
        .init(id: "share", title: "We can share!", spoken: "We can share!", response: "One turn for you, one turn for your friend. Both of you get to play!"),
        .init(id: "gentle", title: "Let's play gently!", spoken: "Let's play gently!", response: "Gentle passes help us enjoy the game together."),
        .init(id: "thanks", title: "Thanks for playing!", spoken: "Thanks for playing!", response: "You thanked your friend. What a friendly way to finish!"),
        .init(id: "fun", title: "It was fun together!", spoken: "It was fun together!", response: "You shared the fun. Everyone had time to play!"),
    ]
}

struct TogetherSportsPlay {
    enum Phase: String { case sport, friend, invite, yourTurn, outbound, friendTurn, inbound, shared, kindWords, response, thanks, complete }
    let id = UUID()
    private(set) var phase: Phase = .sport
    private(set) var sport: TogetherSport?
    private(set) var friend: TogetherFriend?
    private(set) var completed = 0
    private(set) var response = ""
    let friends = TogetherFriend.bank.shuffled()
    let encouragements = ["You shared a turn!", "You waited and your friend passed back!", "A turn for each of you. That is sharing!"].shuffled()
    var kindChoices: [TogetherKindWords] { Array(TogetherKindWords.bank[(completed == 2 ? 0 : completed == 4 ? 2 : 4)..<(completed == 2 ? 2 : completed == 4 ? 4 : 6)]) }
    var prompt: String {
        switch phase {
        case .sport: return Self.invitation
        case .friend: return sport?.chooseFriend ?? Self.invitation
        case .invite: return friend?.introduction ?? Self.invitation
        case .yourTurn: return sport?.prompt ?? Self.invitation
        case .outbound, .friendTurn, .inbound: return friend?.waiting ?? Self.invitation
        case .shared: return encouragements[completed % encouragements.count]
        case .kindWords: return Self.kindPrompt
        case .response: return response
        case .thanks: return friend?.thanks ?? Self.finished
        case .complete: return Self.finished
        }
    }
    mutating func choose(_ sport: TogetherSport) {
        guard phase == .sport else { return }
        self.sport = sport; phase = .friend
    }
    mutating func chooseFriend(_ id: String) {
        guard phase == .friend, let chosen = friends.first(where: { $0.id == id }) else { return }
        friend = chosen; phase = .invite
    }
    mutating func changeSport() {
        guard phase == .friend else { return }
        sport = nil; phase = .sport
    }
    mutating func changeFriend() {
        guard phase == .invite else { return }
        friend = nil; phase = .friend
    }
    mutating func invite() {
        guard phase == .invite else { return }
        phase = .response; response = friend!.ready
    }
    mutating func continuePlaying() {
        guard phase == .response || phase == .shared || phase == .thanks else { return }
        if phase == .thanks { phase = .complete }
        else if phase == .shared && completed.isMultiple(of: 2) { phase = .kindWords }
        else if completed == 6 { phase = .thanks }
        else { phase = .yourTurn }
    }
    mutating func pass() {
        guard phase == .yourTurn, completed < 6 else { return }
        phase = .outbound
    }
    // Each automatic step is tied to the exact session, rally and phase that scheduled it.
    mutating func finishMotion(session: UUID, rally: Int, phase expected: Phase) {
        guard session == id, rally == completed, phase == expected else { return }
        switch phase {
        case .outbound: phase = .friendTurn
        case .friendTurn: phase = .inbound
        case .inbound: completed += 1; phase = .shared
        default: break
        }
    }
    mutating func say(_ id: String) {
        guard phase == .kindWords, let choice = kindChoices.first(where: { $0.id == id }) else { return }
        response = choice.response; phase = .response
    }
    static let invitation = "Let's share the fun! Pick a sport, choose a friend, and take turns together."
    static let kindPrompt = "Let's say something kind to our friend. Choose either friendly message."
    static let finished = "We did it together! You can play again or choose all done."
    static var narration: [String] {
        [invitation, kindPrompt, finished] + TogetherSport.allCases.flatMap { [$0.prompt, $0.chooseFriend] }
        + TogetherFriend.bank.flatMap { [$0.introduction, $0.ready, $0.waiting, $0.thanks] }
        + TogetherKindWords.bank.flatMap { [$0.spoken, $0.response] }
        + TogetherSportsPlay().encouragements
    }
}

extension Color {
    static func sportsRGB(_ hex: UInt) -> Color {
        Color(red: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255)
    }
}
