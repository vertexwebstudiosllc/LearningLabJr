import SwiftUI

struct RollItTogetherGame: View {
    let onReplay: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var play = TogetherSportsPlay()
    @State private var ballProgress = 0.0
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ToddlerGameScaffold(title: "Roll It Together", prompt: play.prompt, accent: .orange,
                            completion: play.phase == .complete, onReplay: onReplay) {
            switch play.phase {
            case .sport: sportPicker
            case .friend: friendPicker
            case .invite: invitation
            default: match
            }
        }.task(id: "\(play.id):\(play.completed):\(play.phase.rawValue):\(scenePhase == .active)") {
            guard scenePhase == .active else { return }
            let phase = play.phase, rally = play.completed, session = play.id
            let duration: Double
            switch phase {
            case .outbound, .inbound:
                duration = reduceMotion ? 0.2 : 1.1
                withAnimation(reduceMotion ? nil : .linear(duration: duration)) { ballProgress = phase == .outbound ? 1 : 0 }
            case .friendTurn: duration = 3.5
            default: return
            }
            do { try await Task.sleep(for: .seconds(duration)) } catch { return }
            guard !Task.isCancelled, scenePhase == .active else { return }
            play.finishMotion(session: session, rally: rally, phase: phase)
        }
    }
    private var sportPicker: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(TogetherSport.allCases) { sport in
                Button { play.choose(sport) } label: {
                    VStack(spacing: 10) {
                        TogetherBall(sport: sport).frame(width: 66, height: 66)
                        Text(sport.name).font(.headline)
                    }.frame(maxWidth: .infinity, minHeight: 142)
                        .background(sport.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 22))
                }.buttonStyle(.plain).accessibilityIdentifier("sports.choose.\(sport.id)")
            }
        }
    }
    private var friendPicker: some View {
        VStack(spacing: 16) {
            Button("Choose a different sport") { play.changeSport() }.font(.headline).frame(minHeight: 48).accessibilityIdentifier("sports.changeSport")
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(play.friends) { friend in
                    Button { play.chooseFriend(friend.id) } label: {
                        VStack(spacing: 8) {
                            TogetherFriendArt(friend: friend, waving: true).frame(width: 90, height: 135)
                            Text(friend.name).font(.headline)
                        }.frame(maxWidth: .infinity, minHeight: 180)
                            .background(.white, in: RoundedRectangle(cornerRadius: 22))
                    }.buttonStyle(.plain).accessibilityLabel(friend.appearance).accessibilityIdentifier("sports.friend.\(friend.id)")
                }
            }
        }
    }
    @ViewBuilder private var invitation: some View {
        if let friend = play.friend {
            TogetherFriendArt(friend: friend, waving: true).frame(width: 150, height: 225)
            Text(friend.name).font(.title.bold())
            ToddlerActionButton(title: "Want to play together?", systemImage: "bubble.left.and.bubble.right.fill", color: .orange) { play.invite() }
                .accessibilityIdentifier("sports.invite")
            Button("Choose another friend") { play.changeFriend() }.font(.headline).frame(minHeight: 48).accessibilityIdentifier("sports.changeFriend")
        }
    }
    @ViewBuilder private var match: some View {
        if let sport = play.sport, let friend = play.friend {
            Text("\(sport.name) with \(friend.name)").font(.title2.bold()).accessibilityIdentifier("sports.match")
            TogetherSportsCourt(sport: sport, friend: friend, progress: ballProgress,
                                waiting: [.outbound, .friendTurn, .inbound].contains(play.phase), shared: play.phase == .shared || play.phase == .complete)
                .accessibilityIdentifier("sports.court")
            Text("\(play.completed) of 6 shared turns").font(.headline).accessibilityIdentifier("sports.progress")
            HStack(spacing: 10) {
                ForEach(0..<6) { i in Image(systemName: i < play.completed ? "heart.fill" : "heart").foregroundStyle(.pink).font(.title3) }
            }.accessibilityHidden(true)
            switch play.phase {
            case .yourTurn:
                Label("Your turn", systemImage: "hand.point.up.left.fill").font(.title2.bold()).accessibilityIdentifier("sports.yourTurn")
                ToddlerActionButton(title: sport.action, systemImage: "arrow.right", color: .orange) { play.pass() }.accessibilityIdentifier("sports.pass")
            case .outbound, .friendTurn, .inbound:
                Label("\(friend.name)'s turn", systemImage: "person.fill").font(.title2.bold()).accessibilityIdentifier("sports.waiting")
                Text("Watch your friend pass back.").font(.headline)
            case .shared:
                Label("A turn for each of us!", systemImage: "heart.fill").font(.title2.bold())
                ToddlerActionButton(title: play.completed.isMultiple(of: 2) ? "Say something kind" : "Another shared turn", systemImage: "arrow.right", color: .orange) { play.continuePlaying() }.accessibilityIdentifier("sports.next")
            case .kindWords:
                ForEach(play.kindChoices) { choice in
                    ToddlerActionButton(title: choice.title, systemImage: "bubble.left.fill", color: .pink) { play.say(choice.id) }.accessibilityIdentifier("sports.kind.\(choice.id)")
                }
            case .response:
                Label(play.completed == 0 ? "Let's play!" : "Kind words help us play", systemImage: "heart.fill").font(.headline)
                ToddlerActionButton(title: play.completed == 6 ? "Finish with a thank-you" : "Ready to play", systemImage: "arrow.right", color: .orange) {
                    play.continuePlaying()
                }.accessibilityIdentifier("sports.continue")
            case .thanks:
                ToddlerActionButton(title: "We played together", systemImage: "heart.fill", color: .orange) { play.continuePlaying() }.accessibilityIdentifier("sports.finish")
            case .complete: Text("You shared the game and the fun!").font(.title2.bold())
            default: EmptyView()
            }
        }
    }
}
