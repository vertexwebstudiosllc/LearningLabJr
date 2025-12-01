//
//  LetterMatch.swift
//  LearningLabJr
//
//  Created by Codex on 12/10/25.
//

import SwiftUI
import AVFoundation

struct LetterMatch: View {
    @State private var currentRound = Round.makeNew()
    @State private var showFeedback: FeedbackType? = nil
    @State private var animateFeedback = false
    @State private var isInputLocked = false
    @State private var successPlayer: AVAudioPlayer?

    private let gridItems = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ZStack {
            // Playful gradient background
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.9, blue: 0.7),
                    Color(red: 1.0, green: 0.75, blue: 0.6),
                    Color(red: 1.0, green: 0.6, blue: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                // Big target letter
                Text(currentRound.targetLetter)
                    .font(.system(size: 96, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.8))
                            .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 6)
                    )

                // Word hint (optional)
                Text("Find the picture that starts with “\(currentRound.targetLetter)”")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                // 2×2 grid of choices
                LazyVGrid(columns: gridItems, spacing: 16) {
                    ForEach(currentRound.options) { item in
                        ChoiceButton(item: item, isLocked: isInputLocked) {
                            handleSelection(item)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }

            // Feedback overlay
            if let feedback = showFeedback {
                FeedbackView(type: feedback, animate: animateFeedback)
            }
        }
        .onAppear {
            prepareSuccessSound()
        }
    }

    // MARK: - Logic

    private func handleSelection(_ item: LetterItem) {
        guard !isInputLocked else { return }
        let isCorrect = item.letter == currentRound.targetLetter
        isInputLocked = true

        if isCorrect {
            showFeedback = .success
            animateFeedback = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    animateFeedback = true
                }
            }
            playSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                nextRound()
            }
        } else {
            showFeedback = .failure
            animateFeedback = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    animateFeedback = true
                }
            }
            // Allow retry after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showFeedback = nil
                animateFeedback = false
                isInputLocked = false
            }
        }
    }

    private func nextRound() {
        currentRound = Round.makeNew()
        showFeedback = nil
        animateFeedback = false
        isInputLocked = false
    }

    // MARK: - Sound

    private func prepareSuccessSound() {
        guard let url = Bundle.main.url(forResource: "SuccessSound", withExtension: "wav") else {
            return
        }
        successPlayer = try? AVAudioPlayer(contentsOf: url)
        successPlayer?.prepareToPlay()
    }

    private func playSuccess() {
        if let player = successPlayer {
            player.currentTime = 0
            player.play()
        } else {
            AudioServicesPlaySystemSound(1110) // fallback system ping
        }
    }
}

// MARK: - Models

struct LetterItem: Identifiable, Hashable {
    let id = UUID()
    let letter: String
    let word: String
    let imageName: String
}

private struct Round {
    let targetLetter: String
    let options: [LetterItem]

    static func makeNew() -> Round {
        let pool = LetterData.allItems
        guard let correct = pool.randomElement() else {
            return Round(targetLetter: "A", options: Array(pool.prefix(4)))
        }
        let other = pool.filter { $0.letter != correct.letter }.shuffled().prefix(3)
        let opts = ([correct] + other).shuffled()
        return Round(targetLetter: correct.letter, options: Array(opts))
    }
}

private enum LetterData {
    static let allItems: [LetterItem] = [
        .init(letter: "A", word: "Apple", imageName: "applelogo"),
        .init(letter: "B", word: "Ball", imageName: "circle.grid.2x1"),
        .init(letter: "C", word: "Cat", imageName: "pawprint.fill"),
        .init(letter: "D", word: "Dog", imageName: "pawprint.circle.fill"),
        .init(letter: "E", word: "Elephant", imageName: "tortoise.fill"),
        .init(letter: "F", word: "Fish", imageName: "fish.fill"),
        .init(letter: "G", word: "Goat", imageName: "hare.fill"),
        .init(letter: "H", word: "Hat", imageName: "graduationcap.fill"),
        .init(letter: "I", word: "IceCream", imageName: "cup.and.saucer.fill"),
        .init(letter: "J", word: "Juice", imageName: "cup.and.saucer"),
        .init(letter: "K", word: "Kite", imageName: "paperplane.fill"),
        .init(letter: "L", word: "Lion", imageName: "l.square.fill"),
        .init(letter: "M", word: "Moon", imageName: "moon.stars.fill"),
        .init(letter: "N", word: "Nest", imageName: "leaf.fill"),
        .init(letter: "O", word: "Orange", imageName: "circle.fill"),
        .init(letter: "P", word: "Pig", imageName: "p.square.fill"),
        .init(letter: "Q", word: "Queen", imageName: "crown.fill"),
        .init(letter: "R", word: "Rainbow", imageName: "cloud.rainbow.half.fill"),
        .init(letter: "S", word: "Sun", imageName: "sun.max.fill"),
        .init(letter: "T", word: "Turtle", imageName: "tortoise.fill"),
        .init(letter: "U", word: "Umbrella", imageName: "umbrella.fill"),
        .init(letter: "V", word: "Violin", imageName: "v.square.fill"),
        .init(letter: "W", word: "Whale", imageName: "water.waves"),
        .init(letter: "X", word: "Xylophone", imageName: "xmark.square.fill"),
        .init(letter: "Y", word: "Yogurt", imageName: "y.square.fill"),
        .init(letter: "Z", word: "Zebra", imageName: "z.square.fill")
    ]
}

// MARK: - Choice Button

private struct ChoiceButton: View {
    let item: LetterItem
    let isLocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            guard !isLocked else { return }
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 90)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 6)

                Text(item.word)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 170)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.blue.opacity(0.35))
            )
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feedback

private enum FeedbackType {
    case success
    case failure

    var symbolName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .failure: return .red
        }
    }
}

private struct FeedbackView: View {
    let type: FeedbackType
    let animate: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
            Image(systemName: type.symbolName)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .foregroundStyle(type.color)
                .shadow(color: type.color.opacity(0.5), radius: 12, x: 0, y: 8)
                .scaleEffect(animate ? 1.0 : 0.4)
                .opacity(animate ? 1.0 : 0.2)
                .animation(.spring(response: 0.45, dampingFraction: 0.6), value: animate)
        }
        .transition(.opacity)
    }
}

#Preview {
    LetterMatch()
}
