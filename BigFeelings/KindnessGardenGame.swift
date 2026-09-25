import SwiftUI

struct KindnessGardenGame: View {
    let onReplay: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("feelings.kindness.lastFirst") private var lastFirst = ""
    @State private var play = KindGardenPlay()
    @State private var started = false
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Kindness Garden", prompt: play.prompt, accent: .green,
                            completion: play.phase == .complete, onReplay: onReplay, scrollToTopOnPromptChange: true) {
            KindGardenPlot(flowers: play.flowers)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.65), value: play.flowers)
            Text(play.flowers == 1 ? "1 garden flower" : "\(play.flowers) garden flowers").font(.headline).accessibilityIdentifier("kindness.flowers")
            switch play.phase {
            case .welcome:
                ToddlerActionButton(title: "Start our garden stories", systemImage: "leaf.fill", color: .green) { play.start() }
                    .accessibilityIdentifier("kindness.start")
            case .choosing, .feedback:
                Text("Story \(play.index + 1) of \(play.rounds.count)").font(.headline).accessibilityIdentifier("kindness.progress")
                KindGardenScene(story: play.current.story).accessibilityIdentifier("kindness.story.\(play.current.story.id)")
                if play.phase == .choosing {
                    ForEach(play.current.choices) { choice in
                        HStack(spacing: 8) {
                            ToddlerActionButton(title: choice.title, systemImage: choice.symbol, color: .teal) { play.choose(choice.id, story: play.current.story.id) }
                                .disabled(!choice.isCaring && play.triedUnkind)
                                .opacity(!choice.isCaring && play.triedUnkind ? 0.45 : 1)
                                .accessibilityIdentifier("kindness.choice.\(choice.id)")
                            Button { narrator.speak(choice.title) } label: {
                                Image(systemName: "speaker.wave.2.fill").font(.title3).frame(width: 48, height: 60)
                            }.accessibilityLabel("Hear \(choice.title)").accessibilityIdentifier("kindness.hear.\(choice.id)")
                        }
                    }
                } else {
                    Label(play.feedbackTitle, systemImage: play.selected?.isCaring == true ? "leaf.fill" : "arrow.uturn.backward")
                        .font(.title2.bold()).accessibilityIdentifier("kindness.feedback")
                    if play.selected?.isCaring == false {
                        ToddlerActionButton(title: "Try a caring choice", systemImage: "arrow.uturn.backward", color: .green) { play.tryAgain() }
                            .accessibilityIdentifier("kindness.retry")
                    }
                    ToddlerActionButton(title: play.index == play.rounds.count - 1 ? "Finish our stories" : "Another garden story", systemImage: "arrow.right", color: .teal) { play.next(play.current.story.id) }
                        .accessibilityIdentifier("kindness.next")
                }
            case .complete:
                Text("You explored twelve garden stories. We can practice caring every day!").font(.title2.bold()).multilineTextAlignment(.center)
            }
        }.onAppear {
            guard !started else { return }
            play = KindGardenPlay(previousFirst: lastFirst); lastFirst = play.current.story.id; started = true
        }.onDisappear { narrator.stop() }
    }
}
