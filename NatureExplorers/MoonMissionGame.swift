import SwiftUI

enum SpaceMissionCategory: String, CaseIterable, Codable {
    case moon, earth, mars, jupiter, saturn, sun
    var title: String { rawValue.capitalized }
}

struct SpaceStoryPage {
    let art: String
    let text: String
    let action: String
}
struct SpaceStory: Identifiable {
    let id: String
    let category: SpaceMissionCategory
    let title: String
    let pages: [SpaceStoryPage]
}

/// Persist the unused categories as well as the last offer, even if a child exits
/// without choosing. All six categories appear before a new shuffled cycle starts.
struct SpaceMissionDeck: Codable {
    var remaining: [SpaceMissionCategory] = []
    var previousOffer: [SpaceMissionCategory] = []
    var lastStory: [String: String] = [:]

    mutating func offer() -> [SpaceStory] {
        if remaining.count < 2 {
            let shuffled = SpaceMissionCategory.allCases.shuffled()
            let first = Array(shuffled.filter { !previousOffer.contains($0) }.prefix(2))
            remaining = first + shuffled.filter { !first.contains($0) }
        }
        let categories = Array(remaining.prefix(2))
        remaining.removeFirst(2)
        previousOffer = categories
        return categories.map { category in
            let options = SpaceStory.bank.filter { $0.category == category && $0.id != lastStory[category.rawValue] }
            let story = options.randomElement()!
            lastStory[category.rawValue] = story.id
            return story
        }.shuffled()
    }
}

struct SpaceMissionSession {
    let choices: [SpaceStory]
    private(set) var selected: SpaceStory?
    private(set) var pageIndex = 0
    var page: SpaceStoryPage? { selected?.pages[pageIndex] }
    var finished: Bool { selected.map { pageIndex == $0.pages.count - 1 } ?? false }
    static let choicePrompt = "Choose a space adventure. Tap a picture, and we'll explore together!"
    var prompt: String { page?.text ?? Self.choicePrompt }

    mutating func select(_ id: String) {
        guard selected == nil, let story = choices.first(where: { $0.id == id }) else { return }
        selected = story; pageIndex = 0
    }
    mutating func next() {
        guard selected != nil, !finished else { return }
        pageIndex += 1
    }
    mutating func back() { if pageIndex > 0 { pageIndex -= 1 } }
}

struct MoonMissionGame: View {
    @AppStorage("nature.spaceMission.deck") private var savedDeck = Data()
    @State private var play = SpaceMissionSession(choices: [])
    @State private var started = false
    @State private var discovery = SpaceDiscoveryProgress()
    @StateObject private var narrator = GameNarrator()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ToddlerGameScaffold(title: "Moon Mission", prompt: play.prompt, accent: .indigo) {
            if let story = play.selected, let page = play.page {
                VStack(spacing: 5) {
                    Text(story.title).font(.system(.headline, design: .rounded))
                    Text("Page \(play.pageIndex + 1) of \(story.pages.count)")
                        .font(.subheadline).foregroundStyle(.secondary)
                        .accessibilityIdentifier("space.page")
                }
                if let lesson = SpaceDiscovery.bank[story.id], play.pageIndex == 3 || play.pageIndex == 4 {
                    SpaceDiscoveryView(storyID: story.id, lesson: lesson, progress: $discovery, review: play.pageIndex == 4) {
                        narrator.speak(story.pages[3].text)
                    }.id("discovery-\(story.id)-\(play.pageIndex)")
                } else {
                    Button { advance() } label: { SpaceMissionScene(art: page.art) }
                        .buttonStyle(.plain)
                        .accessibilityLabel(play.finished ? "Mission complete" : page.action)
                        .accessibilityIdentifier("space.scene")
                        .disabled(play.finished)
                }
                if play.finished {
                    if let lesson = SpaceDiscovery.bank[story.id] {
                        Text("Our discovery: " + lesson.takeaway).font(.headline).multilineTextAlignment(.center)
                    }
                    Label("Mission complete!", systemImage: "star.circle.fill")
                        .font(.system(.title2, design: .rounded, weight: .bold)).foregroundStyle(.indigo)
                    ToddlerActionButton(title: "Choose another mission", systemImage: "sparkles", color: .indigo, action: newChoices)
                        .accessibilityIdentifier("space.chooseAgain")
                    Button("All done") { dismiss() }.frame(minHeight: 48)
                } else {
                    ToddlerActionButton(title: page.action, systemImage: "arrow.right", color: .indigo) { advance() }
                        .accessibilityIdentifier("space.next").disabled(!canContinue)
                }
                HStack {
                    if play.pageIndex > 0 {
                        Button { play.back() } label: { Label("Previous page", systemImage: "arrow.left") }
                            .frame(minHeight: 48).accessibilityIdentifier("space.previous")
                    }
                    Spacer()
                    Button("Choose a new mission", action: newChoices).frame(minHeight: 48)
                        .accessibilityIdentifier("space.changeMission")
                }.font(.system(.subheadline, design: .rounded))
            } else {
                ForEach(play.choices) { story in
                    Button { play.select(story.id) } label: {
                        HStack(spacing: 16) {
                            Image("SpaceClean/\(story.category.title)").resizable().scaledToFit()
                                .frame(width: 96, height: 96).accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(story.category.title).font(.system(.title3, design: .rounded, weight: .bold))
                                Text(story.title).font(.system(.headline, design: .rounded))
                                Text("Start this adventure").font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "play.circle.fill").font(.title2)
                        }
                        .padding(16).frame(maxWidth: .infinity, minHeight: 140)
                        .background(.indigo.opacity(0.09), in: RoundedRectangle(cornerRadius: 26))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(story.category.title): \(story.title)")
                    .accessibilityIdentifier("space.mission.\(story.id)")
                }
                Text("Pretend journeys, real discoveries")
                    .font(.system(.subheadline, design: .rounded)).foregroundStyle(.secondary)
            }
        }
        .id("\(play.selected?.id ?? "choices"):\(play.pageIndex)")
        .onAppear { if !started { newChoices(); started = true } }
    }
    private var canContinue: Bool {
        guard let story = play.selected, let lesson = SpaceDiscovery.bank[story.id] else { return true }
        if play.pageIndex == 3 { return discovery.nextStep(in: lesson) == nil }
        if play.pageIndex == 4 { return discovery.answered }
        return true
    }
    private func advance() {
        guard canContinue, !play.finished else { return }
        narrator.stop(); play.next()
    }
    private func newChoices() {
        narrator.stop()
        discovery = SpaceDiscoveryProgress()

        var deck = (try? JSONDecoder().decode(SpaceMissionDeck.self, from: savedDeck)) ?? SpaceMissionDeck()
        play = SpaceMissionSession(choices: deck.offer())
        savedDeck = (try? JSONEncoder().encode(deck)) ?? Data()
    }
}

private struct SpaceMissionScene: View {
    let art: String
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(LinearGradient(colors: [.indigo.opacity(0.9), Color(red: 0.07, green: 0.12, blue: 0.28)], startPoint: .topLeading, endPoint: .bottomTrailing))
                ForEach(0..<18, id: \.self) { i in
                    Image(systemName: i.isMultiple(of: 3) ? "sparkle" : "circle.fill")
                        .font(.system(size: i.isMultiple(of: 3) ? 12 : 3))
                        .foregroundStyle(.white.opacity(0.65))
                        .position(x: geometry.size.width * CGFloat((i * 37 + 11) % 96 + 2) / 100,
                                  y: geometry.size.height * CGFloat((i * 29 + 7) % 92 + 4) / 100)
                }
                Image("SpaceClean/\(art)").resizable().scaledToFit().padding(16)
                if art != "Rocket" {
                    Image("SpaceClean/Rocket").resizable().scaledToFit().frame(width: 64, height: 80)
                        .rotationEffect(.degrees(-18)).offset(x: geometry.size.width * 0.34, y: geometry.size.height * 0.28)
                }
            }
        }.frame(height: 230).accessibilityHidden(true)
    }
}
