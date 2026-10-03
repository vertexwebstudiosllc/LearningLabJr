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
                            completion: play.complete, onReplay: onReplay, allowUnrecordedPrompt: true) {
            if play.hintShown && !play.solved {
                HStack(spacing: 14) {
                    BodyPartHintArt(buddy: play.current.buddy, part: play.current.clue.part)
                        .frame(width: 96, height: 76)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Look for the \(play.current.clue.part.rawValue)").font(.headline)
                        Text("Try the glowing outline on our buddy.").font(.subheadline)
                    }
                }.padding(12).frame(maxWidth: .infinity)
                    .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                    .accessibilityElement(children: .contain).accessibilityIdentifier("body.visual-hint")
            }
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
                .overlay {
                    if play.solved {
                        VStack(spacing: 8) {
                            Label(play.current.clue.part.title, systemImage: "checkmark.circle.fill")
                                .font(.title2.bold()).foregroundStyle(.green)
                                .accessibilityIdentifier("body.answer")
                            Text(BodyClue.success).font(.headline).multilineTextAlignment(.center)
                        }.padding(18).frame(maxWidth: 290)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.green, lineWidth: 2))
                            .padding(12).allowsHitTesting(false)
                            .accessibilityElement(children: .contain).accessibilityIdentifier("body.success-popup")
                    }
                }
            if play.solved {
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
