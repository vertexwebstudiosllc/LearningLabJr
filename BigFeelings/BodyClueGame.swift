import SwiftUI

struct BodyClueBuddiesGame: View {
    let onReplay: () -> Void
    @AppStorage("feelings.body.previousBuddy") private var previousBuddy = ""
    @AppStorage("feelings.body.previousClue") private var previousClue = ""
    @State private var play = BodyCluePlay()
    @State private var started = false
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Body Clue Buddies", prompt: play.prompt, accent: .orange,
                            completion: play.complete, onReplay: onReplay, scrollToTopOnPromptChange: true) {
            HStack {
                Text("Clue \(min(play.index + 1, play.rounds.count)) of \(play.rounds.count)")
                    .accessibilityIdentifier("body.progress")
                Spacer()
                Button { narrator.speak(play.current.buddy.introduction) } label: {
                    Label(play.current.buddy.name, systemImage: "speaker.wave.2.fill").padding(.vertical, 10)
                }.accessibilityLabel("Meet \(play.current.buddy.name)")
                    .accessibilityIdentifier("body.buddy.\(play.current.buddy.id)")
            }.font(.headline)
            BodyBuddyPicture(buddy: play.current.buddy,
                             highlight: play.solved || play.hintShown ? play.current.clue.part : nil,
                             solved: play.solved) { part in
                guard !play.solved, !play.complete else { return }
                if !play.choose(part, clue: play.current.clue.id) {
                    narrator.speak(play.hintShown ? play.current.clue.part.hint : BodyClue.retry)
                }
            }.disabled(play.solved)
                .accessibilityIdentifier("body.picture.\(play.current.clue.id)")
            if play.solved {
                Label(play.current.clue.part.title, systemImage: "checkmark.circle.fill")
                    .font(.title2.bold()).foregroundStyle(.green).accessibilityIdentifier("body.answer")
                ToddlerActionButton(title: play.index == play.rounds.count - 1 ? "Finish our clues" : "Meet another buddy", systemImage: "arrow.right", color: .orange) {
                    narrator.stop(); play.next()
                }.accessibilityIdentifier("body.next")
            } else {
                if play.attempts > 0 {
                    Text(play.hintShown ? play.current.clue.part.hint : BodyClue.retry)
                        .font(.headline).multilineTextAlignment(.center).accessibilityIdentifier("body.feedback")
                }
                ToddlerActionButton(title: "Show me a hint", systemImage: "sparkles", color: .teal) {
                    play.showHint(); narrator.speak(play.current.clue.part.hint)
                }.accessibilityIdentifier("body.hint")
            }
            Text("Tap our picture buddy. Bodies look and work in different ways. Explore with your grown-up.")
                .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.onAppear {
            guard !started else { return }
            play = BodyCluePlay(previousBuddy: previousBuddy, previousClue: previousClue)
            previousBuddy = play.current.buddy.id; previousClue = play.current.clue.id; started = true
        }.onDisappear { narrator.stop() }
    }
}
