import SwiftUI

struct NatureExplorersMenu: View {
    static let activities: [LearningActivity] = NatureActivity.allCases.map(\.metadata)

    var body: some View {
        ActivityMenu(title: "Nature Explorers", subtitle: "12 little adventures in our wonderful world", accent: .teal) {
            ForEach(NatureActivity.allCases) { activity in
                NavigationLink {
                    NatureGameDestination(activity: activity)
                        .learningActivity(activity.metadata)
                } label: {
                    ActivityCard(title: activity.metadata.title, subtitle: activity.metadata.skill,
                                 symbol: activity.symbol, accent: .teal)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

enum NatureActivity: String, CaseIterable, Identifiable {
    case habitats, tracks, moon, families, barn, garden, cleanup, weather, movement, dayNight, clues, nest
    var id: String { "nature.\(rawValue)" }

    var metadata: LearningActivity {
        let details: (String, String, String, String)
        switch self {
        case .habitats: details = ("Habitat Helpers", "Animal homes", "Match four animals to two homes, then explore a new group", "Animals can use more than one habitat. Look for birds in trees and insects among plants together.")
        case .tracks: details = ("Dinosaur Trail", "Observation & discovery", "Choose between two colored trails to find the named dinosaur", "Make pretend dinosaur footprints with your hands.")
        case .moon: details = ("Moon Mission", "Earth & space", "Pack a spacesuit, launch, land, and return home", "Look for the Moon together, even during the day.")
        case .families: details = ("Animal Families", "Animal vocabulary", "Connect adults with their babies", "A baby horse is a foal. A pony is a small horse, not a baby.")
        case .barn: details = ("Peekaboo Barnyard", "Listening & cause and effect", "Open the doors, meet an animal, and imitate its sound", "Take turns making your own animal sounds.")
        case .garden: details = ("Little Garden", "What plants need", "Plant a seed and give it soil, water, and sunshine", "Care for a real plant together. Growing takes time.")
        case .cleanup: details = ("Ocean Helpers", "Care for living things", "Pick up litter while leaving sea animals in their home", "An adult can help put litter in a bin on your next walk.")
        case .weather: details = ("Weather Window", "Notice the weather", "Change a weather window and explore rain, wind, and sunshine", "Look out of a real window and describe today’s weather.")
        case .movement: details = ("Move Like an Animal", "Animal movement", "Watch an animal and copy three different movements", "Make room nearby and move together; seated movements count too.")
        case .dayNight: details = ("Day & Night", "Observe light and dark", "Turn between day and night and find changing details", "The Sun is a star; the Moon can also be seen in daytime.")
        case .clues: details = ("Nature Detective", "Describe living things", "Open spoken clues and identify the animal", "Describe an animal without naming it and invite a guess.")
        case .nest: details = ("A Cozy Nest", "How birds build", "Choose twigs, weave a nest, and settle the eggs", "Watch a nest from far away and leave it undisturbed.")
        }
        return LearningActivity(id: id, title: details.0, skill: details.1, interaction: details.2,
                                ageBand: self == .clues ? "3–4 with a grown-up" : "2–4 with a grown-up", caregiverTip: details.3)
    }

    var symbol: String { id }
}
