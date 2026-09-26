import SwiftUI

struct SeeYouSoonGame: View {
    let onReplay: () -> Void
    @State private var play = GoodbyePlay()
    @State private var stories = GoodbyeStory.bank.shuffled()
    @State private var dragging = false
    @State private var pickedUp = false
    @State private var feedback = ""
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "See You Soon", prompt: play.prompt, accent: .pink,
                            completion: play.phase == .complete, onReplay: onReplay,
                            scrollToTopOnPromptChange: play.phase != .action) {
            if play.phase == .stories {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(stories) { story in
                        VStack {
                            Button { feedback = ""; pickedUp = false; play.chooseStory(story.id) } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: story.symbol).font(.system(size: 43)).foregroundStyle(.pink)
                                    Text(story.title).font(.headline).multilineTextAlignment(.center)
                                    if play.completed.contains(story.id) { Image(systemName: "checkmark.seal.fill").foregroundStyle(.green) }
                                }.frame(maxWidth: .infinity, minHeight: 130).padding(10).background(.white, in: RoundedRectangle(cornerRadius: 23))
                            }.buttonStyle(.plain).accessibilityIdentifier("goodbye.story.\(story.id)")
                            Button { narrator.speak(story.title) } label: { Label("Hear", systemImage: "speaker.wave.2.fill").frame(minHeight: 44) }
                                .accessibilityLabel("Hear \(story.title)")
                        }
                    }
                }
                Text("\(play.completed.count) of 8 stories explored").font(.headline).accessibilityIdentifier("goodbye.progress")
            } else if let story = play.story, let buddy = play.buddy {
                Text(story.title).font(.title2.bold())
                Text("Our buddy: \(buddy.name)").font(.headline).accessibilityIdentifier("goodbye.buddy.\(buddy.id)")
                GoodbyeStoryScene(story: story, buddy: buddy, moved: play.moved, actions: play.actions,
                                  finished: play.completed.contains(story.id) && play.phase == .ending,
                                  canMove: play.phase == .moving, pickedUp: pickedUp, token: play.dragToken,
                                  pickUp: { pickedUp = true }, move: move, dragging: $dragging)
                switch play.phase {
                case .moving:
                    Text("Drag the person to the glowing spot, or tap the person and then tap the spot.")
                        .font(.headline).multilineTextAlignment(.center)
                case .words:
                    Text("Choose words for this goodbye").font(.headline)
                    ForEach(play.choices) { choice in
                        HStack {
                            ToddlerActionButton(title: choice.title, systemImage: choice.symbol, color: .pink) {
                                if play.say(choice.id) { feedback = "" }
                                else { feedback = story.retry; narrator.speak(feedback) }
                            }.accessibilityIdentifier("goodbye.words.\(choice.id)")
                            Button { narrator.speak(choice.title) } label: {
                                Image(systemName: "speaker.wave.2.fill").frame(width: 48, height: 58)
                            }.accessibilityLabel("Hear \(choice.title)").accessibilityIdentifier("goodbye.hear.\(choice.id)")
                        }
                    }
                case .action:
                    if let selected = play.selected {
                        Label(selected.title, systemImage: selected.symbol).font(.title2.bold()).multilineTextAlignment(.center)
                            .accessibilityIdentifier("goodbye.message")
                    }
                    ToddlerActionButton(title: play.actions == 0 ? story.actionTitle : story.kind == .school ? "Open the door: hello again!" : "Wash and dry hands",
                                        systemImage: actionSymbol(story), color: .teal) {
                        play.act(play.actions, session: play.session)
                    }.accessibilityIdentifier("goodbye.action.\(play.actions)")
                case .ending, .paused:
                    if play.phase == .ending {
                        Label("Goodbye story explored!", systemImage: "heart.fill").font(.title2.bold()).foregroundStyle(.pink)
                    }
                    ToddlerActionButton(title: "Choose another story", systemImage: "map.fill", color: .teal) {
                        narrator.stop(); feedback = ""; pickedUp = false; play.stories()
                    }.accessibilityIdentifier("goodbye.stories")
                    ToddlerActionButton(title: "Finish our play", systemImage: "checkmark", color: .pink) {
                        narrator.stop(); play.finish()
                    }.accessibilityIdentifier("goodbye.finish")
                case .stories, .complete: EmptyView()
                }
                if !feedback.isEmpty { Text(feedback).font(.headline).multilineTextAlignment(.center).accessibilityIdentifier("goodbye.feedback") }
                if [.moving, .words, .action].contains(play.phase) {
                    Button("Take a break") { narrator.stop(); feedback = ""; play.pause() }
                        .frame(minHeight: 48).accessibilityIdentifier("goodbye.pause")
                }
            }
            Text("Pretend together. Your real grown-up stays nearby. Talk about who will care for you and when you will meet again. Feelings and pauses are welcome.")
                .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.scrollDisabled(dragging).onDisappear { narrator.stop(); dragging = false }
    }
    private func move(_ token: String) -> Bool {
        let accepted = play.move(token)
        if accepted { pickedUp = false; feedback = "" }
        return accepted
    }
    private func actionSymbol(_ story: GoodbyeStory) -> String {
        if play.actions > 0 { return story.kind == .school ? "door.left.hand.open" : "hands.sparkles.fill" }
        switch story.kind {
        case .night: return "lamp.desk.fill"
        case .school: return "teddybear.fill"
        case .home: return "door.left.hand.open"
        case .park, .visit: return "hand.wave.fill"
        case .bathroom: return "arrow.triangle.2.circlepath"
        }
    }
}

struct GoodbyeStoryScene: View {
    let story: GoodbyeStory
    let buddy: TogetherFriend
    let moved: Bool
    let actions: Int
    let finished: Bool
    let canMove: Bool
    let pickedUp: Bool
    let token: String
    let pickUp: () -> Void
    let move: (String) -> Bool
    @Binding var dragging: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        GeometryReader { g in
            let targetWidth = min(132, g.size.width * 0.43)
            ZStack {
                RoundedRectangle(cornerRadius: 26).fill(story.kind == .night ? Color.indigo.opacity(actions > 0 ? 0.32 : 0.12) : Color.cyan.opacity(0.12))
                VStack {
                    HStack {
                        Image(systemName: story.kind == .night ? "moon.stars.fill" : story.kind == .bathroom ? "drop.fill" : "sun.max.fill")
                            .font(.system(size: 33)).foregroundStyle(story.kind == .night ? .indigo : .orange)
                        Spacer()
                        if story.kind == .school {
                            Label("Trusted adult", systemImage: "person.fill").font(.caption.bold()).foregroundStyle(.teal)
                        } else {
                            Image(systemName: story.kind == .park ? "tree.fill" : "window.vertical.closed").font(.system(size: 32)).foregroundStyle(.teal)
                        }
                    }.padding(16)
                    Spacer()
                    RoundedRectangle(cornerRadius: 20).fill(story.kind == .park ? Color.green.opacity(0.25) : .brown.opacity(0.12)).frame(height: 46)
                }
                if story.kind == .bathroom {
                    VStack(spacing: 2) {
                        ZStack {
                            Image(systemName: "toilet.fill").font(.system(size: 75)).foregroundStyle(.white)
                                .shadow(color: .indigo.opacity(0.25), radius: 1, x: 1, y: 1)
                            Ellipse().fill(.cyan.opacity(0.45)).frame(width: 50, height: 13).offset(x: 6, y: 4)
                            if actions == 0 {
                                if story.id == "pee" {
                                    Image(systemName: "drop.fill").font(.system(size: 23)).foregroundStyle(.yellow).offset(x: 6, y: -3)
                                } else {
                                    Capsule().fill(.brown).frame(width: 26, height: 13).rotationEffect(.degrees(-12)).offset(x: 6, y: 0)
                                }
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 31)).foregroundStyle(.blue)
                                    .rotationEffect(.degrees(actions > 0 ? 360 : 0))
                                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.7), value: actions)
                            }
                        }
                        Text(actions == 0 ? (story.id == "pee" ? "Pee" : "Poo") : "Flushed!").font(.caption.bold())
                    }.position(x: g.size.width * 0.24, y: 193).accessibilityElement(children: .ignore)
                        .accessibilityLabel(actions == 0 ? "Pretend toilet" : "Pretend toilet flushed")
                        .accessibilityIdentifier("goodbye.toilet.\(actions == 0 ? "full" : "flushed")")
                } else if moved {
                    VStack(spacing: 10) {
                        Image(systemName: story.kind == .school ? (actions >= 2 ? "person.2.fill" : "teddybear.fill") : story.kind == .night ? (actions > 0 ? "star.fill" : "lamp.desk.fill") : "hand.wave.fill")
                            .font(.system(size: 48)).foregroundStyle(story.kind == .night ? .yellow : .pink)
                        Text(story.kind == .school ? (actions >= 2 ? "Hello again!" : "Playtime") : story.kind == .night ? (actions > 0 ? "Rest time" : "A cozy light") : "Bye, friends!")
                            .font(.headline).multilineTextAlignment(.center)
                    }.frame(width: g.size.width * 0.4).position(x: g.size.width * 0.25, y: 163)
                }
                Button {
                    if pickedUp && canMove { _ = move(token) }
                } label: {
                    VStack(spacing: 6) {
                        if moved {
                            if story.kind == .night && actions > 0 {
                                GoodbyeSleepingBuddy(friend: buddy).frame(width: 90, height: 132)
                            } else {
                                TogetherFriendArt(friend: buddy, waving: actions > 0 && story.kind != .bathroom)
                                    .frame(width: 100, height: 150).scaleEffect(0.78).frame(width: 78, height: 117)
                            }
                            if actions > 0 && story.kind == .bathroom {
                                Image(systemName: actions > 1 ? "hands.sparkles.fill" : "drop.fill").foregroundStyle(.teal)
                            }
                        } else {
                            Image(systemName: story.symbol).font(.system(size: 49)).foregroundStyle(.teal).frame(height: 95)
                            Image(systemName: "arrow.down").font(.title2.bold()).foregroundStyle(.orange)
                        }
                        Text(story.destination).font(.subheadline.bold()).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                    }.frame(width: targetWidth, height: 192).background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 23))
                        .overlay(RoundedRectangle(cornerRadius: 23).stroke(canMove ? Color.orange : finished ? .green : .teal.opacity(0.2), style: StrokeStyle(lineWidth: 3, dash: canMove ? [7, 5] : [])))
                }.buttonStyle(.plain).position(x: g.size.width * 0.74, y: 167)
                    .accessibilityLabel(moved ? "\(buddy.name) at the \(story.destination)" : "Move to the \(story.destination)")
                    .accessibilityIdentifier("goodbye.drop")
                    .dropDestination(for: String.self) { values, _ in
                        guard canMove, values.count == 1 else { return false }
                        return move(values[0])
                    }
                if !moved {
                    Button(action: pickUp) {
                        TogetherFriendArt(friend: buddy).frame(width: 100, height: 150).scaleEffect(0.86).frame(width: 86, height: 129)
                            .padding(7).background(.white.opacity(pickedUp ? 0.95 : 0.25), in: RoundedRectangle(cornerRadius: 19))
                            .overlay(RoundedRectangle(cornerRadius: 19).stroke(pickedUp ? Color.orange : .clear, lineWidth: 3))
                    }.buttonStyle(.plain).position(x: g.size.width * 0.24, y: story.kind == .bathroom ? 126 : 168)
                        .disabled(!canMove)
                        .modifier(ImmediatePictureDrag(dragging: $dragging,
                            target: CGRect(x: g.frame(in: .global).minX + g.size.width * 0.74 - targetWidth / 2,
                                           y: g.frame(in: .global).minY + 71, width: targetWidth, height: 192),
                            tap: pickUp, drop: { if canMove { _ = move(token) } })).accessibilityLabel("Move \(buddy.name)").accessibilityIdentifier("goodbye.drag")
                }
            }
        }.frame(height: 285).accessibilityElement(children: .contain)
    }
}

struct GoodbyeSleepingBuddy: View {
    let friend: TogetherFriend
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15).fill(.purple.opacity(0.14))
            RoundedRectangle(cornerRadius: 12).fill(.white).frame(width: 78, height: 58).position(x: 45, y: 33)
            Circle().fill(Color.sportsRGB(friend.hair)).frame(width: 57, height: 57).position(x: 45, y: 34)
            Ellipse().fill(Color.sportsRGB(friend.skin)).frame(width: 52, height: 48).position(x: 45, y: 40)
            HStack(spacing: 12) { Capsule().frame(width: 10, height: 3); Capsule().frame(width: 10, height: 3) }
                .foregroundStyle(Color.sportsRGB(0x332525)).position(x: 45, y: 40)
            Capsule().fill(.pink.opacity(0.6)).frame(width: 12, height: 3).position(x: 45, y: 52)
            RoundedRectangle(cornerRadius: 12).fill(.indigo).frame(width: 86, height: 75).position(x: 45, y: 94)
            Image(systemName: "star.fill").font(.title).foregroundStyle(.yellow).position(x: 45, y: 89)
        }.accessibilityLabel("\(friend.name) resting under a blanket")
    }
}
