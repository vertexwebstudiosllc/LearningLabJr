import SwiftUI

enum LearningCatalog {
    struct Section: Identifiable {
        let id: String
        let title: String
        let activities: [LearningActivity]
    }

    static var sections: [Section] {
        [
            Section(id: "phonics", title: "ABCs & Phonics", activities: ABCsAndPhonicsMenu.activities),
            Section(id: "shapes", title: "Shapes & Colors", activities: ShapesAndColorsMenu.activities),
            Section(id: "counting", title: "123s & Counting", activities: CountingMenu.activities),
            Section(id: "nature", title: "Nature Explorers", activities: NatureExplorersMenu.activities),
            Section(id: "stories", title: "Story Time", activities: StoryTimeMenu.activities),
            Section(id: "feelings", title: "Big Feelings", activities: BigFeelingsMenu.activities)
        ]
    }

    static var activities: [LearningActivity] { sections.flatMap(\.activities) }
}

struct ParentLearningGuide: View {
    var body: some View {
        List {
            Section {
                Text("Start with your child's interests. Sit together, try one short activity, and follow their lead. Age labels are starting points, not milestones or a test.")
                Text("Early play is designed for ages 2–4 with a grown-up. Activities marked 4+ offer optional preschool challenges.")
            }
            ForEach(LearningCatalog.sections) { category in
                Section("\(category.title) · \(category.activities.count) activities") {
                    ForEach(category.activities) { activity in
                        DisclosureGroup {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(activity.interaction)
                                Label(activity.ageBand, systemImage: "person.2.fill")
                                Text("Try together: \(activity.caregiverTip)")
                            }
                            .font(.subheadline)
                            .padding(.vertical, 8)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(activity.title).font(.headline)
                                Text(activity.skill).font(.subheadline).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
        }
        .navigationTitle("What we're exploring")
        .navigationBarTitleDisplayMode(.inline)
    }
}
