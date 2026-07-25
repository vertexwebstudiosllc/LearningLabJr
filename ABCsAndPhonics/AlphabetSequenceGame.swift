import SwiftUI

struct AlphabetSequenceGame: View {
    private let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    @State private var visibleTiles: [LetterWheelTileModel] = []
    @State private var currentIndex = 0
    @State private var promptTargetIndex: Int? = nil
    @State private var options: [String] = []
    @State private var feedback: AlphabetFeedback? = nil
    @State private var isLocked = false
    @State private var pendingPromptIndices: [Int] = []
    @State private var showPrompt = false

    var body: some View {
        ZStack {
            BeginningSoundsBackgroundLayer()

            VStack(spacing: 18) {
                Spacer().frame(height: 20)

                Text("ABC Adventure")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Watch the letters roll, then fill the blank")
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(visibleTiles, id: \.id) { tile in
                                LetterWheelTile(tile: tile, isActive: tile.id == visibleTiles.last?.id)
                                    .id(tile.id)
                            }
                        }
                        .padding(.horizontal, 20)
                        .onChange(of: visibleTiles.count) { _ in
                            if let lastTile = visibleTiles.last {
                                withAnimation(.easeOut(duration: 0.35)) {
                                    proxy.scrollTo(lastTile.id, anchor: .trailing)
                                }
                            }
                        }
                    }
                }

                if showPrompt {
                    VStack(spacing: 12) {
                        Text("What comes next?")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))

                        LetterBadge(letter: "?", isBlank: true)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(options, id: \.self) { option in
                                Button {
                                    handleSelection(option)
                                } label: {
                                    Text(option)
                                        .font(.system(size: 28, weight: .heavy, design: .rounded))
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
                        .padding(.horizontal, 20)
                    }
                } else {
                    VStack(spacing: 12) {
                        Text("Current letter")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))

                        LetterBadge(letter: String(alphabet[currentIndex]), isBlank: false)
                    }
                }

                if let feedback = feedback {
                    Text(feedback.message)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 4)
                }

                Spacer()
            }
            .padding(.bottom, 24)
        }
        .onAppear {
            startGame()
        }
    }

    private func startGame() {
        currentIndex = 0
        showPrompt = false
        feedback = nil
        isLocked = false
        pendingPromptIndices = Array(1..<alphabet.count).shuffled()
        visibleTiles = [LetterWheelTileModel(letter: "A", isBlank: false)]
        advanceAfterDelay()
    }

    private func advanceAfterDelay() {
        guard !isLocked else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            if showPrompt {
                return
            }

            let nextIndex = (currentIndex + 1) % alphabet.count

            if pendingPromptIndices.first == nextIndex {
                pendingPromptIndices.removeFirst()
                if pendingPromptIndices.isEmpty {
                    pendingPromptIndices = Array(1..<alphabet.count).shuffled()
                }
                promptTargetIndex = nextIndex
                showPrompt = true
                setupPromptOptions(for: nextIndex)
            } else {
                currentIndex = nextIndex
                visibleTiles.append(LetterWheelTileModel(letter: String(alphabet[nextIndex]), isBlank: false))
                advanceAfterDelay()
            }
        }
    }

    private func setupPromptOptions(for index: Int) {
        let correct = String(alphabet[index])
        let distractors = alphabet.enumerated()
            .filter { $0.offset != index }
            .map { String($0.element) }
            .shuffled()
            .prefix(3)

        options = ([correct] + distractors).shuffled()
    }

    private func handleSelection(_ selection: String) {
        guard !isLocked else { return }
        isLocked = true

        if selection == String(alphabet[promptTargetIndex ?? currentIndex]) {
            feedback = .success
            if let targetIndex = promptTargetIndex {
                currentIndex = targetIndex
                visibleTiles.append(LetterWheelTileModel(letter: String(alphabet[targetIndex]), isBlank: false))
            }
            showPrompt = false
            promptTargetIndex = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                isLocked = false
                advanceAfterDelay()
            }
        } else {
            feedback = .tryAgain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                feedback = nil
                isLocked = false
            }
        }
    }
}

private struct LetterWheelTile: View {
    let tile: LetterWheelTileModel
    let isActive: Bool

    var body: some View {
        VStack(spacing: 6) {
            LetterBadge(letter: tile.isBlank ? "?" : tile.letter, isBlank: tile.isBlank)
                .scaleEffect(isActive ? 1.08 : 1.0)

            Text(tile.isBlank ? "blank" : tile.letter)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(isActive ? 0.24 : 0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.26), lineWidth: 2)
                )
        )
    }
}

private struct LetterBadge: View {
    let letter: String
    let isBlank: Bool

    var body: some View {
        Group {
            if isBlank {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Image(letter)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 62, height: 62)
            }
        }
        .padding(16)
        .background(
            Circle()
                .fill(Color.white.opacity(isBlank ? 0.24 : 0.18))
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
        )
    }
}

private struct LetterWheelTileModel: Identifiable, Hashable {
    let id = UUID()
    let letter: String
    let isBlank: Bool
}

private enum AlphabetFeedback {
    case success
    case tryAgain

    var message: String {
        switch self {
        case .success:
            return "Great job!"
        case .tryAgain:
            return "Try again"
        }
    }
}

#Preview {
    AlphabetSequenceGame()
}
