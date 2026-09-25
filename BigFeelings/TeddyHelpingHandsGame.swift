import SwiftUI

struct TeddyHelpingHandsGame: View {
    let onReplay: () -> Void
    @AppStorage("feelings.rescue.lastSecond") private var lastSecond = ""
    @State private var play = TeddyRescuePlay()
    @State private var started = false
    @State private var customizing = false
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Teddy's Helping Hands", prompt: play.prompt, accent: .pink,
                            completion: play.complete, onReplay: onReplay) {
            if !play.complete {
                if play.phase == .create {
                    Text("Build your helper Teddy").font(.title2.bold())
                    avatar(height: 225)
                    customization
                    ToddlerActionButton(title: "Let's help!", systemImage: "heart.fill", color: .pink) {
                        play.begin()
                    }.accessibilityIdentifier("rescue.begin")
                } else {
                    mission
                }
            } else {
                avatar(height: 200)
                Text("Twelve helping adventures!").font(.title2.bold())
            }
        }.onAppear {
            guard !started else { return }
            play = TeddyRescuePlay(previousSecond: lastSecond)
            lastSecond = play.rounds[1].scene.id; started = true
        }.onDisappear { narrator.stop() }
            .sheet(isPresented: $customizing) {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Your helper Teddy").font(.title.bold())
                        avatar(height: 225)
                        customization
                        ToddlerActionButton(title: "Ready to help", systemImage: "checkmark", color: .pink) {
                            narrator.stop(); customizing = false
                        }.accessibilityIdentifier("rescue.customize.done")
                    }.padding(24)
                }.presentationDetents([.large])
            }
    }
    private func avatar(height: CGFloat) -> some View {
        RescueTeddy(fur: play.fur, identity: play.identity, items: play.equipped)
            .frame(height: height).accessibilityIdentifier("rescue.teddy")
    }
    private var customization: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(TeddyIdentity.allCases) { identity in
                    Button {
                        play.identity = identity; narrator.speak(identity.narration)
                    } label: {
                        Label(identity.name, systemImage: play.identity == identity ? "checkmark.circle.fill" : "circle")
                            .font(.headline).frame(maxWidth: .infinity, minHeight: 58)
                            .background(.pink.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                    }.buttonStyle(.plain).accessibilityValue(play.identity == identity ? "Selected" : "Not selected")
                        .accessibilityIdentifier("rescue.identity.\(identity.rawValue)")
                }
            }
            Text("Choose Teddy's fur").font(.headline)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(TeddyFur.allCases) { fur in
                    Button {
                        play.fur = fur; narrator.speak(fur.narration)
                    } label: {
                        VStack(spacing: 6) {
                            Circle().fill(fur.color).frame(width: 38, height: 38)
                                .overlay(Circle().stroke(.brown.opacity(0.35), lineWidth: 1))
                                .overlay { if play.fur == fur { Image(systemName: "checkmark").foregroundStyle(.white).font(.headline.bold()).shadow(radius: 1) } }
                            Text(fur.name).font(.subheadline.bold())
                        }.frame(maxWidth: .infinity, minHeight: 80)
                            .background(.white, in: RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain).accessibilityLabel("\(fur.name) fur")
                        .accessibilityValue(play.fur == fur ? "Selected" : "Not selected")
                        .accessibilityIdentifier("rescue.fur.\(fur.rawValue)")
                }
            }
        }
    }
    @ViewBuilder private var mission: some View {
        let scene = play.current.scene
        let slot = play.slot
        Text("Scene \(play.index + 1) of \(play.rounds.count)").font(.headline)
            .accessibilityIdentifier("rescue.progress")
        Text(scene.title).font(.title2.bold()).accessibilityIdentifier("rescue.scene.\(scene.id)")
        TeddyRescueScene(scene: scene, rescued: play.phase == .rescued, fur: play.fur, identity: play.identity).frame(height: 200)
            .accessibilityIdentifier("rescue.story")
        HStack(spacing: 15) {
            avatar(height: 190).frame(width: 155)
            VStack(spacing: 12) {
                Text(play.identity.name).font(.headline)
                Text("\(play.stage) of 3 helper pieces").font(.subheadline)
                    .accessibilityIdentifier("rescue.equipped")
                Button("Change Teddy") { customizing = true }
                    .font(.headline).frame(minHeight: 48).accessibilityIdentifier("rescue.customize")
            }.frame(maxWidth: .infinity)
        }
        switch play.phase {
        case .dress:
            HStack(alignment: .top, spacing: 10) {
                ForEach(play.current.choices[play.stage]) { item in
                    VStack(spacing: 5) {
                        Button { play.choose(item.id, scene: scene.id, slot: slot) } label: {
                            VStack(spacing: 10) {
                                RescueItemArt(item: item).frame(width: 70, height: 65)
                                Text(item.name).font(.system(.subheadline, design: .rounded, weight: .bold))
                                    .multilineTextAlignment(.center).frame(minHeight: 44)
                            }.padding(8).frame(maxWidth: .infinity, minHeight: 138)
                                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                                .overlay(RoundedRectangle(cornerRadius: 18).stroke(.pink.opacity(0.3), lineWidth: 2))
                        }.buttonStyle(.plain).accessibilityLabel(item.name).accessibilityIdentifier("rescue.item.\(item.id)")
                        Button { narrator.speak(item.narration) } label: {
                            Image(systemName: "speaker.wave.2.fill").frame(maxWidth: .infinity, minHeight: 48)
                        }.accessibilityLabel("Hear \(item.name)").accessibilityIdentifier("rescue.hear.\(item.id)")
                    }.frame(maxWidth: .infinity)
                }
            }
            if play.needsHelp {
                Text("Let's find the piece for this helper.").font(.headline).accessibilityIdentifier("rescue.retry")
            }
        case .ready:
            ToddlerActionButton(title: scene.action, systemImage: "heart.fill", color: .pink) {
                play.help(scene.id)
            }.accessibilityIdentifier("rescue.help")
        case .rescued:
            Label("Teddy helped!", systemImage: "heart.fill").font(.title2.bold()).accessibilityIdentifier("rescue.success")
            ToddlerActionButton(title: play.index == play.rounds.count - 1 ? "Finish helping" : "Another helping adventure", systemImage: "arrow.right", color: .pink) {
                play.advance(scene.id)
            }.accessibilityIdentifier("rescue.next")
        case .create: EmptyView()
        }
    }
}
