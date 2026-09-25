import SwiftUI

struct StoryTimeMenu: View {
    static let activities: [LearningActivity] = StoryActivity.allCases.map(\.metadata)

    var body: some View {
        ActivityMenu(title: "Story & Language", subtitle: "12 ways to listen, talk, imagine, and read together", accent: .purple) {
            ForEach(StoryActivity.allCases) { activity in
                NavigationLink {
                    StoryActivityDestination(activity: activity)
                        .learningActivity(activity.metadata)
                } label: {
                    ActivityCard(title: activity.metadata.title, subtitle: activity.metadata.skill,
                                 symbol: activity.id, accent: .purple)
                }.buttonStyle(.plain)
            }
        }
    }
}

enum StoryActivity: String, CaseIterable, Identifiable {
    case library, pictureHunt, storyOrder, puppets, finishSentence, soundStory, storyBag, sillyScene, bunny, conversation, storyChoices, sentenceBuilder
    var id: String { "stories.\(rawValue)" }
    var metadata: LearningActivity {
        let details: (String, String, String, String)
        switch self {
        case .library: details = ("Read Together", "Shared reading", "Listen to and turn the pages of four illustrated books", "For a younger toddler, describe a few pictures instead of reading every word. Stop whenever your child is ready.")
        case .pictureHunt: details = ("Picture Hunt", "Listening & vocabulary", "Find named objects within a picnic scene", "Let your child point, speak, or use their home language.")
        case .storyOrder: details = ("First, Next, Last", "Everyday sequences", "Arrange a three-picture routine in order", "Talk about the steps in a familiar real-life routine.")
        case .puppets: details = ("Puppet Friends", "Pretend dialogue", "Give two puppets turns to greet, speak, and say goodbye", "Use different voices and leave a pause for your child’s reply.")
        case .finishSentence: details = ("Finish My Sentence", "Understand spoken sentences", "Complete an everyday spoken sentence with a picture", "Expand your child’s words: ‘Ball’ can become ‘A bouncy ball!’")
        case .soundStory: details = ("A Noisy Little Story", "Listening & sound imitation", "Bring story scenes to life by activating sound events", "Copy the sounds with your child. No microphone or recording is needed.")
        case .storyBag: details = ("The Story Bag", "Imagination & describing", "Uncover three surprise props and invent a story together", "There are no wrong stories. Your child can point while you supply words.")
        case .sillyScene: details = ("Silly Story Fixer", "Make sense of a scene", "Spot a silly detail and replace it with a fitting object", "Laugh together and explain what makes each scene silly.")
        case .bunny: details = ("Where Is Bunny?", "Words for position", "Place Bunny in, on, and beside a box", "Practice the same words with a real toy and box.")
        case .conversation: details = ("Picnic Chat", "Conversation turns", "Choose what to say and hear a friendly reply", "Pause before choosing; invite your child to answer in any way.")
        case .storyChoices: details = ("Choose Our Adventure", "Predict & create", "Make decisions that change a short story’s path and ending", "Ask what might happen next. Both choices make a valid story.")
        case .sentenceBuilder: details = ("Make a Sentence", "Combine words", "Choose a character, action, and object, then hear your sentence", "Act out the sentence and try changing one word together.")
        }
        return LearningActivity(id: id, title: details.0, skill: details.1, interaction: details.2,
                                ageBand: self == .library || self == .storyOrder || self == .sentenceBuilder ? "3–4 with a grown-up" : "2–4 with a grown-up", caregiverTip: details.3)
    }
    var symbol: String {
        switch self {
        case .library: "book.fill"
        case .pictureHunt: "magnifyingglass"
        case .storyOrder: "arrow.right.square.fill"
        case .puppets: "theatermasks.fill"
        case .finishSentence: "text.bubble.fill"
        case .soundStory: "speaker.wave.2.fill"
        case .storyBag: "bag.fill"
        case .sillyScene: "face.smiling.fill"
        case .bunny: "shippingbox.fill"
        case .conversation: "bubble.left.and.bubble.right.fill"
        case .storyChoices: "arrow.triangle.branch"
        case .sentenceBuilder: "rectangle.3.group.fill"
        }
    }
    var asset: String? {
        switch self {
        case .library: "OwenOnionPage1"
        case .pictureHunt: "Apple"
        case .puppets: "dog"
        case .soundStory: "duck"
        case .storyBag: "basketball"
        case .bunny, .storyChoices: "rabbit"
        default: nil
        }
    }
}

struct StoryActivityDestination: View {
    let activity: StoryActivity
    @ViewBuilder var body: some View {
        switch activity {
        case .library: StoryLibraryView()
        case .pictureHunt: StoryPictureHunt()
        case .storyOrder: StorySequenceGame()
        case .puppets: PuppetFriendsGame()
        case .finishSentence: FinishSentenceGame()
        case .soundStory: NoisyStoryGame()
        case .storyBag: StoryBagGame()
        case .sillyScene: SillyStoryGame()
        case .bunny: BunnyPositionGame()
        case .conversation: PicnicChatGame()
        case .storyChoices: ChooseAdventureGame()
        case .sentenceBuilder: SentenceBuilderGame()
        }
    }
}

private struct StoryLibraryView: View {
    private let books: [StoryBook] = [.owenOnion, .dinoBasketball, .dinoHockey, .dinoBaseball]
    private let covers = ["OwenOnionPage1", "DinoBasketballPage1", "DinoHockeyPage1", "DinoBaseballPage1"]
    var body: some View {
        ActivityMenu(title: "Read Together", subtitle: "Four longer stories for ages 3–4 with a grown-up. Read a little or a lot.", accent: .purple, activityCount: 4) {
            ForEach(books.indices, id: \.self) { index in
                NavigationLink {
                    StoryBookGame(book: books[index])
                } label: {
                    ActivityCard(title: books[index].title, subtitle: "Listen, look, and talk together", symbol: "book.fill", asset: covers[index], accent: .purple)
                }.buttonStyle(.plain)
            }
        }
    }
}
