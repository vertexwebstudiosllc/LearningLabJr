import SwiftUI

struct BigFeelingsMenu: View {
    static let activities: [LearningActivity] = [
        .init(id: "feelings.faces", title: "Funny Face Studio", skill: "Explore facial expressions", interaction: "Copy six expressive faces and find their feeling words", ageBand: "2–4 with a grown-up", caregiverTip: "Copy a face together. Faces give clues, but we ask how someone feels."),
        .init(id: "feelings.breathe", title: "Flower Breaths", skill: "Practice a calming routine", interaction: "Explore eight gentle activities at your own pace", ageBand: "2–4 with a grown-up", caregiverTip: "Try together without rushing. Breathe comfortably; no breath holding. Watching counts, and every feeling is welcome."),
        .init(id: "feelings.teddy", title: "Teddy's Helping Hands", skill: "Offer care and respect choices", interaction: "Build and dress Teddy for twelve helping adventures", ageBand: "2–4 with a grown-up", caregiverTip: "Ask what help is wanted. These are pretend adventures; ask a trusted grown-up for help with real problems."),
        .init(id: "feelings.turns", title: "Roll It Together", skill: "Practice taking turns", interaction: "Choose a sport and a friend, then share six back-and-forth turns", ageBand: "2–4 with a grown-up", caregiverTip: "Ask someone to play, wait for their turn, and share kind words. Try gentle passes with a soft ball together; seated play works too."),
        .init(id: "feelings.pause", title: "Wiggle, Slow, Stop", skill: "Explore movement and pauses", interaction: "Move to music and follow automatic Wiggle, Slow, and Stop cues", ageBand: "2–4 with a grown-up", caregiverTip: "Play with your grown-up in a clear space. Listen for Wiggle, Slow, and Stop. Seated movements count, and you can pause whenever you like."),
        .init(id: "feelings.weather", title: "My Feeling Weather", skill: "Communicate feelings and needs", interaction: "Choose a feeling, its size, and a support", ageBand: "2–4 with a grown-up", caregiverTip: "Accept every answer, including not sure. Feelings do not need to change."),
        .init(id: "feelings.kindness", title: "Kindness Garden", skill: "Practice caring actions", interaction: "Choose, act out, and plant three kindness flowers", ageBand: "2–4 with a grown-up", caregiverTip: "Name the caring action you notice without requiring affection."),
        .init(id: "feelings.tools", title: "My Cozy Toolbox", skill: "Choose a regulation strategy", interaction: "Try three self-paced calming tools together", ageBand: "2–4 with a grown-up", caregiverTip: "These are play ideas, not treatment. Stop a tool if it is uncomfortable."),
        .init(id: "feelings.body", title: "Body Clue Buddies", skill: "Notice body sensations", interaction: "Explore hands, heartbeat, tummy, and feet", ageBand: "2–4 with a grown-up", caregiverTip: "Let your child describe their own body. A body clue can mean many things."),
        .init(id: "feelings.bridge", title: "Friendship Bridge", skill: "Use words and solve social problems", interaction: "Build a bridge through three pretend conversations", ageBand: "3–4 with a grown-up", caregiverTip: "Model asking, listening, and accepting no. There can be many kind solutions."),
        .init(id: "feelings.routine", title: "Cozy Evening Path", skill: "Anticipate familiar routines", interaction: "Put four bedtime pictures in a gentle sequence", ageBand: "2–4 with a grown-up", caregiverTip: "Explain that families have different routines. Talk about your own."),
        .init(id: "feelings.goodbye", title: "See You Soon", skill: "Rehearse a reassuring goodbye", interaction: "Choose a goodbye, a comfort plan, and a pretend reunion", ageBand: "2–4 with a grown-up", caregiverTip: "Use a familiar caregiver and a predictable return. Never disappear without saying goodbye.")
    ]
    private let symbols = ["face.smiling.fill", "camera.macro", "heart.fill", "basketball.fill", "figure.cooldown", "cloud.sun.fill", "leaf.fill", "shippingbox.fill", "hand.raised.fill", "person.2.fill", "moon.stars.fill", "hand.wave.fill"]
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
        case 7: CozyToolboxGame(onReplay: replay)
        case 8: BodyClueBuddiesGame(onReplay: replay)
        case 9: FriendshipBridgeGame(onReplay: replay)
        case 10: CozyEveningPathGame(onReplay: replay)
        default: SeeYouSoonGame(onReplay: replay)
        }
    }
}
