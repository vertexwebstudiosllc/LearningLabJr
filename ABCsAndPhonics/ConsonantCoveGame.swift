import SwiftUI

struct ConsonantCoveGame: View {
    private let rounds: [ConsonantCoveRound] = [
        ConsonantCoveRound(word: "cat", letters: ["c", "a", "t"], imageName: "cat"),
        ConsonantCoveRound(word: "duck", letters: ["d", "u", "c", "k"], imageName: "duck"),
        ConsonantCoveRound(word: "fish", letters: ["f", "i", "s", "h"], imageName: "fish"),
        ConsonantCoveRound(word: "horse", letters: ["h", "o", "r", "s", "e"], imageName: "horse")
    ]

    @State private var currentRoundIndex = 0
    @State private var selectedLetters = ""
    @State private var feedback: ConsonantCoveFeedback? = nil
    @State private var letters: [String] = []

    private var currentRound: ConsonantCoveRound {
        rounds[currentRoundIndex]
    }

    var body: some View {
        ZStack {
            BeginningSoundsBackgroundLayer()

            VStack(spacing: 18) {
                Spacer().frame(height: 26)

                Text("Consonant Cove")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Tap the letters to spell the word")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    if let imageName = currentRound.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                    }

                    Text(selectedLetters.uppercased())
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(minHeight: 48)

                    Text("Try: \(currentRound.word.uppercased())")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.vertical, 8)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(letters, id: \.self) { letter in
                        Button {
                            tapLetter(letter)
                        } label: {
                            Text(letter.uppercased())
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 62)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.white.opacity(0.32))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(Color.white.opacity(0.42), lineWidth: 2)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 28)

                if let feedback {
                    Text(feedback.message)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 6)
                }

                Spacer()
            }
            .padding(.bottom, 24)
        }
        .onAppear {
            startRound()
        }
    }

    private func startRound() {
        letters = currentRound.letters.shuffled()
        selectedLetters = ""
        feedback = nil
    }

    private func tapLetter(_ letter: String) {
        selectedLetters.append(letter)

        if selectedLetters == currentRound.word {
            feedback = .success
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if currentRoundIndex < rounds.count - 1 {
                    currentRoundIndex += 1
                } else {
                    currentRoundIndex = 0
                }
                startRound()
            }
        } else if selectedLetters.count == currentRound.word.count {
            feedback = .tryAgain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                feedback = nil
                selectedLetters = ""
            }
        }
    }
}

private struct ConsonantCoveRound {
    let word: String
    let letters: [String]
    let imageName: String?
}

private enum ConsonantCoveFeedback {
    case success
    case tryAgain

    var message: String {
        switch self {
        case .success:
            return "You spelled it!"
        case .tryAgain:
            return "Try again"
        }
    }
}

#Preview {
    ConsonantCoveGame()
}
