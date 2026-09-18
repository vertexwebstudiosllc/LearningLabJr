import SwiftUI

struct AlphabetWindow: Identifiable {
    let letter: String
    let word: String
    let asset: String?
    var id: String { letter }
    var phrase: String { "\(letter) is for \(word)." }
    var success: String { phrase + " You opened all the alphabet windows!" }

    static let vocabulary: [AlphabetWindow] = BeginningSoundsPair.alphabet.flatMap { pair in
        var words = [AlphabetWindow(letter: pair.letter, word: pair.word, asset: pair.asset),
                     AlphabetWindow(letter: pair.letter, word: pair.matchingWord, asset: pair.matchingAsset)]
        for item in WordBuilderWord.bank where item.word.hasPrefix(pair.letter) {
            let word = item.word.lowercased()
            if !words.contains(where: { $0.word == word }) {
                words.append(AlphabetWindow(letter: pair.letter, word: word, asset: item.asset))
            }
        }
        return words
    }
}

struct AlphabetAdventureRound {
    let windows: [AlphabetWindow]
    var prompt: String { "Open the letter windows: \(windows.map(\.letter).joined(separator: ", ")). Say each letter and picture word together." }

    static func session(previousWords: [String: String]) -> [AlphabetAdventureRound] {
        let windows = LetterDrawAlphabet.letters.map { letter in
            // Every letter has at least two pictures. Avoid its last session's
            // picture while choosing randomly among the remaining words.
            AlphabetWindow.vocabulary.filter { $0.letter == letter && $0.word != previousWords[letter] }.randomElement()!
        }
        return stride(from: 0, to: windows.count, by: 3).map { start in
            AlphabetAdventureRound(windows: Array(windows[start..<min(start + 3, windows.count)]))
        }
    }
}

struct AlphabetWindowsGame: View {
    @StateObject private var play = LiteracyPlay(total: 9)
    @AppStorage("alphabetAdventure.previousWords") private var previousWords = "{}"
    @State private var rounds: [AlphabetAdventureRound] = []

    var body: some View {
        VStack(spacing: 0) {
            if rounds.indices.contains(play.round) {
                let round = rounds[play.round]
                LiteracyStage(title: "ABC Adventure", prompt: round.prompt, play: play,
                              onReplay: restart, progressLabel: "Adventure", nextLabel: "Next letters") {
                    VStack(spacing: 18) {
                        Text("\(play.marked.count) of \(round.windows.count) windows open").font(.headline)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 124))], spacing: 16) {
                            ForEach(Array(round.windows.enumerated()), id: \.element.id) { index, window in
                                Button {
                                    play.marked.insert(index)
                                    if play.marked.count == round.windows.count { play.win(window.success) }
                                    else { play.say(window.phrase) }
                                } label: {
                                    VStack(spacing: 12) {
                                        Text(window.letter).font(.system(size: 42, weight: .bold, design: .rounded))
                                        if play.marked.contains(index) {
                                            BeginningSoundsArt(word: window.word, asset: window.asset, letter: window.letter)
                                                .frame(width: 96, height: 96)
                                            Text(window.word).font(.headline)
                                        } else {
                                            Image(systemName: "window.casement.closed").font(.system(size: 60)).frame(height: 96)
                                        }
                                    }.frame(maxWidth: .infinity, minHeight: 200)
                                        .background(.white, in: RoundedRectangle(cornerRadius: 22))
                                        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.orange.opacity(0.4), lineWidth: 2))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(play.marked.contains(index) ? "\(window.phrase) Hear again." : "Open letter \(window.letter) window")
                                .accessibilityIdentifier("alphabet-adventure.window.\(window.letter)")
                            }
                        }
                    }
                }
            }
        }
        .onAppear { if rounds.isEmpty { restart() } }
        .onDisappear { rounds = [] }
    }

    private func restart() {
        let previous = (try? JSONDecoder().decode([String: String].self, from: Data(previousWords.utf8))) ?? [:]
        rounds = AlphabetAdventureRound.session(previousWords: previous)
        let selected = Dictionary(uniqueKeysWithValues: rounds.flatMap(\.windows).map { ($0.letter, $0.word) })
        if let data = try? JSONEncoder().encode(selected), let json = String(data: data, encoding: .utf8) {
            previousWords = json
        }
        play.replay()
    }
}
