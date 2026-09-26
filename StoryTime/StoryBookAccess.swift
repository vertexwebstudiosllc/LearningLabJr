import Foundation

extension StoryBook {
    static let readTogetherBooks: [StoryBook] = [.owenOnion, .dinoBasketball, .dinoHockey, .dinoBaseball]

    var accessActivity: LearningActivity {
        let id: String
        switch self {
        case .owenOnion: id = "books.owen-onion"
        case .dinoBasketball: id = "books.dino-basketball"
        case .dinoHockey: id = "books.dino-hockey"
        case .dinoBaseball: id = "books.dino-baseball"
        }
        return LearningActivity(id: id, title: title, skill: "Listen, look, and talk together",
                                interaction: "Read a story with a grown-up", ageBand: "Ages 3–4 with a grown-up",
                                caregiverTip: "Read a little or a lot. Pause to talk about the pictures.")
    }
}
