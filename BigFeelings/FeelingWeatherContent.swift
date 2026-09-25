import SwiftUI

struct FeelingWeatherSupport: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let response: String
    static let other = Self(id: "other", title: "Something else", symbol: "ellipsis.bubble.fill", response: "You would like something else. Tell or show your grown-up what you need. Your choice matters.")
}

enum FeelingWeatherMood: String, CaseIterable, Identifiable {
    case happy, sad, mad, worried, calm, unsure
    var id: String { rawValue }
    var name: String {
        switch self {
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .mad: return "Mad"
        case .worried: return "Worried"
        case .calm: return "Calm"
        case .unsure: return "Not sure"
        }
    }
    var symbol: String {
        switch self {
        case .happy: return "sun.max.fill"
        case .sad: return "cloud.rain.fill"
        case .mad: return "cloud.bolt.fill"
        case .worried: return "cloud.fill"
        case .calm: return "cloud.sun.fill"
        case .unsure: return "questionmark.bubble.fill"
        }
    }
    var color: Color {
        switch self {
        case .happy: return .orange
        case .sad: return .blue
        case .mad: return .red
        case .worried: return .purple
        case .calm: return .teal
        case .unsure: return .indigo
        }
    }
    var sizePrompt: String { "You chose " + name + ". Does this feeling seem little, medium, or big? Not sure is okay too." }
    var supportPrompt: String {
        self == .unsure ? "It is okay not to know yet. What would you like right now?" : "You chose " + name + ". What would you like right now? Every choice is okay."
    }
    var supports: [FeelingWeatherSupport] {
        let tailored: [FeelingWeatherSupport]
        switch self {
        case .happy: tailored = [
            .init(id: "happy.news", title: "Share my good news", symbol: "bubble.left.fill", response: "You would like to share your good news. Tell or show your grown-up!"),
            .init(id: "happy.dance", title: "Do a happy dance", symbol: "figure.dance", response: "You would like a happy dance. Invite your grown-up to dance with you!"),
            .init(id: "happy.play", title: "Invite someone to play", symbol: "person.2.fill", response: "You would like to play together. Ask someone if they would like to join you!"),
            .init(id: "happy.draw", title: "Draw a happy picture", symbol: "pencil", response: "You would like to draw a happy picture. Ask your grown-up for some paper and crayons!"),
        ]
        case .sad: tailored = [
            .init(id: "sad.together", title: "Sit with my grown-up", symbol: "person.2.fill", response: "You would like your grown-up to sit with you. You can ask them to stay close."),
            .init(id: "sad.toy", title: "Cuddle my soft toy", symbol: "heart.fill", response: "You would like to cuddle your soft toy. Your grown-up can help you find it."),
            .init(id: "sad.hug", title: "Ask for a hug", symbol: "figure.arms.open", response: "You would like to ask for a hug. Hugs are a choice for both people."),
            .init(id: "sad.story", title: "Read a cozy story", symbol: "book.fill", response: "You would like a cozy story. Choose a book to read with your grown-up."),
        ]
        case .mad: tailored = [
            .init(id: "mad.squeeze", title: "Squeeze a soft toy", symbol: "hands.clap.fill", response: "You would like to gently squeeze a soft toy. Ask your grown-up to find one with you."),
            .init(id: "mad.pause", title: "Take a quiet pause", symbol: "pause.circle.fill", response: "You would like a quiet pause. Let your grown-up know you would like a little space."),
            .init(id: "mad.tell", title: "Tell a grown-up", symbol: "bubble.left.fill", response: "You would like to tell a grown-up what happened. You can use words, signs, or pointing."),
            .init(id: "mad.stretch", title: "Try a gentle stretch", symbol: "figure.flexibility", response: "You would like a gentle stretch. Try a comfortable little stretch with your grown-up."),
        ]
        case .worried: tailored = [
            .init(id: "worried.hand", title: "Hold my grown-up's hand", symbol: "hand.raised.fill", response: "You would like to hold your grown-up's hand. You can ask them."),
            .init(id: "worried.next", title: "Ask what happens next", symbol: "questionmark.bubble.fill", response: "You would like to know what happens next. Ask your grown-up to tell or show you."),
            .init(id: "worried.near", title: "Stay near my grown-up", symbol: "person.2.fill", response: "You would like to stay near your grown-up. Tell or show them you want to be close."),
            .init(id: "worried.comfort", title: "Bring my comfort toy", symbol: "heart.fill", response: "You would like to bring your comfort toy. Ask your grown-up to help you find it."),
        ]
        case .calm: tailored = [
            .init(id: "calm.quietplay", title: "Keep playing quietly", symbol: "puzzlepiece.fill", response: "You would like to keep playing quietly. Choose something you enjoy."),
            .init(id: "calm.song", title: "Listen to a gentle song", symbol: "music.note", response: "You would like a gentle song. Ask your grown-up to sing or play one with you."),
            .init(id: "calm.book", title: "Look at a picture book", symbol: "book.fill", response: "You would like to look at a picture book. You can enjoy it with your grown-up."),
            .init(id: "calm.moment", title: "Enjoy a quiet moment", symbol: "leaf.fill", response: "You would like a quiet moment. You and your grown-up can settle somewhere comfortable."),
        ]
        case .unsure: tailored = [
            .init(id: "unsure.name", title: "Name feelings together", symbol: "bubble.left.and.bubble.right.fill", response: "You would like to name feelings together. Your grown-up can help you find words."),
            .init(id: "unsure.point", title: "Point to how I feel", symbol: "hand.point.up.left.fill", response: "You would like to point to how you feel. You can point to a face or a feeling picture."),
            .init(id: "unsure.think", title: "Sit and think together", symbol: "person.2.fill", response: "You would like to sit and think together. There is no hurry to choose a feeling."),
            .init(id: "unsure.later", title: "Choose a feeling later", symbol: "clock.fill", response: "You would like to choose later. It is okay not to know how you feel yet."),
        ]
        }
        return tailored + [.other]
    }
}

enum FeelingWeatherSize: String, CaseIterable, Identifiable {
    case little, medium, big, unsure
    var id: String { rawValue }
    var title: String { self == .unsure ? "Not sure" : rawValue.capitalized }
}

struct FeelingWeatherPlay {
    enum Phase { case feeling, size, support, review, complete }
    private(set) var feeling: FeelingWeatherMood?
    private(set) var size: FeelingWeatherSize?
    private(set) var support: FeelingWeatherSupport?
    private(set) var finished = false
    var phase: Phase {
        if finished { return .complete }
        if support != nil { return .review }
        if size != nil { return .support }
        return feeling == nil ? .feeling : .size
    }
    var prompt: String {
        switch phase {
        case .feeling: return Self.invitation
        case .size: return feeling!.sizePrompt
        case .support: return feeling!.supportPrompt
        case .review: return support!.response
        case .complete: return Self.completion
        }
    }
    mutating func choose(_ feeling: FeelingWeatherMood) {
        guard phase == .feeling else { return }
        self.feeling = feeling
    }
    mutating func chooseSize(_ size: FeelingWeatherSize) {
        guard phase == .size else { return }
        self.size = size
    }
    mutating func chooseSupport(_ id: String, for mood: FeelingWeatherMood) {
        guard phase == .support, feeling == mood, let choice = mood.supports.first(where: { $0.id == id }) else { return }
        support = choice
    }
    mutating func finish() {
        guard phase == .review else { return }
        finished = true
    }
    mutating func reset() { self = Self() }
    static let invitation = "What is your feeling weather? You can choose any feeling, or not sure."
    static let completion = "We did it together! You can play again or choose all done."
    static var narration: [String] {
        [invitation, completion] + FeelingWeatherMood.allCases.flatMap { [$0.sizePrompt, $0.supportPrompt] + $0.supports.flatMap { [$0.title, $0.response] } }
    }
}
