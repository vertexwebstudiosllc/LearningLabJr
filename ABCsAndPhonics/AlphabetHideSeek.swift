import SwiftUI

struct LetterHideSeekRound {
    let target: String
    let board: [String]
    var prompt: String { "Find every \(target). There are three hiding here." }
    var found: String { "Found \(target). Keep looking for another." }
    var success: String { "You found all three copies of \(target)!" }
    var retry: String { "Look at the model. Find \(target) next." }

    static func session(previousStart: String, lastShown: String) -> [LetterHideSeekRound] {
        LetterDrawAlphabet.shuffled(startingAfter: previousStart, lastShown: lastShown).map { target in
            let distractors = LetterDrawAlphabet.letters.filter { $0 != target }.shuffled().prefix(3)
            return LetterHideSeekRound(target: target, board: (Array(repeating: target, count: 3) + distractors).shuffled())
        }
    }
}

struct LetterHideSeekGame: View {
    @StateObject private var play = LiteracyPlay(total: 26)
    @AppStorage("letterHideSeek.previousStartingLetter") private var previousStart = ""
    @AppStorage("letterHideSeek.lastShownLetter") private var lastShown = ""
    @State private var rounds: [LetterHideSeekRound] = []

    var body: some View {
        VStack(spacing: 0) {
            if rounds.indices.contains(play.round) {
                let round = rounds[play.round]
                LiteracyStage(title: "Letter Hide & Seek", prompt: round.prompt, play: play,
                              onReplay: restart, progressLabel: "Letter", nextLabel: "Next letter") {
                    VStack(spacing: 18) {
                        Text("Find \(round.target) · \(play.marked.count) of 3").font(.title.bold())
                            .accessibilityIdentifier("letter-hide-seek.target")
                            .accessibilityLabel(round.target)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 88))], spacing: 14) {
                            ForEach(round.board.indices, id: \.self) { index in
                                LiteracyLetterButton(letter: round.board[index], selected: play.marked.contains(index)) {
                                    guard !play.solved, !play.marked.contains(index) else { return }
                                    if round.board[index] == round.target {
                                        play.marked.insert(index)
                                        if play.marked.count == 3 { play.win(round.success) }
                                        else { play.say(round.found) }
                                    } else { play.say(round.retry) }
                                }
                                .overlay(alignment: .topTrailing) {
                                    if play.marked.contains(index) {
                                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).padding(6).accessibilityHidden(true)
                                    }
                                }
                                .accessibilityLabel("Letter \(round.board[index]), \(play.marked.contains(index) ? "found" : "not selected"), position \(index + 1)")
                                .accessibilityIdentifier("letter-hide-seek.cell.\(index)")
                            }
                        }
                    }
                }
            }
        }
        .onAppear { if rounds.isEmpty { restart() } }
        .onDisappear { rounds = [] }
        .onChange(of: play.round) { _, index in
            if rounds.indices.contains(index) { lastShown = rounds[index].target }
        }
    }

    private func restart() {
        rounds = LetterHideSeekRound.session(previousStart: previousStart, lastShown: lastShown)
        previousStart = rounds[0].target
        lastShown = previousStart
        play.replay()
    }
}
