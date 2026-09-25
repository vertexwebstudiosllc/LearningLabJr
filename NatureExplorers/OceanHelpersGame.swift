import SwiftUI
import Combine

@MainActor
final class OceanCleanupSession: ObservableObject {
    static let choicesKey = "nature.ocean.lastOfferedBuddies"
    @Published var play: OceanCleanupPlay
    private let defaults: UserDefaults
    nonisolated deinit {}
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        play = OceanCleanupPlay(previousChoices: defaults.stringArray(forKey: Self.choicesKey) ?? [])
        defaults.set(play.choices.map(\.id), forKey: Self.choicesKey)
    }
    func replay() {
        play = OceanCleanupPlay(previousChoices: play.choices.map(\.id))
        defaults.set(play.choices.map(\.id), forKey: Self.choicesKey)
    }
}

struct OceanHelpersGame: View {
    @StateObject private var session = OceanCleanupSession()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var play: OceanCleanupPlay { session.play }

    var body: some View {
        ToddlerGameScaffold(title: "Ocean Helpers", prompt: play.prompt, accent: .cyan) {
            if let hero = play.hero {
                HStack(spacing: 16) {
                    OceanBuddyPortrait(buddy: hero).frame(width: 86, height: 86)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Helping the \(hero.name)").font(.title3.bold())
                        Text(play.complete ? "Ten sparkling places!" : "Your cleanup buddy").font(.subheadline)
                    }
                    Spacer(minLength: 0)
                }.accessibilityElement(children: .combine).accessibilityIdentifier("ocean.hero.\(hero.id)")
                if !play.started {
                    Label("10 ocean puzzles", systemImage: "water.waves").font(.headline)
                    ToddlerActionButton(title: "Let's help!", systemImage: "play.fill", color: .cyan) { session.play.begin() }
                        .accessibilityIdentifier("ocean.begin")
                } else if play.complete {
                    VStack(spacing: 18) {
                        Image(systemName: "sparkles").font(.system(size: 60)).foregroundStyle(.orange)
                        Text("Ocean helper!").font(.largeTitle.bold())
                        Text("\(play.totalCollected) pieces of trash collected").font(.headline)
                    }.padding(24).frame(maxWidth: .infinity).background(.cyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 24))
                        .accessibilityIdentifier("ocean.complete")
                    ToddlerActionButton(title: "Help another friend", systemImage: "arrow.clockwise", color: .cyan) { session.replay() }
                        .accessibilityIdentifier("ocean.replay")
                    Button("All done") { dismiss() }.font(.headline).frame(minHeight: 48)
                } else if let round = play.current {
                    HStack {
                        Text("Round \(play.index + 1) of 10").accessibilityIdentifier("ocean.round")
                        Spacer()
                        Text(round.name)
                    }.font(.headline)
                    if let target = round.target, play.targetRemaining {
                        HStack(spacing: 14) {
                            OceanTrashArt(litter: target).frame(width: 56, height: 56)
                            Text("Find these first").font(.headline)
                        }.padding(10).frame(maxWidth: .infinity)
                            .background(.yellow.opacity(0.22), in: RoundedRectangle(cornerRadius: 18))
                            .accessibilityElement(children: .ignore).accessibilityLabel(target.name)
                            .accessibilityIdentifier("ocean.target.\(target.id)")
                    }
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 12) {
                        ForEach(round.pieces) { piece in
                            if play.collected.contains(piece.id) {
                                Image(systemName: "water.waves").font(.largeTitle).foregroundStyle(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity, minHeight: 96)
                                    .accessibilityLabel("Clean water").accessibilityIdentifier("ocean.cleared.\(piece.id)")
                            } else {
                                Button { _ = session.play.pick(piece.id) } label: {
                                    Group {
                                        if let litter = piece.litter { OceanTrashArt(litter: litter).padding(14) }
                                        else if let animal = piece.animal { OceanBuddyPortrait(buddy: animal).padding(5) }
                                    }.frame(maxWidth: .infinity).frame(height: 96)
                                        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 18))
                                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(play.selected == piece.id ? Color.orange : .clear, lineWidth: 5))
                                        .overlay(alignment: .topTrailing) {
                                            if play.selected == piece.id { Image(systemName: "checkmark.circle.fill").foregroundStyle(.white, .orange).font(.title3).padding(4) }
                                        }
                                }.buttonStyle(.plain).accessibilityLabel(piece.name)
                                    .accessibilityValue(play.selected == piece.id ? "Selected; find its match" : "")
                                    .accessibilityIdentifier("ocean.piece.\(piece.litter == nil ? "animal" : "trash").\(piece.litter?.id ?? piece.animal!.id).\(piece.id)")
                            }
                        }
                    }.padding(14)
                        .background {
                            ZStack(alignment: .bottom) {
                                LinearGradient(colors: [.cyan.opacity(0.65), .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                                HStack {
                                    Image(systemName: "leaf.fill").rotationEffect(.degrees(-30))
                                    Spacer()
                                    Image(systemName: "leaf.fill").rotationEffect(.degrees(30))
                                }.font(.system(size: 52)).foregroundStyle(.green.opacity(0.4)).padding(8)
                            }.clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: play.collected)
                    Label("\(play.collected.count) of \(round.trashIDs.count) in the bin", systemImage: "trash.fill")
                        .font(.headline).accessibilityIdentifier("ocean.count")
                    if play.solved {
                        ToddlerActionButton(title: play.index == 9 ? "Celebrate!" : "Next ocean puzzle", systemImage: play.index == 9 ? "star.fill" : "arrow.right", color: .cyan) { session.play.next() }
                            .accessibilityIdentifier("ocean.next")
                    }
                }
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(play.choices) { buddy in
                        Button { session.play.choose(buddy) } label: {
                            VStack(spacing: 8) {
                                OceanBuddyPortrait(buddy: buddy).frame(height: 100)
                                Text(buddy.name).font(.headline)
                            }.padding(12).frame(maxWidth: .infinity, minHeight: 148)
                                .background(.cyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 22))
                        }.buttonStyle(.plain).accessibilityLabel(buddy.name).accessibilityIdentifier("ocean.buddy.\(buddy.id)")
                    }
                }
            }
        }
    }
}

private struct OceanBuddyPortrait: View {
    let buddy: OceanBuddy
    var body: some View {
        Image(buddy.asset).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 15))
            .accessibilityHidden(true)
    }
}

private struct OceanTrashArt: View {
    let litter: OceanLitter
    private var color: Color {
        switch litter.id {
        case "bottle": .blue
        case "bag": .purple
        case "can": .gray
        case "cup": .red
        case "carton": .brown
        default: .orange
        }
    }
    var body: some View {
        ZStack {
            Image(systemName: litter.symbol).resizable().scaledToFit().foregroundStyle(color)
            if litter.id == "wrapper" {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { _ in Rectangle().fill(.white.opacity(0.8)).frame(width: 4) }
                }.padding(.vertical, 8)
            }
        }.accessibilityHidden(true)
    }
}
