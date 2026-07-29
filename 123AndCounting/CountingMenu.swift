//
//  CountingMenu.swift
//  LearningLabJr
//
//  Created by Matthew Teitelman on 12/10/25.
//

import SwiftUI

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

private struct PileMatchItem {
    let emoji: String
    let count: Int
}

private struct PileMatchGame: View {
    @State private var round = 0
    @State private var piles: [PileMatchItem]
    @State private var recentItems: [String] = []
    @State private var answers: [Int?] = [nil, nil]
    @State private var selectedCard: Int?
    @State private var feedback: Bool?
    @State private var coaching = "Count each group, then move its number card."
    @State private var dropFrames: [Int: CGRect] = [:]
    @State private var activeDropTarget: Int?
    @State private var wrongAttempts = 0
    @State private var correctPlacements = 0
    @State private var hintCard: Int?
    @State private var hintPulse = false
    @State private var hintTimerID = 0
    @State private var draggingCard: Int?
    private static let itemPool = [
        "🍎", "⭐️", "🐠", "🦋", "🚗", "⚽️", "🍪", "🎈",
        "🐞", "🌼", "🐶", "🐸", "🦀", "🐢", "🐙", "🐬",
        "🦊", "🐼", "🧁", "🥕", "🚀", "🦕", "🍓", "🍊",
        "🐧", "🐝", "🌈", "🎁", "🍉", "🥨", "🐳", "🪁"
    ]
    private var cards: [Int] { Array(piles.map(\.count).reversed()) }

    init() {
        _piles = State(initialValue: Self.makeRound(excluding: []))
    }

    var body: some View {
        GameShell(title: "Pile Match", directions: "Count each group. Drag or tap each number onto its matching group.", colors: [.orange, .pink]) {
            VStack(spacing: 18) {
                RoundCounter(round: round % 10, total: 10)

                Label(coaching, systemImage: feedback == true ? "star.fill" : "hand.point.up.left.fill")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(feedback == true ? Color.yellow : .white)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .padding(.horizontal, 12)
                    .background(.black.opacity(0.12), in: Capsule())
                    .contentTransition(.numericText())
                    .accessibilityLabel("Game hint. \(coaching)")

                HStack(alignment: .top, spacing: 16) {
                    ForEach(piles.indices, id: \.self) { index in
                        PileMatchDropZone(
                            emoji: piles[index].emoji,
                            itemCount: piles[index].count,
                            answer: answers[index],
                            isTargeted: activeDropTarget == index
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 24))
                        .onTapGesture { placeSelectedCard(in: index) }
                        .background {
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: PileDropFrameKey.self,
                                    value: [index: proxy.frame(in: .named("pileMatchBoard"))]
                                )
                            }
                        }
                        .accessibilityAction(named: "Place selected card") {
                            placeSelectedCard(in: index)
                        }
                    }
                }
                .frame(minHeight: 205)

                VStack(spacing: 9) {
                    Text(answers.allSatisfy { $0 != nil } ? "Wonderful matching!" : "NUMBER CARDS")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.white.opacity(0.82))

                    HStack(spacing: 22) {
                    ForEach(cards, id: \.self) { number in
                            PileNumberCard(
                                number: number,
                                selected: selectedCard == number,
                                placed: answers.contains(number),
                                isHinting: hintCard == number,
                                hintPulse: hintPulse,
                                hintDirection: hintDirection(for: number),
                                onTap: { select(number) },
                                onDragBegan: {
                                    draggingCard = number
                                    stopHint()
                                },
                                onDragChanged: { location in
                                    activeDropTarget = target(at: location)
                                },
                                onDragEnded: { location in
                                    defer {
                                        activeDropTarget = nil
                                        draggingCard = nil
                                        restartHintTimer()
                                    }
                                    guard let index = target(at: location) else {
                                        coaching = "Almost! Move the card inside a glowing group."
                                        wrongAttempts += 1
                                        return
                                    }
                                    attemptPlace(number, in: index)
                                }
                            )
                        }
                    }
                }
                .padding(.vertical, 8)

                if answers.contains(where: { $0 != nil }) && feedback != true {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            resetAnswers()
                        }
                    } label: {
                        Label("Start This Match Over", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                }
            }
            .coordinateSpace(name: "pileMatchBoard")
            .onPreferenceChange(PileDropFrameKey.self) { dropFrames = $0 }
            .sensoryFeedback(.error, trigger: wrongAttempts)
            .sensoryFeedback(.selection, trigger: selectedCard)
            .sensoryFeedback(.success, trigger: correctPlacements)
            .task(id: hintTimerID) {
                try? await Task.sleep(for: .seconds(5))
                guard !Task.isCancelled,
                      selectedCard == nil,
                      draggingCard == nil,
                      feedback != true,
                      let number = cards.filter({ !answers.contains($0) }).randomElement()
                else { return }

                hintCard = number
                coaching = "Try the wiggling \(number). It is showing you where to go!"
                hintPulse = false
                withAnimation(.easeInOut(duration: 0.32).repeatForever(autoreverses: true)) {
                    hintPulse = true
                }
            }
        }
    }

    private func nextRound() {
        withAnimation(.easeInOut(duration: 0.35)) {
            recentItems.append(contentsOf: piles.map(\.emoji))
            recentItems = Array(recentItems.suffix(20))
            piles = Self.makeRound(excluding: Set(recentItems))
            round += 1
            resetAnswers()
        }
    }

    private func select(_ number: Int) {
        guard !answers.contains(number), feedback != true else { return }
        stopHint()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
            selectedCard = selectedCard == number ? nil : number
            coaching = selectedCard == nil
                ? "Count each group, then move its number card."
                : "Card \(number) selected. Now tap the matching group."
        }
        if selectedCard == nil {
            restartHintTimer()
        }
    }

    private func placeSelectedCard(in index: Int) {
        guard let selectedCard else {
            coaching = "Choose a number card first, then tap its group."
            wrongAttempts += 1
            restartHintTimer()
            return
        }
        attemptPlace(selectedCard, in: index)
    }

    private func attemptPlace(_ number: Int, in index: Int) {
        guard feedback != true, !answers.contains(number) else { return }

        guard number == piles[index].count else {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) {
                coaching = "Count again—this group does not have \(number)."
                selectedCard = number
            }
            wrongAttempts += 1
            restartHintTimer()
            return
        }

        stopHint()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.68)) {
            answers[index] = number
            selectedCard = nil
            correctPlacements += 1
            if answers.allSatisfy({ $0 != nil }) {
                feedback = true
                coaching = "You matched both groups! Great counting!"
            } else {
                coaching = "\(number) is a match! Now count the other group."
            }
        }

        guard feedback == true else {
            restartHintTimer()
            return
        }
        Task {
            try? await Task.sleep(for: .seconds(1.6))
            guard !Task.isCancelled else { return }
            nextRound()
        }
    }

    private func target(at location: CGPoint) -> Int? {
        dropFrames.first(where: { $0.value.insetBy(dx: -12, dy: -12).contains(location) })?.key
    }

    private func resetAnswers() {
        answers = [nil, nil]
        selectedCard = nil
        activeDropTarget = nil
        feedback = nil
        coaching = "Count each group, then move its number card."
        restartHintTimer()
    }

    private func stopHint() {
        hintTimerID += 1
        hintCard = nil
        hintPulse = false
    }

    private func restartHintTimer() {
        hintTimerID += 1
        hintCard = nil
        hintPulse = false
    }

    private func hintDirection(for number: Int) -> CGFloat {
        guard let pileIndex = piles.firstIndex(where: { $0.count == number }) else { return 0 }
        return pileIndex == 0 ? -1 : 1
    }

    private static func makeRound(excluding excludedItems: Set<String>) -> [PileMatchItem] {
        var availableItems = itemPool.filter { !excludedItems.contains($0) }
        if availableItems.count < 2 {
            availableItems = itemPool
        }

        let chosenItems = Array(availableItems.shuffled().prefix(2))
        let chosenCounts = Array((1...8).shuffled().prefix(2))
        return zip(chosenItems, chosenCounts).map { PileMatchItem(emoji: $0.0, count: $0.1) }
    }
}

private struct PileMatchDropZone: View {
    let emoji: String
    let itemCount: Int
    let answer: Int?
    let isTargeted: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text(String(repeating: emoji, count: itemCount))
                .font(.system(size: 39))
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, minHeight: 100)

            ZStack {
                RoundedRectangle(cornerRadius: 17)
                    .fill(answer == nil ? .white.opacity(isTargeted ? 0.34 : 0.14) : .green.opacity(0.85))

                if let answer {
                    Label("\(answer)", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 25, weight: .black, design: .rounded))
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Label(isTargeted ? "Let go!" : "Match here", systemImage: isTargeted ? "arrow.down.circle.fill" : "square.dashed")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 64)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(isTargeted ? 0.2 : 0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            answer == nil ? (isTargeted ? Color.yellow : .white.opacity(0.28)) : Color.green,
                            style: StrokeStyle(lineWidth: isTargeted ? 5 : 2, dash: answer == nil && !isTargeted ? [8] : [])
                        )
                }
        )
        .scaleEffect(isTargeted ? 1.035 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.72), value: isTargeted)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(itemCount) \(emoji) items. \(answer == nil ? "Waiting for a number." : "Matched with \(answer!).")")
        .accessibilityHint(answer == nil ? "Select the matching number, then activate this group." : "This group is complete.")
    }
}

private struct PileNumberCard: View {
    let number: Int
    let selected: Bool
    let placed: Bool
    let isHinting: Bool
    let hintPulse: Bool
    let hintDirection: CGFloat
    let onTap: () -> Void
    let onDragBegan: () -> Void
    let onDragChanged: (CGPoint) -> Void
    let onDragEnded: (CGPoint) -> Void
    @State private var dragOffset: CGSize = .zero
    @State private var dragging = false

    var body: some View {
        Text("\(number)")
            .font(.system(size: 36, weight: .black, design: .rounded))
            .foregroundStyle(selected || dragging ? .white : .indigo)
            .frame(width: 82, height: 82)
            .background(
                Circle()
                    .fill(selected || dragging ? Color.indigo : .white)
                    .shadow(color: .black.opacity(dragging ? 0.3 : 0.18), radius: dragging ? 16 : 7, y: dragging ? 12 : 5)
            )
            .overlay {
                Circle()
                    .stroke(selected ? Color.yellow : .white.opacity(0.65), lineWidth: selected ? 5 : 2)
            }
            .scaleEffect(dragging ? 1.16 : selected ? 1.08 : 1)
            .rotationEffect(.degrees(isHinting ? (hintPulse ? 5 : -5) : 0))
            .offset(
                x: dragOffset.width + (isHinting ? hintDirection * (hintPulse ? 18 : 10) : 0),
                y: dragOffset.height + (isHinting ? -10 : 0)
            )
            .opacity(placed ? 0 : 1)
            .allowsHitTesting(!placed)
            .zIndex(dragging ? 20 : 1)
            .onTapGesture(perform: onTap)
            .highPriorityGesture(
                DragGesture(minimumDistance: 1, coordinateSpace: .named("pileMatchBoard"))
                    .onChanged { value in
                        guard !placed else { return }
                        if !dragging {
                            onDragBegan()
                        }
                        dragging = true
                        dragOffset = value.translation
                        onDragChanged(value.location)
                    }
                    .onEnded { value in
                        guard !placed else { return }
                        onDragEnded(value.location)
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.66)) {
                            dragOffset = .zero
                            dragging = false
                        }
                    }
            )
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: selected)
            .accessibilityLabel("Number \(number)")
            .accessibilityHint(
                isHinting
                    ? "This card is giving a hint. Move it toward the \(hintDirection < 0 ? "left" : "right") group."
                    : "Double tap to select, then activate the group with \(number) items."
            )
            .accessibilityAddTraits(selected ? [.isSelected] : [])
            .accessibilityHidden(placed)
    }
}

private struct PileDropFrameKey: PreferenceKey {
    static let defaultValue: [Int: CGRect] = [:]

    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
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
