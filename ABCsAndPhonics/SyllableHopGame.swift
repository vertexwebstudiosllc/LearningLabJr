import SwiftUI

struct SyllableHopGame: View {
    private let rounds: [SyllableHopRound] = [
        SyllableHopRound(word: "cow", answer: 1, options: [1, 2, 3]),
        SyllableHopRound(word: "rabbit", answer: 2, options: [1, 2, 3]),
        SyllableHopRound(word: "penguin", answer: 2, options: [1, 2, 3]),
        SyllableHopRound(word: "octopus", answer: 3, options: [1, 2, 3])
    ]

    @State private var currentRoundIndex = 0
    @State private var feedback: SyllableHopFeedback? = nil
    @State private var isLocked = false

    private var currentRound: SyllableHopRound {
        rounds[currentRoundIndex]
    }

    var body: some View {
        ZStack {
            BeginningSoundsBackgroundLayer()

            VStack(spacing: 18) {
                Spacer().frame(height: 26)

                Text("Syllable Hop")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("How many beats does the word have?")
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

                    VStack(spacing: 12) {
                        Text(currentRound.word.uppercased())
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)

                        Text("Tap the number of syllables")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(24)
                }
                .frame(maxWidth: 290, minHeight: 170)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(currentRound.options, id: \.self) { option in
                        Button {
                            handleSelection(option)
                        } label: {
                            Text("\(option) beat")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 72)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.white.opacity(0.18))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
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

    private func handleSelection(_ selection: Int) {
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

private struct SyllableHopRound {
    let word: String
    let answer: Int
    let options: [Int]
}

private enum SyllableHopFeedback {
    case success
    case tryAgain

    var message: String {
        switch self {
        case .success:
            return "That’s right!"
        case .tryAgain:
            return "Try again"
        }
    }
}

#Preview {
    SyllableHopGame()
}
