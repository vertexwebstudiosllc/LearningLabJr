import SwiftUI

struct VowelGardenGame: View {
    private let rounds: [VowelGardenRound] = [
        VowelGardenRound(word: "cat", blankIndex: 1, answer: "a", options: ["a", "e", "i", "o"]),
        VowelGardenRound(word: "dog", blankIndex: 1, answer: "o", options: ["a", "o", "u", "e"]),
        VowelGardenRound(word: "fish", blankIndex: 1, answer: "i", options: ["a", "i", "u", "o"]),
        VowelGardenRound(word: "duck", blankIndex: 1, answer: "u", options: ["a", "u", "e", "i"])
    ]

    @State private var currentRoundIndex = 0
    @State private var feedback: VowelGardenFeedback? = nil
    @State private var isLocked = false

    private var currentRound: VowelGardenRound {
        rounds[currentRoundIndex]
    }

    var body: some View {
        ZStack {
            BeginningSoundsBackgroundLayer()

            VStack(spacing: 18) {
                Spacer().frame(height: 26)

                Text("Vowel Garden")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Pick the missing vowel in the word")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)

                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 2)
                        )

                    VStack(spacing: 14) {
                        let displayWord: String = {
                            let index = currentRound.word.index(currentRound.word.startIndex, offsetBy: currentRound.blankIndex)
                            let nextIndex = currentRound.word.index(after: index)
                            return currentRound.word.replacingCharacters(in: index..<nextIndex, with: "?")
                        }()

                        Text(displayWord.uppercased())
                            .font(.system(size: 46, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)

                        Text("What vowel fits?")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(24)
                }
                .frame(maxWidth: 280, minHeight: 170)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(currentRound.options, id: \.self) { option in
                        Button {
                            handleSelection(option)
                        } label: {
                            Text(option.uppercased())
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 74)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color.white.opacity(0.18))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .stroke(Color.white.opacity(0.28), lineWidth: 2)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(isLocked)
                    }
                }
                .padding(.horizontal, 24)

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
    }

    private func handleSelection(_ selection: String) {
        guard !isLocked else { return }
        isLocked = true

        if selection == currentRound.answer {
            feedback = .success
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if currentRoundIndex < rounds.count - 1 {
                    currentRoundIndex += 1
                } else {
                    currentRoundIndex = 0
                }
                feedback = nil
                isLocked = false
            }
        } else {
            feedback = .tryAgain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                feedback = nil
                isLocked = false
            }
        }
    }
}

private struct VowelGardenRound {
    let word: String
    let blankIndex: Int
    let answer: String
    let options: [String]
}

private enum VowelGardenFeedback {
    case success
    case tryAgain

    var message: String {
        switch self {
        case .success:
            return "You found the vowel!"
        case .tryAgain:
            return "Try another vowel"
        }
    }
}

#Preview {
    VowelGardenGame()
}
