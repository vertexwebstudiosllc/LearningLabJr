//
//  CountingMenu.swift
//  LearningLabJr
//
//  Created by Matthew Teitelman on 12/10/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct CountingMenu: View {
    private let games = CountingGame.allGames

    var body: some View {
        ZStack {
            CountingBackgroundLayer()

            GeometryReader { geo in
                let padding: CGFloat = 20
                let spacing: CGFloat = 12
                let columnCount = min(3, max(1, Int((geo.size.width - padding * 2) / 104)))
                let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 20)

                        Image("learningLabLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 198, maxHeight: 198)
                            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
                            .offset(y: -8)

                        Image("learningLabKids")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 490, maxHeight: 490)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)
                            .padding(.top, -170)

                        LazyVGrid(columns: columns, spacing: spacing) {
                            ForEach(games) { game in
                                NavigationLink {
                                    game.destination
                                } label: {
                                    CountingGameTile(game: game)
                                        .aspectRatio(1, contentMode: .fit)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, padding)
                        .padding(.top, -145)
                        .padding(.bottom, 48)
                    }
                    .frame(minHeight: geo.size.height, alignment: .top)
                }
                .scrollBounceBehavior(.basedOnSize)
                .ignoresSafeArea(edges: .top)
            }
        }
    }
}

private struct CountingGame: Identifiable {
    enum Kind {
        case pileMatch, touchCount, addition, subtraction, missingNumber, compare
        case tenFrame, numberOrder, numberBonds, dominoes, numberLine, balance
    }

    let kind: Kind
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]
    var id: String { title }

    @ViewBuilder var destination: some View {
        switch kind {
        case .pileMatch: PileMatchGame()
        case .touchCount: TouchCountGame()
        case .addition: AdditionGame()
        case .subtraction: SubtractionGame()
        case .missingNumber: MissingNumberGame()
        case .compare: CompareGame()
        case .tenFrame: TenFrameGame()
        case .numberOrder: NumberOrderGame()
        case .numberBonds: NumberBondGame()
        case .dominoes: DominoGame()
        case .numberLine: NumberLineGame()
        case .balance: BalanceGame()
        }
    }

    static let allGames: [CountingGame] = [
        .init(kind: .pileMatch, title: "Pile Match", subtitle: "Drag numbers to two object piles.", icon: "hand.draw.fill", colors: [.orange, .pink]),
        .init(kind: .touchCount, title: "Touch & Count", subtitle: "Touch every critter as you count.", icon: "hand.tap.fill", colors: [.blue, .cyan]),
        .init(kind: .addition, title: "Addition Picnic", subtitle: "Add two groups and choose the sum.", icon: "plus.circle.fill", colors: [.green, .mint]),
        .init(kind: .subtraction, title: "Dino Dash", subtitle: "Tap dinos away, then count.", icon: "minus.circle.fill", colors: [.purple, .indigo]),
        .init(kind: .missingNumber, title: "Treasure Trail", subtitle: "Find the number missing in line.", icon: "map.fill", colors: [.yellow, .orange]),
        .init(kind: .compare, title: "More or Less", subtitle: "Choose >, <, or = for two groups.", icon: "scale.3d", colors: [.teal, .blue]),
        .init(kind: .tenFrame, title: "Ten-Frame Garden", subtitle: "Plant the requested number.", icon: "square.grid.3x3.fill", colors: [.pink, .purple]),
        .init(kind: .numberOrder, title: "Train Order", subtitle: "Build a train from least to greatest.", icon: "tram.fill", colors: [.indigo, .teal]),
        .init(kind: .numberBonds, title: "Make the Number", subtitle: "Pick two parts that make a whole.", icon: "link.circle.fill", colors: [.red, .orange]),
        .init(kind: .dominoes, title: "Domino Detective", subtitle: "Count both sides and find the total.", icon: "die.face.5.fill", colors: [.brown, .orange]),
        .init(kind: .numberLine, title: "Frog Number Hops", subtitle: "Hop forward to solve addition.", icon: "arrow.right.circle.fill", colors: [.cyan, .blue]),
        .init(kind: .balance, title: "Balance the Scale", subtitle: "Make both sides equal.", icon: "equal.circle.fill", colors: [.green, .yellow])
    ]
}

private struct CountingGameTile: View {
    let game: CountingGame

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(LinearGradient(colors: game.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: game.icon)
                        .font(.system(size: 25, weight: .bold))
                    Text(game.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .lineLimit(2)
                    Text(game.subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .opacity(0.9)
                        .lineLimit(3)
                }
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(8)
            }
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
    }
}

private struct GameShell<Content: View>: View {
    let title: String
    let directions: String
    let colors: [Color]
    let content: Content
    @Environment(\.dismiss) private var dismiss

    init(title: String, directions: String, colors: [Color], @ViewBuilder content: () -> Content) {
        self.title = title
        self.directions = directions
        self.colors = colors
        self.content = content()
    }

    var body: some View {
        ZStack {
            CountingBackgroundLayer()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .frame(width: 42, height: 42)
                                .background(.white.opacity(0.2), in: Circle())
                        }
                        Spacer()
                    }

                    Text(title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    Text(directions)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .accessibilityLabel("How to play. \(directions)")

                    content
                        .padding(18)
                        .frame(maxWidth: 620)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.white.opacity(0.16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(.white.opacity(0.25), lineWidth: 2)
                                )
                        )
                }
                .foregroundStyle(.white)
                .padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
}

private struct FeedbackBanner: View {
    let success: Bool?
    var correctMessage = "That’s correct! Great thinking."
    var retryMessage = "Not quite. Take another look and try again."
    var onCorrect: () -> Void = {}

    var body: some View {
        if let success {
            Label(success ? correctMessage : retryMessage, systemImage: success ? "star.fill" : "arrow.counterclockwise")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(success ? Color.yellow : Color.white)
                .multilineTextAlignment(.center)
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel(success ? correctMessage : retryMessage)
                .task(id: success) {
                    guard success else { return }
                    try? await Task.sleep(for: .seconds(1.35))
                    guard !Task.isCancelled else { return }
                    onCorrect()
                }
        }
    }
}

private struct RoundCounter: View {
    let round: Int
    let total: Int

    var body: some View {
        VStack(spacing: 7) {
            Text("Challenge \(round + 1) of \(total)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.2))
                    Capsule()
                        .fill(.white.opacity(0.9))
                        .frame(width: proxy.size.width * CGFloat(round + 1) / CGFloat(total))
                }
            }
            .frame(height: 7)
        }
        .frame(maxWidth: 260)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Challenge \(round + 1) of \(total)")
    }
}

private struct NumberButton: View {
    let number: Int
    var selected = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(selected ? .white : .indigo)
                .frame(minWidth: 58, minHeight: 58)
                .background(selected ? Color.indigo : Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(number)")
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

// MARK: - 1. Match two number cards to two distinct piles

private struct PileMatchGame: View {
    @State private var round = 0
    @State private var answers: [Int?] = [nil, nil]
    @State private var selectedCard: Int?
    @State private var feedback: Bool?
    private let rounds = [
        [(emoji: "🍎", count: 3), (emoji: "⭐️", count: 5)],
        [(emoji: "🐠", count: 4), (emoji: "🦋", count: 2)],
        [(emoji: "🚗", count: 6), (emoji: "⚽️", count: 3)],
        [(emoji: "🍪", count: 2), (emoji: "🎈", count: 7)],
        [(emoji: "🐞", count: 5), (emoji: "🌼", count: 4)]
    ]
    private var piles: [(emoji: String, count: Int)] { rounds[round] }
    private var cards: [Int] { Array(piles.map(\.count).reversed()) }

    var body: some View {
        GameShell(title: "Pile Match", directions: "Count both piles. Drag each number card to the pile it matches.", colors: [.orange, .pink]) {
            VStack(spacing: 22) {
                RoundCounter(round: round, total: rounds.count)
                HStack(alignment: .top, spacing: 16) {
                    ForEach(piles.indices, id: \.self) { index in
                        VStack(spacing: 10) {
                            Text(String(repeating: piles[index].emoji, count: piles[index].count))
                                .font(.system(size: 36))
                                .multilineTextAlignment(.center)
                                .accessibilityLabel("\(piles[index].count) items")
                            Text(answers[index].map(String.init) ?? "Drop here")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 62)
                                .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
                                .onDrop(of: [.text], isTargeted: nil) { providers in
                                    loadNumber(from: providers) { number in
                                        place(number, in: index)
                                    }
                                    return true
                                }
                                .onTapGesture {
                                    guard let selectedCard else { return }
                                    place(selectedCard, in: index)
                                }
                                .accessibilityLabel("Pile \(index + 1), \(answers[index].map(String.init) ?? "empty answer")")
                                .accessibilityHint(selectedCard == nil ? "Select a number card first" : "Double tap to place \(selectedCard!) here")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                HStack(spacing: 16) {
                    ForEach(cards, id: \.self) { number in
                        Text("\(number)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(selectedCard == number ? .white : .indigo)
                            .frame(width: 68, height: 68)
                            .background(selectedCard == number ? Color.indigo : .white, in: Circle())
                            .onDrag { NSItemProvider(object: NSString(string: "\(number)")) }
                            .onTapGesture {
                                selectedCard = selectedCard == number ? nil : number
                                feedback = nil
                            }
                            .accessibilityLabel("Number \(number). Drag to a pile.")
                            .accessibilityAddTraits(selectedCard == number ? [.isSelected] : [])
                    }
                }
                FeedbackBanner(
                    success: feedback,
                    correctMessage: "Both numbers match their piles!",
                    retryMessage: "One number is misplaced. Count each pile and move the cards.",
                    onCorrect: nextRound
                )
                Button("Clear My Answers") {
                    answers = [nil, nil]
                    selectedCard = nil
                    feedback = nil
                }
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private func nextRound() {
        round = (round + 1) % rounds.count
        answers = [nil, nil]
        selectedCard = nil
        feedback = nil
    }

    private func place(_ number: Int, in index: Int) {
        if let previousIndex = answers.firstIndex(where: { $0 == number }) {
            answers[previousIndex] = nil
        }
        answers[index] = number
        selectedCard = nil
        feedback = answers.allSatisfy { $0 != nil }
            ? answers[0] == piles[0].count && answers[1] == piles[1].count
            : nil
    }
}

private func loadNumber(from providers: [NSItemProvider], completion: @escaping (Int) -> Void) {
    guard let provider = providers.first else { return }
    _ = provider.loadObject(ofClass: NSString.self) { object, _ in
        guard let string = object as? String, let number = Int(string) else { return }
        DispatchQueue.main.async { completion(number) }
    }
}

// MARK: - 2. Touch every object while counting aloud

private struct TouchCountGame: View {
    @State private var round = 0
    @State private var touched: [Int] = []
    @State private var feedback: Bool?
    private let counts = [6, 4, 7, 5, 8]
    private let emojis = [
        ["🐶", "🐱", "🐥"], ["🐸", "🐞", "🐝"], ["🐙", "🐬", "🐳"],
        ["🦊", "🐼", "🐨"], ["🦀", "🐢", "🐡"]
    ]
    private var count: Int { counts[round] }
    private var choices: [Int] {
        [[count, count + 1, count - 1], [count - 1, count + 1, count], [count + 1, count, count - 1]][round % 3]
    }

    var body: some View {
        GameShell(title: "Touch & Count", directions: "Touch each animal once. Then choose how many you counted.", colors: [.blue, .cyan]) {
            VStack(spacing: 20) {
                RoundCounter(round: round, total: counts.count)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 14) {
                    ForEach(0..<count, id: \.self) { index in
                        Button {
                            guard !touched.contains(index) else { return }
                            touched.append(index)
                            feedback = nil
                        } label: {
                            ZStack(alignment: .topTrailing) {
                            Text(emojis[round][index % 3]).font(.system(size: 50))
                                if touched.contains(index) {
                                    Text("\(touched.firstIndex(of: index)! + 1)")
                                        .font(.caption.bold())
                                        .frame(width: 25, height: 25)
                                        .background(.green, in: Circle())
                                }
                            }
                            .opacity(touched.contains(index) ? 0.55 : 1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            touched.contains(index)
                                ? "\(emojis[round][index % 3]), counted \(touched.firstIndex(of: index)! + 1)"
                                : "\(emojis[round][index % 3]), not counted"
                        )
                        .accessibilityHint("Double tap to count this animal")
                    }
                }
                HStack {
                    ForEach(choices, id: \.self) { value in
                        NumberButton(number: value) {
                            feedback = touched.count == count && value == count
                        }
                    }
                }
                FeedbackBanner(
                    success: feedback,
                    correctMessage: "You counted every animal once!",
                    retryMessage: touched.count < count
                        ? "Touch every animal before choosing the total."
                        : "Count the numbered animals once more.",
                    onCorrect: nextRound
                )
                Button("Start Over") { touched.removeAll(); feedback = nil }
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private func nextRound() {
        round = (round + 1) % counts.count
        touched.removeAll()
        feedback = nil
    }
}

// MARK: - 3. Visual addition with a multiple-choice sum

private struct AdditionGame: View {
    @State private var round = 0
    @State private var feedback: Bool?
    private let rounds = [
        (emoji: "🍓", left: 2, right: 3),
        (emoji: "🥕", left: 4, right: 2),
        (emoji: "🧁", left: 1, right: 3),
        (emoji: "🍊", left: 5, right: 2),
        (emoji: "🥨", left: 3, right: 3)
    ]
    private var question: (emoji: String, left: Int, right: Int) { rounds[round] }
    private var total: Int { question.left + question.right }
    private var choices: [Int] {
        let values = [max(0, total - 1), total, total + 1]
        return [values, [values[1], values[2], values[0]], [values[2], values[0], values[1]]][round % 3]
    }

    var body: some View {
        GameShell(title: "Addition Picnic", directions: "Count each group, then put them together. What is \(question.left) plus \(question.right)?", colors: [.green, .mint]) {
            VStack(spacing: 22) {
                RoundCounter(round: round, total: rounds.count)
                HStack(spacing: 18) {
                    ObjectGroup(emoji: question.emoji, count: question.left)
                    Text("+").font(.largeTitle.bold())
                    ObjectGroup(emoji: question.emoji, count: question.right)
                }
                Text("\(question.left) + \(question.right) = ?").font(.system(size: 32, weight: .bold, design: .rounded))
                HStack {
                    ForEach(choices, id: \.self) { value in
                        NumberButton(number: value) { feedback = value == total }
                    }
                }
                FeedbackBanner(
                    success: feedback,
                    correctMessage: "\(question.left) plus \(question.right) equals \(total)!",
                    retryMessage: "Count both groups together, starting with one.",
                    onCorrect: nextRound
                )
            }
        }
    }

    private func nextRound() {
        round = (round + 1) % rounds.count
        feedback = nil
    }
}

// MARK: - 4. Subtraction by physically tapping objects away

private struct SubtractionGame: View {
    @State private var round = 0
    @State private var removed: Set<Int> = []
    @State private var feedback: Bool?
    private let rounds = [
        (emoji: "🦕", start: 5, takeAway: 2),
        (emoji: "🐇", start: 6, takeAway: 2),
        (emoji: "🚀", start: 4, takeAway: 3),
        (emoji: "🐧", start: 7, takeAway: 3),
        (emoji: "🍪", start: 8, takeAway: 2)
    ]
    private var question: (emoji: String, start: Int, takeAway: Int) { rounds[round] }
    private var answer: Int { question.start - question.takeAway }
    private var choices: [Int] {
        let values = [max(0, answer - 1), answer, answer + 1]
        return [values, [values[2], values[0], values[1]], [values[1], values[2], values[0]]][round % 3]
    }

    var body: some View {
        GameShell(title: "Dino Dash", directions: "Tap \(question.takeAway) objects to make them dash away. How many remain?", colors: [.purple, .indigo]) {
            VStack(spacing: 22) {
                RoundCounter(round: round, total: rounds.count)
                HStack {
                    ForEach(0..<question.start, id: \.self) { index in
                        Button {
                            if removed.contains(index) {
                                removed.remove(index)
                            } else if removed.count < question.takeAway {
                                removed.insert(index)
                            }
                            feedback = nil
                        } label: {
                            Text(question.emoji)
                                .font(.system(size: 45))
                                .opacity(removed.contains(index) ? 0.12 : 1)
                                .offset(y: removed.contains(index) ? -18 : 0)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(removed.contains(index) ? "Object \(index + 1), taken away" : "Object \(index + 1)")
                        .accessibilityHint("Double tap to take away or restore this object")
                    }
                }
                Text("\(question.start) − \(removed.count) = ?")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                HStack {
                    ForEach(choices, id: \.self) { value in
                        NumberButton(number: value) { feedback = removed.count == question.takeAway && value == answer }
                    }
                }
                FeedbackBanner(
                    success: feedback,
                    correctMessage: "\(question.start) take away \(question.takeAway) leaves \(answer)!",
                    retryMessage: removed.count != question.takeAway
                        ? "Take away exactly \(question.takeAway) objects first."
                        : "Count only the objects that are still here.",
                    onCorrect: nextRound
                )
                Button("Bring Them Back") { removed.removeAll(); feedback = nil }
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private func nextRound() {
        round = (round + 1) % rounds.count
        removed.removeAll()
        feedback = nil
    }
}

// MARK: - 5. Missing number in a sequence

private struct MissingNumberGame: View {
    @State private var round = 0
    @State private var answer: Int?
    private let sequences = [
        (values: ["2", "3", "?", "5", "6"], answer: 4),
        (values: ["5", "?", "7", "8", "9"], answer: 6),
        (values: ["7", "8", "9", "?", "11"], answer: 10),
        (values: ["?", "13", "14", "15", "16"], answer: 12),
        (values: ["16", "17", "?", "19", "20"], answer: 18)
    ]
    private var question: (values: [String], answer: Int) { sequences[round] }
    private var choices: [Int] {
        let values = [question.answer - 1, question.answer, question.answer + 1]
        return [values, [values[1], values[2], values[0]], [values[2], values[0], values[1]]][round % 3]
    }

    var body: some View {
        GameShell(title: "Treasure Trail", directions: "Which stepping-stone number is missing?", colors: [.yellow, .orange]) {
            VStack(spacing: 24) {
                RoundCounter(round: round, total: sequences.count)
                HStack(spacing: 8) {
                    ForEach(question.values, id: \.self) { value in
                        Text(value)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .frame(width: 52, height: 52)
                            .background(value == "?" ? Color.orange : .white.opacity(0.22), in: Circle())
                    }
                }
                HStack {
                    ForEach(choices, id: \.self) { value in
                        NumberButton(number: value) { answer = value }
                    }
                }
                FeedbackBanner(
                    success: answer.map { $0 == question.answer },
                    correctMessage: "\(question.answer) completes the counting pattern!",
                    retryMessage: "Say the numbers in order and listen for the missing one.",
                    onCorrect: nextRound
                )
            }
        }
    }

    private func nextRound() {
        round = (round + 1) % sequences.count
        answer = nil
    }
}

// MARK: - 6. Compare two visible quantities with symbols

private struct CompareGame: View {
    @State private var round = 0
    @State private var answer: String?
    private let rounds = [
        (emoji: "🎈", left: 4, right: 2),
        (emoji: "🐚", left: 3, right: 5),
        (emoji: "🍪", left: 4, right: 4),
        (emoji: "⭐️", left: 2, right: 6),
        (emoji: "🐞", left: 7, right: 3)
    ]
    private var question: (emoji: String, left: Int, right: Int) { rounds[round] }
    private var correctSymbol: String {
        question.left == question.right ? "=" : (question.left < question.right ? "<" : ">")
    }

    var body: some View {
        GameShell(title: "More or Less", directions: "Choose the symbol that makes the number sentence true.", colors: [.teal, .blue]) {
            VStack(spacing: 22) {
                RoundCounter(round: round, total: rounds.count)
                HStack(spacing: 18) {
                    ObjectGroup(emoji: question.emoji, count: question.left)
                    Text(answer ?? "?")
                        .font(.system(size: 40, weight: .black))
                        .frame(width: 58)
                    ObjectGroup(emoji: question.emoji, count: question.right)
                }
                HStack(spacing: 14) {
                    ForEach(["<", "=", ">"], id: \.self) { symbol in
                        Button(symbol) { answer = symbol }
                            .font(.system(size: 30, weight: .black))
                            .frame(width: 68, height: 58)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16))
                            .foregroundStyle(.indigo)
                            .accessibilityLabel(symbol == "<" ? "less than" : symbol == ">" ? "greater than" : "equal to")
                    }
                }
                FeedbackBanner(
                    success: answer.map { $0 == correctSymbol },
                    correctMessage: correctSymbol == "=" ? "Both groups are equal!" : "Yes—the \(correctSymbol == ">" ? "left" : "right") group has more.",
                    retryMessage: "Count each group, then point the open side toward the group with more.",
                    onCorrect: nextRound
                )
            }
        }
    }

    private func nextRound() {
        round = (round + 1) % rounds.count
        answer = nil
    }
}

// MARK: - 7. Construct a quantity in a ten-frame

private struct TenFrameGame: View {
    @State private var round = 0
    @State private var planted: Set<Int> = []
    @State private var feedback: Bool?
    private let targets = [7, 4, 9, 5, 10]
    private var target: Int { targets[round] }

    var body: some View {
        GameShell(title: "Ten-Frame Garden", directions: "Plant exactly \(target) flowers in the ten-frame.", colors: [.pink, .purple]) {
            VStack(spacing: 20) {
                RoundCounter(round: round, total: targets.count)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5), spacing: 6) {
                    ForEach(0..<10, id: \.self) { index in
                        Button {
                            if planted.contains(index) { planted.remove(index) } else { planted.insert(index) }
                            feedback = nil
                        } label: {
                            Text(planted.contains(index) ? "🌼" : "")
                                .font(.system(size: 30))
                                .frame(maxWidth: .infinity, minHeight: 58)
                                .background(.white.opacity(0.24), in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(planted.contains(index) ? "Space \(index + 1), flower planted" : "Space \(index + 1), empty")
                        .accessibilityHint("Double tap to plant or remove a flower")
                    }
                }
                Text("\(planted.count) flowers").font(.title2.bold())
                Button("Check My Garden") { feedback = planted.count == target }
                    .buttonStyle(.borderedProminent)
                FeedbackBanner(
                    success: feedback,
                    correctMessage: "Your ten-frame shows exactly \(target)!",
                    retryMessage: planted.count < target
                        ? "Plant \(target - planted.count) more \(target - planted.count == 1 ? "flower" : "flowers")."
                        : "Remove \(planted.count - target) \(planted.count - target == 1 ? "flower" : "flowers").",
                    onCorrect: nextRound
                )
            }
        }
    }

    private func nextRound() {
        round = (round + 1) % targets.count
        planted.removeAll()
        feedback = nil
    }
}

// MARK: - 8. Select scrambled values from least to greatest

private struct NumberOrderGame: View {
    @State private var round = 0
    @State private var ordered: [Int] = []
    @State private var feedback: Bool?
    private let rounds = [
        [4, 1, 3, 2], [7, 5, 8, 6], [10, 8, 11, 9],
        [14, 12, 15, 13], [18, 20, 17, 19]
    ]
    private var numbers: [Int] { rounds[round] }

    var body: some View {
        GameShell(title: "Train Order", directions: "Tap the train cars from the smallest number to the biggest.", colors: [.indigo, .teal]) {
            VStack(spacing: 22) {
                RoundCounter(round: round, total: rounds.count)
                HStack {
                    ForEach(numbers, id: \.self) { value in
                        NumberButton(number: value, selected: ordered.contains(value)) {
                            guard !ordered.contains(value) else { return }
                            let expected = numbers.sorted()[ordered.count]
                            guard value == expected else {
                                feedback = false
                                return
                            }
                            ordered.append(value)
                            feedback = ordered.count == numbers.count ? true : nil
                        }
                    }
                }
                HStack(spacing: 4) {
                    Image(systemName: "tram.fill").font(.title)
                    ForEach(ordered, id: \.self) { Text("\($0)").frame(width: 42, height: 42).background(.orange, in: RoundedRectangle(cornerRadius: 8)) }
                }
                .frame(minHeight: 46)
                FeedbackBanner(
                    success: feedback,
                    correctMessage: "The train is in order from least to greatest!",
                    retryMessage: "Find the smallest number that has not joined the train yet.",
                    onCorrect: nextRound
                )
                Button("Mix Them Up") { ordered.removeAll(); feedback = nil }
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private func nextRound() {
        round = (round + 1) % rounds.count
        ordered.removeAll()
        feedback = nil
    }
}

// MARK: - 9. Choose an addend pair for a target whole

private struct NumberBondGame: View {
    @State private var round = 0
    @State private var selected: Int?
    private let rounds = [
        (whole: 7, part: 3), (whole: 9, part: 4), (whole: 6, part: 2),
        (whole: 10, part: 6), (whole: 8, part: 1)
    ]
    private var question: (whole: Int, part: Int) { rounds[round] }
    private var missing: Int { question.whole - question.part }
    private var choices: [Int] {
        let values = [max(0, missing - 1), missing, missing + 1]
        return [values, [values[2], values[0], values[1]], [values[1], values[2], values[0]]][round % 3]
    }

    var body: some View {
        GameShell(title: "Make the Number", directions: "The whole is \(question.whole). One part is \(question.part). Choose the other part.", colors: [.red, .orange]) {
            VStack(spacing: 20) {
                RoundCounter(round: round, total: rounds.count)
                Text("\(question.whole)").font(.system(size: 34, weight: .black)).frame(width: 72, height: 72).background(.orange, in: Circle())
                HStack {
                    Text("\(question.part)").font(.title.bold()).frame(width: 64, height: 64).background(.white.opacity(0.25), in: Circle())
                    Image(systemName: "plus").font(.title.bold())
                    Text(selected.map(String.init) ?? "?").font(.title.bold()).frame(width: 64, height: 64).background(.white.opacity(0.25), in: Circle())
                }
                HStack {
                    ForEach(choices, id: \.self) { value in
                        NumberButton(number: value) { selected = value }
                    }
                }
                FeedbackBanner(
                    success: selected.map { question.part + $0 == question.whole },
                    correctMessage: "\(question.part) and \(missing) make \(question.whole)!",
                    retryMessage: "Count on from \(question.part) until you reach \(question.whole).",
                    onCorrect: nextRound
                )
            }
        }
    }

    private func nextRound() {
        round = (round + 1) % rounds.count
        selected = nil
    }
}

// MARK: - 10. Count dot patterns on both halves of a domino

private struct DominoGame: View {
    @State private var round = 0
    @State private var answer: Int?
    private let rounds = [
        (left: 3, right: 2), (left: 1, right: 4), (left: 3, right: 3),
        (left: 2, right: 4), (left: 5, right: 2)
    ]
    private var question: (left: Int, right: Int) { rounds[round] }
    private var total: Int { question.left + question.right }
    private var choices: [Int] {
        let values = [total - 1, total, total + 1]
        return [values, [values[1], values[2], values[0]], [values[2], values[0], values[1]]][round % 3]
    }

    var body: some View {
        GameShell(title: "Domino Detective", directions: "Count the dots on both sides. What is the total?", colors: [.brown, .orange]) {
            VStack(spacing: 22) {
                RoundCounter(round: round, total: rounds.count)
                HStack(spacing: 0) {
                    DominoHalf(count: question.left)
                    Rectangle().fill(.indigo).frame(width: 3, height: 110)
                    DominoHalf(count: question.right)
                }
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                Text("\(question.left) + \(question.right) = ?").font(.title.bold())
                HStack {
                    ForEach(choices, id: \.self) { value in
                        NumberButton(number: value) { answer = value }
                    }
                }
                FeedbackBanner(
                    success: answer.map { $0 == total },
                    correctMessage: "\(question.left) dots plus \(question.right) dots equals \(total)!",
                    retryMessage: "Touch and count every dot on both sides.",
                    onCorrect: nextRound
                )
            }
        }
    }

    private func nextRound() {
        round = (round + 1) % rounds.count
        answer = nil
    }
}

private struct DominoHalf: View {
    let count: Int
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(0..<count, id: \.self) { _ in Circle().fill(.indigo).frame(width: 18, height: 18) }
        }
        .frame(width: 100, height: 110)
        .padding(.horizontal, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(count) dots")
    }
}

// MARK: - 11. Move a character along a number line

private struct NumberLineGame: View {
    @State private var round = 0
    @State private var frogPosition = 2
    @State private var hops = 0
    @State private var feedback: Bool?
    private let rounds = [
        (start: 2, hops: 3), (start: 1, hops: 4), (start: 4, hops: 2),
        (start: 3, hops: 5), (start: 5, hops: 3)
    ]
    private var question: (start: Int, hops: Int) { rounds[round] }
    private var lineEnd: Int { max(6, question.start + question.hops + 1) }

    var body: some View {
        GameShell(title: "Frog Number Hops", directions: "Start at \(question.start). Tap Hop \(question.hops) times.", colors: [.cyan, .blue]) {
            VStack(spacing: 22) {
                RoundCounter(round: round, total: rounds.count)
                HStack(spacing: 5) {
                    ForEach(0...lineEnd, id: \.self) { number in
                        VStack(spacing: 4) {
                            Text(frogPosition == number ? "🐸" : " ").font(.title2)
                            Text("\(number)").font(.headline).frame(width: 38, height: 38).background(.white.opacity(0.23), in: Circle())
                        }
                    }
                }
                Text("\(question.start) + \(hops) = \(frogPosition)").font(.title.bold())
                Button("Hop →") {
                    guard hops < question.hops else { return }
                    hops += 1
                    frogPosition += 1
                    if hops == question.hops { feedback = frogPosition == question.start + question.hops }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Hop forward one")
                .accessibilityHint("\(question.hops - hops) hops remaining")
                FeedbackBanner(
                    success: feedback,
                    correctMessage: "\(question.start) plus \(question.hops) equals \(question.start + question.hops)!",
                    onCorrect: nextRound
                )
                Button("Back to \(question.start)") { frogPosition = question.start; hops = 0; feedback = nil }
                    .buttonStyle(.bordered)
            }
        }
        .onAppear { frogPosition = question.start }
    }

    private func nextRound() {
        round = (round + 1) % rounds.count
        hops = 0
        feedback = nil
        frogPosition = rounds[round].start
    }
}

// MARK: - 12. Solve an equality by completing one side

private struct BalanceGame: View {
    @State private var round = 0
    @State private var answer: Int?
    private let rounds = [
        (whole: 6, part: 3), (whole: 8, part: 5), (whole: 5, part: 1),
        (whole: 10, part: 4), (whole: 9, part: 2)
    ]
    private var question: (whole: Int, part: Int) { rounds[round] }
    private var missing: Int { question.whole - question.part }
    private var choices: [Int] {
        let values = [max(0, missing - 1), missing, missing + 1]
        return [values, [values[1], values[2], values[0]], [values[2], values[0], values[1]]][round % 3]
    }
    private var rightTotal: Int { question.part + (answer ?? 0) }

    var body: some View {
        GameShell(title: "Balance the Scale", directions: "The left side weighs \(question.whole). Choose the missing number that makes both sides equal.", colors: [.green, .yellow]) {
            VStack(spacing: 22) {
                RoundCounter(round: round, total: rounds.count)
                HStack(spacing: 14) {
                    VStack { Text(String(repeating: "🍊", count: question.whole)); Text("\(question.whole)").font(.title.bold()) }
                        .frame(maxWidth: .infinity).padding().background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
                    Image(systemName: rightTotal == question.whole ? "equal.circle.fill" : "scale.3d").font(.largeTitle)
                    VStack {
                        Text(String(repeating: "🍊", count: question.part))
                        Text(answer.map { String(repeating: "🍊", count: $0) } ?? "?")
                        Text(answer.map { "\(question.part) + \($0)" } ?? "\(question.part) + ?").font(.title2.bold())
                    }
                        .frame(maxWidth: .infinity).padding().background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
                }
                HStack {
                    ForEach(choices, id: \.self) { value in
                        NumberButton(number: value) { answer = value }
                    }
                }
                Text("\(question.part) + ? = \(question.whole)").font(.title2.bold())
                FeedbackBanner(
                    success: answer.map { $0 == missing },
                    correctMessage: "Both sides equal \(question.whole)—the scale is balanced!",
                    retryMessage: "Count on from \(question.part) to \(question.whole) to find the missing part.",
                    onCorrect: nextRound
                )
            }
        }
    }

    private func nextRound() {
        round = (round + 1) % rounds.count
        answer = nil
    }
}

private struct ObjectGroup: View {
    let emoji: String
    let count: Int

    var body: some View {
        Text(String(repeating: emoji, count: count))
            .font(.system(size: 34))
            .multilineTextAlignment(.center)
            .padding(12)
            .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(count) items")
    }
}

private struct CountingBackgroundLayer: View {
    var body: some View {
        GeometryReader { proxy in
            let totalHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.92, green: 0.55, blue: 0.62), Color(red: 0.60, green: 0.30, blue: 0.86)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                Image("learningLabBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: totalHeight)
                    .clipped()
                    .ignoresSafeArea()

                Image("PlayfulBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: totalHeight)
                    .clipped()
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    CountingMenu()
}
