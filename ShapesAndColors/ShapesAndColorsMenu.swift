import SwiftUI

struct ShapesAndColorsMenu: View {
    static let activities: [LearningActivity] = [
        .init(id: "shapes.post", title: "Shape Post", skill: "Recognize shape outlines", interaction: "Drag ten shapes into matching openings", ageBand: "2–4 with a grown-up", caregiverTip: "Trace the edges with your finger and name the shape."),
        .init(id: "shapes.laundry", title: "Color Laundry", skill: "Sort by one attribute", interaction: "Drag shirts to matching baskets across eleven colors", ageBand: "2–4 with a grown-up", caregiverTip: "Try sorting real socks together afterward."),
        .init(id: "shapes.mix", title: "Little Color Lab", skill: "Explore color mixing", interaction: "Explore nine levels of color mixtures and light and dark shades", ageBand: "2–4 with a grown-up", caregiverTip: "Try a little white to lighten paint, or a little black to darken it."),
        .init(id: "shapes.train", title: "Pattern Train", skill: "Notice repeating patterns", interaction: "Complete sixty distinct trains with gradually harder repeating groups", ageBand: "3–4 with a grown-up", caregiverTip: "Read each pattern aloud before choosing the next carriage."),
        .init(id: "shapes.town", title: "Build a Shape Town", skill: "Compose pictures from shapes", interaction: "Drag three to five shapes into outlines to build twenty pictures", ageBand: "2–4 with a grown-up", caregiverTip: "Talk about which pieces sit above or below the others."),
        .init(id: "shapes.nest", title: "Nesting Shapes", skill: "Compare small, medium, and large", interaction: "Layer shapes from largest to smallest", ageBand: "2–4 with a grown-up", caregiverTip: "Use your hands to show big and small."),
        .init(id: "shapes.trail", title: "Shape Trails", skill: "Explore lines and boundaries", interaction: "Trace or tap a path around three shapes", ageBand: "2–4 with a grown-up", caregiverTip: "A broad scribble is welcome. Guide a finger only if invited."),
        .init(id: "shapes.garden", title: "Mosaic Garden", skill: "Make creative color choices", interaction: "Choose paints and decorate six flower petals", ageBand: "2–4 with a grown-up", caregiverTip: "Describe the choices without asking for a right answer."),
        .init(id: "shapes.wings", title: "Mirror Wings", skill: "Notice matching sides", interaction: "Paint spots and reveal mirrored partners", ageBand: "3–4 with a grown-up", caregiverTip: "Point to the same spot on the other wing."),
        .init(id: "shapes.safari", title: "Shape Safari", skill: "Find shapes in everyday objects", interaction: "Find round, square, and triangular objects", ageBand: "2–4 with a grown-up", caregiverTip: "Find another example in the room after each round."),
        .init(id: "shapes.reveal", title: "Rainbow Windows", skill: "Connect color words and objects", interaction: "Open six windows to reveal a rainbow collection", ageBand: "2–4 with a grown-up", caregiverTip: "Ask which color your child wants to explore next."),
        .init(id: "shapes.roads", title: "Little Road Trip", skill: "Follow routes and position words", interaction: "Move a car along a winding path to its home", ageBand: "3–4 with a grown-up", caregiverTip: "Say across, up, and down as you guide the car together.")
    ]
    private let symbols = ["envelope.fill", "tshirt.fill", "paintpalette.fill", "tram.fill", "house.fill", "square.3.layers.3d", "pencil.tip", "camera.macro", "butterfly.fill", "magnifyingglass", "rainbow", "car.fill"]
    var body: some View {
        ActivityMenu(title: "Shapes & Colors", subtitle: "12 ways to sort, build, paint, and discover", accent: .blue) {
            ForEach(Array(Self.activities.enumerated()), id: \.element.id) { index, activity in
                NavigationLink {
                    SCActivityDestination(index: index).learningActivity(activity)
                } label: {
                    ActivityCard(title: activity.title, subtitle: activity.skill, symbol: symbols[index], accent: .blue)
                }.buttonStyle(.plain)
            }
        }
    }
}

private struct SCActivityDestination: View {
    let index: Int
    @State private var session = UUID()
    var body: some View { game.id(session) }
    private func replay() { session = UUID() }
    @ViewBuilder private var game: some View {
        switch index {
        case 0: ShapePostGame(onReplay: replay)
        case 1: ColorLaundryGame(onReplay: replay)
        case 2: ColorLabGame(onReplay: replay)
        case 3: PatternTrainGame(onReplay: replay)
        case 4: ShapeTownGame(onReplay: replay)
        case 5: NestingShapesGame(onReplay: replay)
        case 6: ShapeTrailsGame(onReplay: replay)
        case 7: MosaicGardenGame(onReplay: replay)
        case 8: MirrorWingsGame(onReplay: replay)
        case 9: ShapeSafariGame(onReplay: replay)
        case 10: RainbowWindowsGame(onReplay: replay)
        default: LittleRoadTripGame(onReplay: replay)
        }
    }
}
