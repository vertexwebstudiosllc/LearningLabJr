import SwiftUI

struct BeginningSoundsGame: View {
    @State private var currentRound = BeginningSoundRound.makeNew()
    @State private var showFeedback: BeginningSoundFeedback? = nil
    @State private var isInputLocked = false

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack {
            BeginningSoundsBackgroundLayer()

            VStack(spacing: 20) {
                Spacer().frame(height: 20)

                Text("Beginning Sounds")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)

                Text("Tap the letter that starts the word")
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)

                VStack(spacing: 14) {
                    Text(currentRound.word)
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.white.opacity(0.24))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 2)
                                )
                        )

                    Image(systemName: currentRound.symbolName)
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Circle().fill(Color.white.opacity(0.2)))
                }

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(currentRound.options) { option in
                        Button {
                            handleSelection(option)
                        } label: {
                            LetterChoiceCard(option: option)
                        }
                        .buttonStyle(.plain)
                        .disabled(isInputLocked)
                    }
                }
                .padding(.horizontal, 6)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)

            if let feedback = showFeedback {
                FeedbackBadge(type: feedback)
            }
        }
    }

    private func handleSelection(_ option: LetterChoice) {
        guard !isInputLocked else { return }
        isInputLocked = true

        if option.letter == currentRound.answer.letter {
            showFeedback = .success
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                currentRound = BeginningSoundRound.makeNew()
                showFeedback = nil
                isInputLocked = false
            }
        } else {
            showFeedback = .tryAgain
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showFeedback = nil
                isInputLocked = false
            }
        }
    }
}

private struct LetterChoiceCard: View {
    let option: LetterChoice

    var body: some View {
        VStack(spacing: 10) {
            Image(option.assetName)
                .resizable()
                .scaledToFit()
                .frame(height: 70)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.9))
                )
                .shadow(color: .black.opacity(0.14), radius: 8, x: 0, y: 6)

            VStack(spacing: 2) {
                Text(option.letter.uppercased())
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                Text(option.letter.lowercased())
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.14))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.28), lineWidth: 2)
                )
        )
    }
}

private struct FeedbackBadge: View {
    let type: BeginningSoundFeedback

    var body: some View {
        VStack {
            Image(systemName: type.symbolName)
                .font(.system(size: 52, weight: .bold))
                .foregroundColor(.white)
                .padding(20)
                .background(Circle().fill(type.backgroundColor))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 6)

            Text(type.message)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 8)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.18))
        )
    }
}

private struct BeginningSoundRound {
    let word: String
    let symbolName: String
    let answer: LetterChoice
    let options: [LetterChoice]

    static func makeNew() -> BeginningSoundRound {
        let set = BeginningSoundData.allRounds
        guard let round = set.randomElement() else {
            return BeginningSoundRound(word: "Apple", symbolName: "apple.logo", answer: LetterChoice(letter: "A"), options: [LetterChoice(letter: "A"), LetterChoice(letter: "B"), LetterChoice(letter: "C"), LetterChoice(letter: "D")])
        }

        let options = ([round.answer] + round.distractors).shuffled()
        return BeginningSoundRound(word: round.word, symbolName: round.symbolName, answer: round.answer, options: options)
    }
}

private struct LetterChoice: Identifiable, Hashable {
    let id = UUID()
    let letter: String
    let assetName: String

    init(letter: String) {
        self.letter = letter
        self.assetName = letter
    }
}

private enum BeginningSoundFeedback {
    case success
    case tryAgain

    var symbolName: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .tryAgain:
            return "arrow.counterclockwise.circle.fill"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .success:
            return .green
        case .tryAgain:
            return .orange
        }
    }

    var message: String {
        switch self {
        case .success:
            return "Great job!"
        case .tryAgain:
            return "Try another letter"
        }
    }
}

private enum BeginningSoundData {
    static let allRounds: [BeginningSoundRoundData] = [
        BeginningSoundRoundData(word: "Apple", symbolName: "apple.logo", answer: LetterChoice(letter: "A"), distractors: [LetterChoice(letter: "B"), LetterChoice(letter: "C"), LetterChoice(letter: "D")]),
        BeginningSoundRoundData(word: "Ball", symbolName: "basketball.fill", answer: LetterChoice(letter: "B"), distractors: [LetterChoice(letter: "A"), LetterChoice(letter: "C"), LetterChoice(letter: "D")]),
        BeginningSoundRoundData(word: "Cat", symbolName: "cat.fill", answer: LetterChoice(letter: "C"), distractors: [LetterChoice(letter: "A"), LetterChoice(letter: "B"), LetterChoice(letter: "D")]),
        BeginningSoundRoundData(word: "Dog", symbolName: "dog.fill", answer: LetterChoice(letter: "D"), distractors: [LetterChoice(letter: "A"), LetterChoice(letter: "B"), LetterChoice(letter: "C")]),
        BeginningSoundRoundData(word: "Elephant", symbolName: "tortoise.fill", answer: LetterChoice(letter: "E"), distractors: [LetterChoice(letter: "A"), LetterChoice(letter: "F"), LetterChoice(letter: "G")]),
        BeginningSoundRoundData(word: "Fish", symbolName: "fish.fill", answer: LetterChoice(letter: "F"), distractors: [LetterChoice(letter: "A"), LetterChoice(letter: "B"), LetterChoice(letter: "C")]),
        BeginningSoundRoundData(word: "Goat", symbolName: "hare.fill", answer: LetterChoice(letter: "G"), distractors: [LetterChoice(letter: "E"), LetterChoice(letter: "F"), LetterChoice(letter: "H")]),
        BeginningSoundRoundData(word: "Hat", symbolName: "graduationcap.fill", answer: LetterChoice(letter: "H"), distractors: [LetterChoice(letter: "G"), LetterChoice(letter: "I"), LetterChoice(letter: "J")]),
        BeginningSoundRoundData(word: "Ice Cream", symbolName: "cup.and.saucer.fill", answer: LetterChoice(letter: "I"), distractors: [LetterChoice(letter: "H"), LetterChoice(letter: "J"), LetterChoice(letter: "K")]),
        BeginningSoundRoundData(word: "Jump", symbolName: "figure.walk", answer: LetterChoice(letter: "J"), distractors: [LetterChoice(letter: "I"), LetterChoice(letter: "K"), LetterChoice(letter: "L")])
    ]
}

private struct BeginningSoundRoundData {
    let word: String
    let symbolName: String
    let answer: LetterChoice
    let distractors: [LetterChoice]
}

struct BeginningSoundsBackgroundLayer: View {
    var body: some View {
        GeometryReader { proxy in
            let totalHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom

            ZStack(alignment: .center) {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.78, blue: 0.42),
                        Color(red: 1.0, green: 0.68, blue: 0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(.all)

                Image("learningLabBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: totalHeight)
                    .clipped()
                    .ignoresSafeArea(.all)

                Image("PlayfulBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: totalHeight)
                    .clipped()
                    .ignoresSafeArea(.all)
            }
        }
    }
}

#Preview {
    BeginningSoundsGame()
}
