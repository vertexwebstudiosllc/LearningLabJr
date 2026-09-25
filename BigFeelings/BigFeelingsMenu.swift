import SwiftUI

struct BigFeelingsMenu: View {
    static let activities: [LearningActivity] = [
        .init(id: "feelings.faces", title: "Funny Face Studio", skill: "Explore facial expressions", interaction: "Copy six expressive faces and find their feeling words", ageBand: "2–4 with a grown-up", caregiverTip: "Copy a face together. Faces give clues, but we ask how someone feels."),
        .init(id: "feelings.breathe", title: "Flower Breaths", skill: "Practice a calming routine", interaction: "Explore eight gentle activities at your own pace", ageBand: "2–4 with a grown-up", caregiverTip: "Try together without rushing. Breathe comfortably; no breath holding. Watching counts, and every feeling is welcome."),
        .init(id: "feelings.teddy", title: "Teddy's Helping Hands", skill: "Offer care and respect choices", interaction: "Build and dress Teddy for twelve helping adventures", ageBand: "2–4 with a grown-up", caregiverTip: "Ask what help is wanted. These are pretend adventures; ask a trusted grown-up for help with real problems."),
        .init(id: "feelings.turns", title: "Roll It Together", skill: "Practice taking turns", interaction: "Choose a sport and a friend, then share six back-and-forth turns", ageBand: "2–4 with a grown-up", caregiverTip: "Ask someone to play, wait for their turn, and share kind words. Try gentle passes with a soft ball together; seated play works too."),
        .init(id: "feelings.pause", title: "Wiggle, Slow, Stop", skill: "Explore movement and pauses", interaction: "Move to music and follow automatic Wiggle, Slow, and Stop cues", ageBand: "2–4 with a grown-up", caregiverTip: "Play with your grown-up in a clear space. Listen for Wiggle, Slow, and Stop. Seated movements count, and you can pause whenever you like."),
        .init(id: "feelings.weather", title: "My Feeling Weather", skill: "Communicate feelings and needs", interaction: "Choose a feeling, its size, and a support that fits how you feel", ageBand: "2–4 with a grown-up", caregiverTip: "Accept every answer, including not sure. Feelings do not need to change."),
        .init(id: "feelings.kindness", title: "Kindness Garden", skill: "Practice caring actions", interaction: "Explore mixed-up caring choices and watch a pretend garden grow or fade", ageBand: "2–4 with a grown-up", caregiverTip: "Talk about what each choice does. We can try again. Choices can help or hurt; children are never labeled good or bad. Respect no and personal space."),
        .init(id: "feelings.tools", title: "My Solution Toolbox", skill: "Practice solving everyday problems", interaction: "Open a toolbox and choose helpful items for eighteen everyday problems", ageBand: "2–4 with a grown-up", caregiverTip: "Explore solutions together. Ask a trusted grown-up for real repairs. Many problems have more than one solution."),
        .init(id: "feelings.body", title: "Body Clue Buddies", skill: "Identify familiar body parts", interaction: "Solve eighteen clues by tapping a new picture buddy each round", ageBand: "2–4 with a grown-up", caregiverTip: "Tap the picture together. Bodies look and work in different ways. Children can point, listen, or ask for a hint."),
        .init(id: "feelings.bridge", title: "Friendship Bridge", skill: "Make friends and share playful turns", interaction: "Choose a buddy and build a bridge through twelve interactive playdates", ageBand: "3–4 with a grown-up", caregiverTip: "Practice friendly words together. Ask before joining, respect no, and give friends space. Watching, pointing, and seated play count."),
        .init(id: "feelings.routine", title: "Cozy Evening Path", skill: "Practice everyday routines", interaction: "Explore eight interactive paths from bedtime to outings", ageBand: "2–4 with a grown-up", caregiverTip: "Practice Teddy's pretend plans together. Your family's order may differ. Offer help and pauses; bathroom play is never a test of readiness."),
        .init(id: "feelings.goodbye", title: "See You Soon", skill: "Practice friendly goodbyes", interaction: "Move a buddy through eight goodbye stories and choose words that fit", ageBand: "2–4 with a grown-up", caregiverTip: "Stay together for pretend play. Name the trusted adult who stays at drop-off and explain the real return plan. Feelings and pauses are welcome; hugs are a choice.")
    ]
    private let symbols = ["face.smiling.fill", "camera.macro", "heart.fill", "basketball.fill", "figure.cooldown", "cloud.sun.fill", "leaf.fill", "toolbox.fill", "hand.raised.fill", "person.2.fill", "moon.stars.fill", "hand.wave.fill"]
    var body: some View {
        ActivityMenu(title: "Big Feelings", subtitle: "12 playful ways to connect and care", accent: .pink) {
            ForEach(Array(Self.activities.enumerated()), id: \.element.id) { index, activity in
                NavigationLink {
                    BFActivityDestination(index: index).learningActivity(activity)
                } label: {
                    ActivityCard(title: activity.title, subtitle: activity.skill, symbol: symbols[index], accent: .pink)
                }.buttonStyle(.plain)
            }
        }
    }
}

private struct BFActivityDestination: View {
    let index: Int
    @State private var session = UUID()
    var body: some View { game.id(session) }
    private func replay() { session = UUID() }
    @ViewBuilder private var game: some View {
        switch index {
        case 0: FunnyFaceStudioGame(onReplay: replay)
        case 1: FlowerBreathsGame(onReplay: replay)
        case 2: TeddyHelpingHandsGame(onReplay: replay)
        case 3: RollItTogetherGame(onReplay: replay)
        case 4: WiggleSlowStopGame(onReplay: replay)
        case 5: FeelingWeatherGame(onReplay: replay)
        case 6: KindnessGardenGame(onReplay: replay)
        case 7: SolutionToolboxGame(onReplay: replay)
        case 8: BodyClueBuddiesGame(onReplay: replay)
        case 9: FriendshipBridgeGame(onReplay: replay)
        case 10: CozyEveningPathGame(onReplay: replay)
        default: SeeYouSoonGame(onReplay: replay)
        }
    }
}
