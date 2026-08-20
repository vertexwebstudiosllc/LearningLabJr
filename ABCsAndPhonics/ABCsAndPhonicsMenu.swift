import SwiftUI

struct ABCsAndPhonicsMenu: View {
    static let activities: [LearningActivity] = [
        .init(id: "phonics.letter-match", title: "Letter Twins", skill: "Notice matching letter shapes", interaction: "Match a large letter to its identical twin", ageBand: "Ages 2–4", caregiverTip: "Notice lines and curves together; letter names can come gradually."),
        .init(id: "phonics.letter-draw", title: "Letter Draw", skill: "Explore letter formation", interaction: "Trace one large letter or draw it in the air together", ageBand: "Optional · Ages 4+", caregiverTip: "Let your child use a whole arm in the air before tracing on screen."),
        .init(id: "phonics.sound-baskets", title: "Sound Baskets", skill: "Group words by their first sound", interaction: "Sort picture cards into two sound families", ageBand: "Optional · Ages 4+", caregiverTip: "Stretch the first sound in moon and sun without adding an 'uh'."),
        .init(id: "phonics.vehicle-peekaboo", title: "Vehicle Peekaboo", skill: "Understand spoken clues", interaction: "Listen to a vehicle clue, then open its garage", ageBand: "Ages 2–4", caregiverTip: "Ask where you have seen each vehicle in your neighborhood."),
        .init(id: "phonics.food-scroll", title: "Picnic Words", skill: "Listen and remember familiar words", interaction: "Browse food cards and pack a two-item spoken picnic list", ageBand: "Ages 2–4", caregiverTip: "Repeat the list as often as needed and name real foods together."),
        .init(id: "phonics.claw-game", title: "Word Claw", skill: "Follow a spoken direction", interaction: "Aim a claw at the named object, then lower it to collect", ageBand: "Ages 2–4", caregiverTip: "Take turns giving each other a one-step direction."),
        .init(id: "phonics.word-builder", title: "Word Builder", skill: "Explore letters in short words", interaction: "Build a picture word from left to right using a visible model", ageBand: "Optional · Ages 4+", caregiverTip: "This is supported letter play; independent reading is not expected."),
        .init(id: "phonics.beginning-sounds", title: "Beginning Sounds", skill: "Hear matching word beginnings", interaction: "Listen to a picture pair and find the matching first sound", ageBand: "Ages 3–4 with a grown-up", caregiverTip: "Say the whole words clearly, then emphasize their first sound."),
        .init(id: "phonics.abc-adventure", title: "ABC Adventure", skill: "Connect letter names with familiar words", interaction: "Open alphabet windows to discover picture words", ageBand: "Ages 3–4 with a grown-up", caregiverTip: "Sing the short letter sequence together; there is no timer."),
        .init(id: "phonics.rhyme-garden", title: "Rhyme Garden", skill: "Notice words with matching endings", interaction: "Listen to two word pairs and grow the rhyming flower", ageBand: "Optional · Ages 4+", caregiverTip: "Rhyming is playful listening. Say the pairs together and help freely."),
        .init(id: "phonics.letter-hide-seek", title: "Letter Hide & Seek", skill: "Find a letter among different shapes", interaction: "Find every copy of a target letter on a discovery board", ageBand: "Ages 3–4", caregiverTip: "Find the same letter in a book or on a package afterward."),
        .init(id: "phonics.syllable-hop", title: "Syllable Hop", skill: "Hear the beats in spoken words", interaction: "Clap or tap each spoken word part, then check the beat count", ageBand: "Optional · Ages 4+", caregiverTip: "Say rabbit as rab-bit while you clap together. Help whenever needed.")
    ]

    private static let symbols = ["a.square.fill", "pencil.tip", "basket.fill", "car.fill", "basket", "hand.point.down.fill", "textformat.abc", "ear.fill", "tram.fill", "camera.macro", "magnifyingglass", "hands.clap.fill"]
    private static let assets: [String?] = ["A", "Button-Letter-Draw", "Button-Sound-Basket", "carBlue", "Apple", "basketball", "cat", "Moon", "B", "cat", "M", "rabbit"]

    var body: some View {
        ActivityMenu(title: "ABCs & Word Play", subtitle: "12 ways to listen, talk, and discover letters together", accent: .orange) {
            ForEach(Array(Self.activities.enumerated()), id: \.element.id) { index, activity in
                LiteracyMenuLink(index: index, activity: activity, symbol: Self.symbols[index], asset: Self.assets[index])
            }
        }
    }
}

private struct LiteracyMenuLink: View {
    let index: Int
    let activity: LearningActivity
    let symbol: String
    let asset: String?
    @ObservedObject private var store = StoreManager.shared
    @State private var showPremiumGate = false
    // Preserve the six original premium destinations and entitlement behavior.
    private var locked: Bool { (1...6).contains(index) && !store.hasPremium }

    var body: some View {
        Group {
            if locked {
                Button { showPremiumGate = true } label: { card }
            } else {
                NavigationLink { destination.learningActivity(activity) } label: { card }
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPremiumGate) { PremiumParentGateView() }
    }

    private var card: some View {
        ActivityCard(title: activity.title, subtitle: "\(activity.ageBand)\(locked ? " · Premium" : "")", symbol: locked ? "lock.fill" : symbol, asset: asset, accent: .orange)
            .accessibilityLabel("\(activity.title). \(activity.ageBand). \(locked ? "Premium, grown-up required" : activity.skill)")
    }

    @ViewBuilder private var destination: some View {
        switch index {
        case 0: LetterTwinsGame()
        case 1: LetterDraw()
        case 2: LiteracySoundBasketsGame()
        case 3: LiteracyVehiclePeekabooGame()
        case 4: PicnicWordsGame()
        case 5: LiteracyWordClawGame()
        case 6: GuidedWordBuilderGame()
        case 7: ListeningBeginningsGame()
        case 8: AlphabetWindowsGame()
        case 9: RhymeGardenGame()
        case 10: LetterHideSeekGame()
        default: WordBeatHopGame()
        }
    }
}
