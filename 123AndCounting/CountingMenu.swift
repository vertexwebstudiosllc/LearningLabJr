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
    }
}

private struct FeedbackBanner: View {
    let success: Bool?

    var body: some View {
        if let success {
            Label(success ? "You got it!" : "Try again!", systemImage: success ? "star.fill" : "arrow.counterclockwise")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(success ? Color.yellow : Color.white)
                .transition(.scale.combined(with: .opacity))
        }
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
    }
}

// MARK: - 1. Match two number cards to two distinct piles

private struct PileMatchGame: View {
    @State private var answers: [Int?] = [nil, nil]
    @State private var feedback: Bool?
    private let piles = [(emoji: "🍎", count: 3), (emoji: "⭐️", count: 5)]

    var body: some View {
        GameShell(title: "Pile Match", directions: "Count both piles. Drag each number card to the pile it matches.", colors: [.orange, .pink]) {
            VStack(spacing: 22) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(piles.indices, id: \.self) { index in
                        VStack(spacing: 10) {
                            Text(String(repeating: piles[index].emoji, count: piles[index].count))
                                .font(.system(size: 36))
                                .multilineTextAlignment(.center)
                            Text(answers[index].map(String.init) ?? "Drop here")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 62)
                                .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
                                .onDrop(of: [.text], isTargeted: nil) { providers in
                                    loadNumber(from: providers) { number in
                                        answers[index] = number
                                        if answers.allSatisfy({ $0 != nil }) {
                                            feedback = answers[0] == piles[0].count && answers[1] == piles[1].count
                                        }
                                    }
                                    return true
                                }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                HStack(spacing: 16) {
                    ForEach([5, 3], id: \.self) { number in
                        Text("\(number)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.indigo)
                            .frame(width: 68, height: 68)
                            .background(.white, in: Circle())
                            .onDrag { NSItemProvider(object: NSString(string: "\(number)")) }
                    }
                }
                FeedbackBanner(success: feedback)
                Button("Reset") { answers = [nil, nil]; feedback = nil }
                    .buttonStyle(.borderedProminent)
            }
        }
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
    @State private var touched: Set<Int> = []
    @State private var feedback: Bool?
    private let count = 6

    var body: some View {
        GameShell(title: "Touch & Count", directions: "Touch each animal once. Then choose how many you counted.", colors: [.blue, .cyan]) {
            VStack(spacing: 20) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 14) {
                    ForEach(0..<count, id: \.self) { index in
                        Button {
                            touched.insert(index)
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Text(["🐶", "🐱", "🐥"][index % 3]).font(.system(size: 50))
                                if touched.contains(index) {
                                    Text("\(touched.sorted().firstIndex(of: index)! + 1)")
                                        .font(.caption.bold())
                                        .frame(width: 25, height: 25)
                                        .background(.green, in: Circle())
                                }
                            }
                            .opacity(touched.contains(index) ? 0.55 : 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
                HStack {
                    ForEach([5, 6, 7], id: \.self) { value in
                        NumberButton(number: value) { feedback = touched.count == count && value == count }
                    }
                }
                FeedbackBanner(success: feedback)
                Button("Start Over") { touched.removeAll(); feedback = nil }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - 3. Visual addition with a multiple-choice sum

private struct AdditionGame: View {
    @State private var feedback: Bool?

    var body: some View {
        GameShell(title: "Addition Picnic", directions: "Put both picnic groups together. What is 2 + 3?", colors: [.green, .mint]) {
            VStack(spacing: 22) {
                HStack(spacing: 18) {
                    ObjectGroup(emoji: "🍓", count: 2)
                    Text("+").font(.largeTitle.bold())
                    ObjectGroup(emoji: "🍓", count: 3)
                }
                Text("2 + 3 = ?").font(.system(size: 32, weight: .bold, design: .rounded))
                HStack {
                    ForEach([4, 5, 6], id: \.self) { value in
                        NumberButton(number: value) { feedback = value == 5 }
                    }
                }
                FeedbackBanner(success: feedback)
            }
        }
    }
}

// MARK: - 4. Subtraction by physically tapping objects away

private struct SubtractionGame: View {
    @State private var removed: Set<Int> = []
    @State private var feedback: Bool?

    var body: some View {
        GameShell(title: "Dino Dash", directions: "There are 5 dinosaurs. Tap 2 to make them dash away. How many remain?", colors: [.purple, .indigo]) {
            VStack(spacing: 22) {
                HStack {
                    ForEach(0..<5, id: \.self) { index in
                        Button {
                            if removed.count < 2 { removed.insert(index) }
                        } label: {
                            Text("🦕")
                                .font(.system(size: 45))
                                .opacity(removed.contains(index) ? 0.12 : 1)
                                .offset(y: removed.contains(index) ? -18 : 0)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text("5 − \(removed.count) = ?")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                HStack {
                    ForEach([2, 3, 4], id: \.self) { value in
                        NumberButton(number: value) { feedback = removed.count == 2 && value == 3 }
                    }
                }
                FeedbackBanner(success: feedback)
                Button("Bring Them Back") { removed.removeAll(); feedback = nil }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - 5. Missing number in a sequence

private struct MissingNumberGame: View {
    @State private var answer: Int?

    var body: some View {
        GameShell(title: "Treasure Trail", directions: "Which stepping-stone number is missing?", colors: [.yellow, .orange]) {
            VStack(spacing: 24) {
                HStack(spacing: 8) {
                    ForEach(["2", "3", "?", "5", "6"], id: \.self) { value in
                        Text(value)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .frame(width: 52, height: 52)
                            .background(value == "?" ? Color.orange : .white.opacity(0.22), in: Circle())
                    }
                }
                HStack {
                    ForEach([3, 4, 5], id: \.self) { value in
                        NumberButton(number: value) { answer = value }
                    }
                }
                FeedbackBanner(success: answer.map { $0 == 4 })
            }
        }
    }
}

// MARK: - 6. Compare two visible quantities with symbols

private struct CompareGame: View {
    @State private var answer: String?

    var body: some View {
        GameShell(title: "More or Less", directions: "Choose the symbol that makes the number sentence true.", colors: [.teal, .blue]) {
            VStack(spacing: 22) {
                HStack(spacing: 18) {
                    ObjectGroup(emoji: "🎈", count: 4)
                    Text(answer ?? "?")
                        .font(.system(size: 40, weight: .black))
                        .frame(width: 58)
                    ObjectGroup(emoji: "🎈", count: 2)
                }
                HStack(spacing: 14) {
                    ForEach(["<", "=", ">"], id: \.self) { symbol in
                        Button(symbol) { answer = symbol }
                            .font(.system(size: 30, weight: .black))
                            .frame(width: 68, height: 58)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16))
                            .foregroundStyle(.indigo)
                    }
                }
                FeedbackBanner(success: answer.map { $0 == ">" })
            }
        }
    }
}

// MARK: - 7. Construct a quantity in a ten-frame

private struct TenFrameGame: View {
    @State private var planted: Set<Int> = []
    @State private var feedback: Bool?
    private let target = 7

    var body: some View {
        GameShell(title: "Ten-Frame Garden", directions: "Plant exactly 7 flowers in the ten-frame.", colors: [.pink, .purple]) {
            VStack(spacing: 20) {
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
                    }
                }
                Text("\(planted.count) flowers").font(.title2.bold())
                Button("Check My Garden") { feedback = planted.count == target }
                    .buttonStyle(.borderedProminent)
                FeedbackBanner(success: feedback)
            }
        }
    }
}

// MARK: - 8. Select scrambled values from least to greatest

private struct NumberOrderGame: View {
    @State private var ordered: [Int] = []
    @State private var feedback: Bool?
    private let numbers = [4, 1, 3, 2]

    var body: some View {
        GameShell(title: "Train Order", directions: "Tap the train cars from the smallest number to the biggest.", colors: [.indigo, .teal]) {
            VStack(spacing: 22) {
                HStack {
                    ForEach(numbers, id: \.self) { value in
                        NumberButton(number: value, selected: ordered.contains(value)) {
                            guard !ordered.contains(value) else { return }
                            ordered.append(value)
                            if ordered.count == numbers.count { feedback = ordered == numbers.sorted() }
                        }
                    }
                }
                HStack(spacing: 4) {
                    Image(systemName: "tram.fill").font(.title)
                    ForEach(ordered, id: \.self) { Text("\($0)").frame(width: 42, height: 42).background(.orange, in: RoundedRectangle(cornerRadius: 8)) }
                }
                .frame(minHeight: 46)
                FeedbackBanner(success: feedback)
                Button("Mix Them Up") { ordered.removeAll(); feedback = nil }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - 9. Choose an addend pair for a target whole

private struct NumberBondGame: View {
    @State private var selected: Int?

    var body: some View {
        GameShell(title: "Make the Number", directions: "The whole is 7. One part is 3. Choose the other part.", colors: [.red, .orange]) {
            VStack(spacing: 20) {
                Text("7").font(.system(size: 34, weight: .black)).frame(width: 72, height: 72).background(.orange, in: Circle())
                HStack {
                    Text("3").font(.title.bold()).frame(width: 64, height: 64).background(.white.opacity(0.25), in: Circle())
                    Image(systemName: "plus").font(.title.bold())
                    Text(selected.map(String.init) ?? "?").font(.title.bold()).frame(width: 64, height: 64).background(.white.opacity(0.25), in: Circle())
                }
                HStack {
                    ForEach([3, 4, 5], id: \.self) { value in
                        NumberButton(number: value) { selected = value }
                    }
                }
                FeedbackBanner(success: selected.map { 3 + $0 == 7 })
            }
        }
    }
}

// MARK: - 10. Count dot patterns on both halves of a domino

private struct DominoGame: View {
    @State private var answer: Int?

    var body: some View {
        GameShell(title: "Domino Detective", directions: "Count the dots on both sides. What is the total?", colors: [.brown, .orange]) {
            VStack(spacing: 22) {
                HStack(spacing: 0) {
                    DominoHalf(count: 3)
                    Rectangle().fill(.indigo).frame(width: 3, height: 110)
                    DominoHalf(count: 2)
                }
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                Text("3 + 2 = ?").font(.title.bold())
                HStack {
                    ForEach([4, 5, 6], id: \.self) { value in
                        NumberButton(number: value) { answer = value }
                    }
                }
                FeedbackBanner(success: answer.map { $0 == 5 })
            }
        }
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
    }
}

// MARK: - 11. Move a character along a number line

private struct NumberLineGame: View {
    @State private var frogPosition = 2
    @State private var hops = 0
    @State private var feedback: Bool?

    var body: some View {
        GameShell(title: "Frog Number Hops", directions: "Start at 2. Tap Hop three times to solve 2 + 3.", colors: [.cyan, .blue]) {
            VStack(spacing: 22) {
                HStack(spacing: 5) {
                    ForEach(0...6, id: \.self) { number in
                        VStack(spacing: 4) {
                            Text(frogPosition == number ? "🐸" : " ").font(.title2)
                            Text("\(number)").font(.headline).frame(width: 38, height: 38).background(.white.opacity(0.23), in: Circle())
                        }
                    }
                }
                Text("2 + \(hops) = \(frogPosition)").font(.title.bold())
                Button("Hop →") {
                    guard hops < 3 else { return }
                    hops += 1
                    frogPosition += 1
                    if hops == 3 { feedback = frogPosition == 5 }
                }
                .buttonStyle(.borderedProminent)
                FeedbackBanner(success: feedback)
                Button("Back to 2") { frogPosition = 2; hops = 0; feedback = nil }
                    .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - 12. Solve an equality by completing one side

private struct BalanceGame: View {
    @State private var answer: Int?

    var body: some View {
        GameShell(title: "Balance the Scale", directions: "The left side weighs 6. Choose the number that makes the right side equal.", colors: [.green, .yellow]) {
            VStack(spacing: 22) {
                HStack(spacing: 14) {
                    VStack { Text("🍊🍊🍊"); Text("🍊🍊🍊"); Text("6").font(.title.bold()) }
                        .frame(maxWidth: .infinity).padding().background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
                    Image(systemName: answer == 6 ? "equal.circle.fill" : "scale.3d").font(.largeTitle)
                    VStack { Text("🍊🍊🍊"); Text(answer.map { String(repeating: "🍊", count: $0) } ?? "?"); Text(answer.map(String.init) ?? "?").font(.title.bold()) }
                        .frame(maxWidth: .infinity).padding().background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
                }
                HStack {
                    ForEach([2, 3, 4], id: \.self) { missing in
                        NumberButton(number: missing) { answer = 3 + missing }
                    }
                }
                Text("3 + ? = 6").font(.title2.bold())
                FeedbackBanner(success: answer.map { $0 == 6 })
            }
        }
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
