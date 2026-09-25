import SwiftUI

struct FriendshipBridgeGame: View {
    let onReplay: () -> Void
    @AppStorage("feelings.bridge.first") private var previousFirst = ""
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var play = BridgePlay()
    @State private var started = false
    @State private var selectedToken: String?
    @State private var feedback = ""
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Friendship Bridge", prompt: play.prompt, accent: .teal,
                            completion: play.phase == .complete, onReplay: onReplay, scrollToTopOnPromptChange: play.phase != .playing) {
            if play.phase == .friends {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(TogetherFriend.bank) { friend in
                        Button { play.chooseFriend(friend.id) } label: {
                            VStack {
                                TogetherFriendArt(friend: friend).frame(width: 100, height: 150)
                                    .scaleEffect(0.7).frame(width: 70, height: 105)
                                Text(friend.name).font(.headline)
                            }.frame(maxWidth: .infinity).padding(12).background(.white, in: RoundedRectangle(cornerRadius: 22))
                        }.buttonStyle(.plain).accessibilityLabel("Play with \(friend.appearance)")
                            .accessibilityIdentifier("bridge.friend.\(friend.id)")
                    }
                }
            } else if let friend = play.friend {
                BridgeFriendScene(friend: friend, pieces: play.bridgePieces,
                                  waving: play.current.kind == .wave && play.current.id != "space" && play.actions > 0)
                Text("\(play.bridgePieces) of 12 bridge pieces").font(.headline).accessibilityIdentifier("bridge.progress")
                Text(play.current.title).font(.title2.bold()).accessibilityIdentifier("bridge.story.\(play.current.id)")
                switch play.phase {
                case .choosing:
                    ForEach(0..<2, id: \.self) { index in
                        HStack {
                            ToddlerActionButton(title: play.current.choices[index].title, systemImage: "bubble.left.fill", color: .teal) { play.chooseWords(index) }
                                .accessibilityIdentifier("bridge.words.\(index)")
                            Button { narrator.speak(play.current.choices[index].title) } label: {
                                Image(systemName: "speaker.wave.2.fill").frame(width: 48, height: 60)
                            }.accessibilityLabel("Hear \(play.current.choices[index].title)")
                        }
                    }
                case .ready:
                    ToddlerActionButton(title: "Let's try it!", systemImage: "play.fill", color: .orange) { feedback = ""; selectedToken = nil; play.start() }
                        .accessibilityIdentifier("bridge.start")
                case .playing:
                    activity
                    Text("\(play.actions) of \(play.current.goal) playful actions").font(.headline).accessibilityIdentifier("bridge.actions")
                    if !feedback.isEmpty { Text(feedback).font(.headline).multilineTextAlignment(.center).accessibilityIdentifier("bridge.feedback") }
                case .celebration:
                    Label("Another piece connects our bridge!", systemImage: "heart.fill").font(.title2.bold()).foregroundStyle(.teal).multilineTextAlignment(.center)
                    ToddlerActionButton(title: play.index == 11 ? "Celebrate our friendship bridge" : "Another playdate", systemImage: "arrow.right", color: .teal) {
                        narrator.stop(); selectedToken = nil; feedback = ""; play.next()
                    }.accessibilityIdentifier("bridge.next")
                case .complete:
                    Text("Our bridge connects two friends!").font(.title2.bold())
                case .friends: EmptyView()
                }
            }
            Text("Try the words with a grown-up. Friends can say no or choose to watch. Small, seated movements count.")
                .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.onAppear {
            guard !started else { return }
            play = BridgePlay(previousFirst: previousFirst); previousFirst = play.current.id; started = true
        }.onDisappear { narrator.stop() }
    }
    private func act(_ value: Int, token: String, target: Int = 0) {
        let accepted: Bool
        if reduceMotion { accepted = play.act(value, token: token, target: target) }
        else { accepted = withAnimation(.easeInOut(duration: 0.35)) { play.act(value, token: token, target: target) } }
        if accepted { feedback = ""; selectedToken = nil }
        else if play.phase == .playing {
            feedback = play.current.kind == .copy ? BridgeAdventure.copyRetry : BridgeAdventure.retry
            narrator.speak(feedback)
        }
    }
    @ViewBuilder private var activity: some View {
        switch play.current.kind {
        case .wave:
            Button { act(0, token: play.token) } label: {
                VStack(spacing: 14) {
                    Image(systemName: play.choice == 0 ? "hand.wave.fill" : "face.smiling.fill")
                        .font(.system(size: 85)).rotationEffect(.degrees(play.actions.isMultiple(of: 2) ? -10 : 10))
                    Text(play.choice == 0 ? "Wave hello" : "Send a smile").font(.title2.bold())
                    HStack { ForEach(0..<3) { i in Image(systemName: i < play.actions ? "heart.fill" : "heart").foregroundStyle(.pink) } }
                }.frame(maxWidth: .infinity).padding(24).background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 26))
            }.buttonStyle(.plain).accessibilityIdentifier("bridge.wave")
        case .pass:
            VStack(spacing: 20) {
                HStack { Text("You"); Spacer(); Text(play.friend?.name ?? "Buddy") }.font(.headline)
                GeometryReader { g in
                    Path { p in p.move(to: CGPoint(x: 42, y: 48)); p.addLine(to: CGPoint(x: g.size.width - 42, y: 48)) }
                        .stroke(.teal.opacity(0.25), style: StrokeStyle(lineWidth: 8, dash: [10, 8]))
                    Button { act(play.turn, token: play.token) } label: {
                        Image(systemName: play.current.symbol).font(.system(size: 49)).foregroundStyle(.orange)
                            .frame(width: 84, height: 84).background(.white, in: Circle()).overlay(Circle().stroke(.orange, lineWidth: 3))
                    }.buttonStyle(.plain).position(x: play.turn == 0 ? 45 : g.size.width - 45, y: 48)
                        .accessibilityLabel(play.turn == 0 ? "Pass to your friend" : "Let your friend pass back")
                        .accessibilityIdentifier("bridge.pass")
                }.frame(height: 100)
                Label(play.turn == 0 ? "Your turn" : "Your friend's turn", systemImage: play.turn == 0 ? "arrow.right" : "arrow.left").font(.title2.bold())
            }.padding(16).background(.teal.opacity(0.1), in: RoundedRectangle(cornerRadius: 24))
        case .copy:
            VStack(spacing: 18) {
                Text("Our friend's picture").font(.headline)
                BridgeCopyPicture(option: play.current.copies[play.copyTarget], animal: play.current.id == "animals")
                    .frame(width: 100, height: 100).accessibilityIdentifier("bridge.example.\(play.copyTarget)")
                HStack(spacing: 12) {
                    ForEach(play.copyChoices, id: \.self) { index in
                        Button { act(index, token: play.token) } label: {
                            VStack {
                                BridgeCopyPicture(option: play.current.copies[index], animal: play.current.id == "animals").frame(width: 66, height: 66)
                                Text(play.current.copies[index].title).font(.headline).minimumScaleFactor(0.7).lineLimit(1)
                            }.frame(maxWidth: .infinity).padding(.vertical, 12).background(.white, in: RoundedRectangle(cornerRadius: 18))
                        }.buttonStyle(.plain).accessibilityIdentifier("bridge.copy.\(index)")
                    }
                }
                Text("Copy the picture, or try a tiny silly action together!").font(.subheadline).multilineTextAlignment(.center)
            }
        case .bubbles:
            Text(play.turn == 0 ? "You · Teal" : "Friend · Purple").font(.title2.bold())
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(play.bubbles, id: \.self) { id in
                    Button { act(id, token: play.token) } label: {
                        Image(systemName: play.popped.contains(id) ? "sparkles" : play.current.symbol)
                            .font(.system(size: 41)).foregroundStyle(id.isMultiple(of: 2) ? Color.teal : .purple)
                            .frame(maxWidth: .infinity, minHeight: 78)
                            .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 22))
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(id % 2 == play.turn && !play.popped.contains(id) ? Color.orange : .clear, lineWidth: 3))
                            .opacity(play.popped.contains(id) ? 0.25 : 1)
                    }.buttonStyle(.plain).disabled(play.popped.contains(id))
                        .accessibilityLabel(id.isMultiple(of: 2) ? "Your teal shape" : "Friend's purple shape")
                        .accessibilityIdentifier("bridge.bubble.\(id)")
                }
            }
        case .build, .tidy:
            VStack(spacing: 18) {
                if play.current.kind == .build {
                    if play.current.id == "tower" {
                        VStack(spacing: 2) {
                            ForEach(Array((0..<6).reversed()), id: \.self) { index in
                                RoundedRectangle(cornerRadius: 3).fill(index < play.actions ? (index.isMultiple(of: 2) ? Color.teal : .purple) : .gray.opacity(0.1))
                                    .frame(width: CGFloat(100 - index * 5), height: 14)
                            }
                        }.frame(height: 100).accessibilityLabel("\(play.actions) shared tower blocks")
                    } else {
                        HStack(spacing: 5) {
                            ForEach(0..<6) { index in
                                RoundedRectangle(cornerRadius: 6).fill(index < play.actions ? (index.isMultiple(of: 2) ? Color.teal : .purple) : .gray.opacity(0.1))
                                    .frame(maxWidth: .infinity).frame(height: 45)
                            }
                        }.frame(height: 90).accessibilityLabel("\(play.actions) shared bridge blocks")
                    }
                }
                Button { selectedToken = play.token } label: {
                    Image(systemName: play.current.symbol).font(.system(size: 58)).foregroundStyle(play.turn == 0 ? .teal : .purple)
                        .frame(width: 94, height: 88).background(.white, in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(selectedToken == play.token ? Color.orange : .clear, lineWidth: 3))
                }.buttonStyle(.plain).draggable(play.token) {
                    Image(systemName: play.current.symbol).font(.system(size: 58)).foregroundStyle(.teal)
                }.accessibilityLabel("Pick up the \(play.current.kind == .build ? "block" : "picture item")")
                    .accessibilityIdentifier("bridge.drag")
                Text("Drag the picture, or tap it and then tap its spot.").font(.subheadline).multilineTextAlignment(.center)
                HStack {
                    ForEach(0..<(play.current.kind == .build ? 2 : 1), id: \.self) { target in
                        dropSpot(target)
                    }
                }
            }
        }
    }
    private func dropSpot(_ target: Int) -> some View {
        let active = play.current.kind == .tidy || target == play.turn
        return Button {
            guard selectedToken == play.token else { return }
            act(play.actions, token: play.token, target: target)
        } label: {
            VStack(spacing: 10) {
                Image(systemName: play.current.kind == .build ? "square.dashed" : play.current.id == "picture" ? "photo.artframe" : "shippingbox.fill").font(.system(size: 44))
                Text(play.current.kind == .build ? (target == 0 ? "Your building spot" : "Friend's building spot") : play.current.id == "picture" ? "Our shared picture" : "Our toy box").font(.headline)
                if play.current.kind == .tidy {
                    HStack { ForEach(0..<play.actions, id: \.self) { _ in Image(systemName: play.current.symbol).foregroundStyle(.pink) } }
                }
            }.frame(maxWidth: .infinity, minHeight: 115).padding(10)
                .background(.teal.opacity(0.09), in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(active ? Color.orange : .gray.opacity(0.2), lineWidth: 3))
        }.buttonStyle(.plain).accessibilityIdentifier("bridge.drop.\(target)")
            .dropDestination(for: String.self) { values, _ in
                guard values.count == 1, values[0] == play.token, play.phase == .playing else { return false }
                let before = play.actions
                act(play.actions, token: values[0], target: target)
                return play.actions > before
            }
    }
}

struct BridgeCopyPicture: View {
    let option: BridgeCopy
    let animal: Bool
    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            ZStack {
                Circle().fill(animal ? Color.teal.opacity(0.12) : Color.yellow.opacity(0.7))
                if animal {
                    Image(systemName: option.symbol).font(.system(size: w * 0.57)).foregroundStyle(.teal)
                } else {
                    HStack(spacing: w * 0.2) {
                        Circle().fill(.indigo).frame(width: w * 0.1, height: w * 0.13)
                        if option.id == 1 { Capsule().fill(.indigo).frame(width: w * 0.14, height: w * 0.04) }
                        else { Circle().fill(.indigo).frame(width: w * 0.1, height: w * 0.13) }
                    }.offset(y: -w * 0.12)
                    if option.id == 2 { Ellipse().fill(.indigo).frame(width: w * 0.19, height: w * 0.26).offset(y: w * 0.2) }
                    else {
                        Path { p in p.move(to: CGPoint(x: w * 0.28, y: w * 0.6)); p.addQuadCurve(to: CGPoint(x: w * 0.72, y: w * 0.6), control: CGPoint(x: w * 0.5, y: w * 0.93)) }
                            .stroke(.indigo, style: StrokeStyle(lineWidth: w * 0.04, lineCap: .round))
                    }
                }
            }
        }.accessibilityElement(children: .ignore).accessibilityLabel(option.title)
    }
}

struct BridgeFriendScene: View {
    let friend: TogetherFriend
    let pieces: Int
    let waving: Bool
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                RescueTeddy(fur: .brown, identity: .boy, items: []).frame(width: 75, height: 105).accessibilityLabel("Your teddy")
                Spacer()
                TogetherFriendArt(friend: friend, waving: waving).frame(width: 100, height: 150).scaleEffect(0.7).frame(width: 70, height: 105)
            }.padding(.horizontal, 22)
            GeometryReader { g in
                ZStack {
                    RoundedRectangle(cornerRadius: 18).fill(.cyan.opacity(0.22))
                    HStack(spacing: 3) {
                        ForEach(0..<12) { i in
                            RoundedRectangle(cornerRadius: 4).fill(i < pieces ? Color.brown : .brown.opacity(0.12))
                                .frame(maxWidth: .infinity).frame(height: 40).rotationEffect(.degrees(i.isMultiple(of: 2) ? -3 : 3))
                        }
                    }.padding(.horizontal, 12)
                    if pieces == 12 { Image(systemName: "heart.fill").font(.title).foregroundStyle(.pink).padding(7).background(.white, in: Circle()) }
                }.frame(width: g.size.width, height: 66)
            }.frame(height: 66)
        }.padding(12).background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 24))
            .accessibilityElement(children: .ignore).accessibilityLabel("You and \(friend.name), connected by \(pieces) bridge pieces")
    }
}
