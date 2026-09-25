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
        case .moon: details = ("Moon Mission", "Earth & space", "Choose a narrated space story and discover planets, our Moon and our star", "These are pretend trips with real space facts. Ask your child to share one discovery.")
        case .families: details = ("Animal Families", "Animal vocabulary", "Match babies, grown-ups and animal sounds across eighteen rounds", "A baby horse is a foal. A pony is a small horse, not a baby.")
        case .barn: details = ("Peekaboo Barnyard", "Listening & cause and effect", "Slide open the original barn doors and discover nineteen farm surprises", "Make farm sounds together, name baby animals, and pretend to help the farmer.")
        case .garden: details = ("Little Garden", "What plants need", "Choose a flower and grow it in a pot or garden", "Care for a plant with a grown-up. Real flowers need many days or weeks to grow; our game speeds up time.")
        case .cleanup: details = ("Ocean Helpers", "Care for living things", "Choose an ocean friend and solve ten cleanup puzzles", "Spot litter on a walk and ask a grown-up to handle it. Leave real animals undisturbed.")
        case .weather: details = ("Weather Window", "Notice the weather", "Swipe through sunshine, rain, wind, nighttime, snow, and fall", "Look out of a real window together. Notice the weather, time of day, and seasonal changes.")
        case .movement: details = ("Move Like an Animal", "Animal movement", "Move together with sixteen shuffled animal friends", "Invite a grown-up to play and make a little space together. Every animal has a seated movement to try.")
        case .dayNight: details = ("Day & Night", "Practice everyday routines", "Explore eighteen daytime and bedtime activities", "Talk about your own family routines. Brushing teeth, reading, and tidying can happen at more than one time of day.")
        case .clues: details = ("Nature Detective", "Describe living things", "Solve twenty-four animal and insect mysteries with three spoken clues", "Play detective together. Listen for body parts, sounds, and movements; insects are animals, too.")
        case .nest: details = ("A Cozy Nest", "How birds build", "Choose twigs, weave a nest, and settle the eggs", "Watch a nest from far away and leave it undisturbed.")
        }
        return LearningActivity(id: id, title: details.0, skill: details.1, interaction: details.2,
                                ageBand: self == .clues ? "3–4 with a grown-up" : "2–4 with a grown-up", caregiverTip: details.3)
    }

    var symbol: String { id }
}
