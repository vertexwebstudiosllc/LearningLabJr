import Foundation

struct WeatherDiscovery: Identifiable {
    let id: String
    let title: String
    let narration: String
}
struct WindowCondition: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let pages: [WeatherDiscovery]
    static let all: [Self] = [
        .init(id: "sunshine", title: "Sunshine", symbol: "sun.max.fill", pages: [
            .init(id: "overview", title: "A sunny day", narration: "Sunshine! The Sun lights up our view. Swipe left or right to see what is outside."),
            .init(id: "flower", title: "A sunny flower", narration: "Look at the flower! Sunlight helps plants grow."),
            .init(id: "butterfly", title: "A butterfly", narration: "A butterfly is visiting a flower. Watch its wings flutter."),
            .init(id: "shadow", title: "A tree and its shadow", narration: "The tree blocks some sunlight. Look at its shadow on the ground."),
            .init(id: "bird", title: "A garden bird", narration: "A little bird is outside our sunny window. Can you pretend to flap your wings?"),
        ]),
        .init(id: "rain", title: "Rain", symbol: "cloud.rain.fill", pages: [
            .init(id: "overview", title: "A rainy day", narration: "Rain! Drops of water fall from clouds. Swipe left or right to explore our rainy view."),
            .init(id: "umbrella", title: "An umbrella", narration: "An umbrella helps keep the rain off. Look at the drops around it!"),
            .init(id: "puddle", title: "A puddle", narration: "Rainwater has gathered in a puddle. Drip, drop! See the little ripples."),
            .init(id: "boots", title: "Rain boots", narration: "Rain boots help keep feet dry when we step outside."),
            .init(id: "wetleaves", title: "Raindrops on leaves", narration: "Raindrops rest on the leaves. Plants need water to grow."),
        ]),
        .init(id: "wind", title: "Wind", symbol: "wind", pages: [
            .init(id: "overview", title: "A windy day", narration: "Wind! Moving air makes the branches sway. Swipe left or right to see things the wind can move."),
            .init(id: "kite", title: "A kite", narration: "The wind can lift a kite. A grown-up can help us fly one in an open space."),
            .init(id: "flag", title: "A fluttering flag", narration: "Look at the flag fluttering in the wind. Can you wave your hand like a flag?"),
            .init(id: "leaves", title: "Blowing leaves", narration: "The wind is carrying loose leaves. Watch them tumble through the air."),
            .init(id: "pinwheel", title: "A pinwheel", narration: "Moving air can turn a pinwheel. Round and round it goes!"),
        ]),
        .init(id: "night", title: "Nighttime", symbol: "moon.stars.fill", pages: [
            .init(id: "overview", title: "A nighttime view", narration: "Nighttime! Our view is dark and quiet. Swipe left or right to explore the night."),
            .init(id: "moon", title: "The Moon", narration: "There is the Moon! The Moon reflects light from the Sun."),
            .init(id: "stars", title: "Stars in the sky", narration: "Stars shine in the night sky. Can you wiggle your fingers like twinkling stars?"),
            .init(id: "cat", title: "A cat at night", narration: "A cat is watching the quiet street. Hello, little cat!"),
            .init(id: "windows", title: "Glowing windows", narration: "Lights glow inside the houses. The lights help people see when it is dark."),
        ]),
        .init(id: "snow", title: "Snow", symbol: "cloud.snow.fill", pages: [
            .init(id: "overview", title: "A snowy day", narration: "Snow! Little snowflakes fall on a cold day. Swipe left or right to explore our snowy view."),
            .init(id: "snowman", title: "A snowman", narration: "Someone has made a snowman. Look at the big snowballs stacked together!"),
            .init(id: "sled", title: "A sled", narration: "A sled can slide over snow. A grown-up can help us find a safe place to ride."),
            .init(id: "tracks", title: "Footprints in snow", narration: "Footprints show where someone walked through the snow. Can you follow them with your eyes?"),
            .init(id: "snowflake", title: "A snowflake", narration: "A snowflake is made of ice. Look closely at its branching shape."),
        ]),
        .init(id: "fall", title: "Fall", symbol: "leaf.fill", pages: [
            .init(id: "overview", title: "A fall day", narration: "Fall is a season. Some trees change color and lose their leaves. Swipe left or right to explore our fall view."),
            .init(id: "leaves", title: "Colorful leaves", narration: "Red, yellow, and orange leaves have fallen from the tree. Which color do you notice?"),
            .init(id: "acorn", title: "An acorn", narration: "An acorn is a seed from an oak tree. A new oak tree can grow from it."),
            .init(id: "pumpkin", title: "A pumpkin", narration: "A round orange pumpkin is outside our window. Pumpkins grow on vines."),
            .init(id: "squirrel", title: "A squirrel", narration: "A squirrel is gathering food. Some squirrels store food to eat later."),
        ]),
    ]
}

struct WeatherWindowPlay {
    private(set) var conditionIndex = 0
    private(set) var pageIndex = 0
    private(set) var visited: Set<String> = ["sunshine.overview"]
    var condition: WindowCondition { WindowCondition.all[conditionIndex] }
    var current: WeatherDiscovery { condition.pages[pageIndex] }
    var total: Int { WindowCondition.all.reduce(0) { $0 + $1.pages.count } }
    mutating func choose(_ id: String) {
        guard let index = WindowCondition.all.firstIndex(where: { $0.id == id }) else { return }
        conditionIndex = index; pageIndex = 0; recordVisit()
    }
    mutating func move(_ direction: Int) {
        guard direction == -1 || direction == 1 else { return }
        pageIndex = (pageIndex + direction + condition.pages.count) % condition.pages.count
        recordVisit()
    }
    private mutating func recordVisit() { visited.insert("\(condition.id).\(current.id)") }
}
