import SwiftUI

struct SpaceDiscoveryStep: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let instruction: String
    let finding: String
}

struct SpaceDiscovery {
    let title: String
    let steps: [SpaceDiscoveryStep]
    let question: String
    let answer: String
    let alternative: String
    let takeaway: String

    static let bank: [String: Self] = [
        "moon-craters": .init(title: "Be a crater detective", steps: [
            .init(id: "rock", title: "Space rock", symbol: "mountain.2.fill", instruction: "Tap the space rock to make a pretend impact.", finding: "A rock hitting the Moon can make a crater."),
            .init(id: "big", title: "Big crater", symbol: "circle.circle", instruction: "Find the big round crater.", finding: "Craters are dents in the surface."),
            .init(id: "little", title: "Little crater", symbol: "circle.circle", instruction: "Now find the little crater.", finding: "Craters come in different sizes.")], question: "Which neighbor has the craters we explored?", answer: "Moon", alternative: "Sun", takeaway: "Space rocks make craters on the Moon."),
        "moon-shine": .init(title: "Follow the light", steps: [
            .init(id: "Sun", title: "Sun", symbol: "sun.max.fill", instruction: "Start at the Sun, which makes light.", finding: "Sunlight travels to the Moon."),
            .init(id: "Moon", title: "Moon", symbol: "moon.fill", instruction: "Tap the Moon to bounce the light onward.", finding: "The Moon reflects sunlight."),
            .init(id: "Earth", title: "Earth", symbol: "globe.americas.fill", instruction: "Tap Earth, where we see the moonlight.", finding: "Moonlight reaches us on Earth.")], question: "Which one makes its own light?", answer: "Sun", alternative: "Moon", takeaway: "The Moon shines by reflecting sunlight."),
        "earth-blue": .init(title: "Explore our home", steps: [
            .init(id: "ocean", title: "Ocean", symbol: "water.waves", instruction: "Find the blue ocean water.", finding: "Oceans cover much of Earth."),
            .init(id: "land", title: "Land", symbol: "tree.fill", instruction: "Find land where a tree can grow.", finding: "People and many animals live on land."),
            .init(id: "cloud", title: "Clouds", symbol: "cloud.fill", instruction: "Find the clouds above our planet.", finding: "Earth has air around it.")], question: "Which planet is our home?", answer: "Earth", alternative: "Mars", takeaway: "Our home has oceans, land, and air."),
        "earth-day": .init(title: "Turn from day to night", steps: [
            .init(id: "Sun", title: "Sunlight", symbol: "sun.max.fill", instruction: "Tap the Sun to light one side of Earth.", finding: "The side facing the Sun has daytime."),
            .init(id: "day", title: "Day side", symbol: "sun.max.fill", instruction: "Find the bright day side.", finding: "Our place on Earth turns toward the sunlight."),
            .init(id: "night", title: "Night side", symbol: "moon.stars.fill", instruction: "Turn our place away from the Sun. Tap the dark side.", finding: "The side facing away has nighttime.")], question: "Which planet spins as we have day and night?", answer: "Earth", alternative: "Moon", takeaway: "Earth spins. Our place turns into daylight and then night."),
        "mars-rover": .init(title: "Help a robot scientist", steps: [
            .init(id: "wheel", title: "Wheels", symbol: "gearshape.2.fill", instruction: "Tap the wheels to move our pretend rover.", finding: "A rover is a robot that drives and explores."),
            .init(id: "rock", title: "Rock", symbol: "mountain.2.fill", instruction: "Stop and inspect a Mars rock.", finding: "Mars has rocky, dusty ground."),
            .init(id: "camera", title: "Camera", symbol: "camera.fill", instruction: "Take a pretend picture to share with Earth.", finding: "Robots send information to help scientists learn.")], question: "Where did our rover explore?", answer: "Mars", alternative: "Saturn", takeaway: "Rovers help scientists study rocky Mars."),
        "mars-moons": .init(title: "Count Mars's moons", steps: [
            .init(id: "Mars", title: "Mars", symbol: "circle.fill", instruction: "Find Mars at the center of the picture.", finding: "Two little moons travel around Mars."),
            .init(id: "Phobos", title: "Phobos", symbol: "moon.fill", instruction: "Tap Phobos. That is one moon.", finding: "Phobos is one of Mars's moons."),
            .init(id: "Deimos", title: "Deimos", symbol: "moon.fill", instruction: "Tap Deimos. Now we have counted two.", finding: "One, two! Mars has two moons.")], question: "Which planet has two moons?", answer: "Mars", alternative: "Earth", takeaway: "Phobos and Deimos travel around Mars."),
        "jupiter-stripes": .init(title: "Investigate cloud bands", steps: [
            .init(id: "light", title: "Light band", symbol: "line.3.horizontal", instruction: "Find a light stripe on Jupiter.", finding: "The stripe is a band of clouds."),
            .init(id: "dark", title: "Dark band", symbol: "line.3.horizontal", instruction: "Now find a darker cloud band.", finding: "Cloud bands make Jupiter look striped."),
            .init(id: "ship", title: "Spaceship", symbol: "paperplane.fill", instruction: "Tap our spaceship to explore from above.", finding: "Jupiter has no solid ground like Earth's.")], question: "Which planet has these giant cloud bands?", answer: "Jupiter", alternative: "Earth", takeaway: "Jupiter is a giant planet with bands of clouds."),
        "jupiter-storm": .init(title: "Observe a giant storm", steps: [
            .init(id: "spot", title: "Red Spot", symbol: "hurricane", instruction: "Find the reddish oval storm.", finding: "The Great Red Spot is a giant storm."),
            .init(id: "wind", title: "Wind", symbol: "wind", instruction: "Tap the wind to turn our storm picture.", finding: "Winds move Jupiter's clouds."),
            .init(id: "ship", title: "Spaceship", symbol: "paperplane.fill", instruction: "Return to our pretend spaceship to watch.", finding: "We observe from above the clouds.")], question: "Where is the Great Red Spot?", answer: "Jupiter", alternative: "Mars", takeaway: "Jupiter's Great Red Spot is a swirling storm."),
        "saturn-rings": .init(title: "Look closely at the rings", steps: [
            .init(id: "ice", title: "Ice pieces", symbol: "snowflake", instruction: "Find ice pieces in our ring close-up.", finding: "Many pieces of ice are in Saturn's rings."),
            .init(id: "rock", title: "Rock pieces", symbol: "mountain.2.fill", instruction: "Find the rocky pieces, too.", finding: "The rings contain ice and rock."),
            .init(id: "ring", title: "Ring", symbol: "circle", instruction: "Tap the ring to see the pieces around Saturn.", finding: "A ring is many pieces, not one solid road.")], question: "Which planet did we visit to study these rings?", answer: "Saturn", alternative: "Earth", takeaway: "Saturn's rings contain many separate pieces of ice and rock."),
        "saturn-postcard": .init(title: "Make a science postcard", steps: [
            .init(id: "Saturn", title: "Saturn", symbol: "circle.fill", instruction: "Add the planet to our postcard.", finding: "Saturn is a giant planet."),
            .init(id: "ring", title: "Rings", symbol: "circle", instruction: "Add the rings around Saturn.", finding: "The rings circle the planet."),
            .init(id: "ice", title: "Ice and rock", symbol: "snowflake", instruction: "Add a close-up of the tiny ring pieces.", finding: "The rings are made of many separate pieces.")], question: "Which giant planet belongs on our ring postcard?", answer: "Saturn", alternative: "Mars", takeaway: "A science picture can show a planet and a close-up of its rings."),
        "sun-star": .init(title: "Explore what sunlight does", steps: [
            .init(id: "Sun", title: "Sun", symbol: "sun.max.fill", instruction: "Tap our picture of the Sun to start the light.", finding: "The Sun is a star that makes its own light."),
            .init(id: "Earth", title: "Earth", symbol: "globe.americas.fill", instruction: "Follow the light to Earth.", finding: "Sunlight reaches our home planet."),
            .init(id: "plant", title: "Plant", symbol: "leaf.fill", instruction: "Find a plant that uses sunlight to grow.", finding: "Sunlight helps plants grow.")], question: "Which picture shows our nearest star?", answer: "Sun", alternative: "Earth", takeaway: "The Sun gives Earth light and warmth."),
        "sun-light": .init(title: "Help our pretend plant", steps: [
            .init(id: "water", title: "Water", symbol: "drop.fill", instruction: "Give our pretend seed some water.", finding: "Plants need water."),
            .init(id: "air", title: "Air", symbol: "wind", instruction: "Add air around our little plant.", finding: "Plants need air, too."),
            .init(id: "Sun", title: "Sunlight", symbol: "sun.max.fill", instruction: "Add sunlight and watch the leaves appear.", finding: "Water, air, and light help plants grow.")], question: "Where does our plant's sunlight come from?", answer: "Sun", alternative: "Moon", takeaway: "Plants use water, air, and light to grow.")
    ]
}

struct SpaceDiscoveryProgress {
    private(set) var visited: Set<String> = []
    private(set) var answered = false
    func nextStep(in lesson: SpaceDiscovery) -> SpaceDiscoveryStep? { lesson.steps.first { !visited.contains($0.id) } }
    mutating func explore(_ id: String, in lesson: SpaceDiscovery) -> Bool {
        guard nextStep(in: lesson)?.id == id else { return false }
        visited.insert(id); return true
    }
    mutating func answer(_ value: String, in lesson: SpaceDiscovery) -> Bool {
        guard nextStep(in: lesson) == nil, value == lesson.answer else { return false }
        answered = true; return true
    }
}
