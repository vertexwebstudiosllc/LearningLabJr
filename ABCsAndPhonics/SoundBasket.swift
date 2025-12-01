import SwiftUI
import Combine
import AVFoundation

struct SoundBaskets: View {
    @StateObject private var viewModel = SoundBasketsViewModel()
    @Namespace private var dragSpace
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var dragStartPoint: CGPoint = .zero
    @State private var dragAreaWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            ABCsBackgroundLayer()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear { dragAreaWidth = proxy.size.width }
                            .onChange(of: proxy.size.width) { dragAreaWidth = $0 }
                    }
                )

            VStack(spacing: 16) {
                Spacer().frame(height: 20)

                // Logo at top center; replace name with your asset name
                Image("learningLabLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 198, maxHeight: 198) // ~10% smaller
                    .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
                    .offset(y: -8)

                // Kids artwork beneath logo; replace name with your asset name
                Image("learningLabKids")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 490, maxHeight: 490) // ~20% larger again
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
                    .padding(.top, -170) // nudged slightly down (~2.5-3% shift)

                // Current word to sort (draggable)
                VStack(spacing: 12) {
                    viewModel.currentWordImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .shadow(radius: 8)
                        .padding(.top, 8)
                        .offset(dragOffset)
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .named("dragArea"))
                                .onChanged { value in
                                    if !isDragging {
                                        isDragging = true
                                        viewModel.beginDrag()
                                    }
                                    dragOffset = value.translation
                                    let midX = dragAreaWidth / 2
                                    viewModel.updateHoverState(location: value.location, midX: midX)
                                }
                                .onEnded { value in
                                    let midX = dragAreaWidth / 2
                                    let targetLetter = value.location.x < midX ? viewModel.leftLetter : viewModel.rightLetter
                                    viewModel.handleDrop(on: targetLetter)
                                    dragOffset = .zero
                                    isDragging = false
                                }
                        )
                        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: dragOffset)

                    Text(viewModel.currentWord.word.capitalized)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                }
                .padding(.bottom, 8)

                // Drag hint
                Text("Drag to the matching sound")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                GeometryReader { geo in
                    let basketHeight: CGFloat = 180

                    HStack(spacing: 24) {
                        basketView(letter: viewModel.leftLetter, state: viewModel.leftState)
                            .frame(maxWidth: .infinity)
                            .frame(height: basketHeight)

                        basketView(letter: viewModel.rightLetter, state: viewModel.rightState)
                            .frame(maxWidth: .infinity)
                            .frame(height: basketHeight)
                    }
                    .padding(.horizontal, 24)
                }
                .frame(height: 260)

                Spacer()
            }

            if viewModel.showCheckmark {
                feedbackOverlay(symbol: "checkmark.circle.fill", color: .green)
            }
            if viewModel.showXMark {
                feedbackOverlay(symbol: "xmark.circle.fill", color: .red)
            }
        }
        .onAppear {
            viewModel.prepareAudio()
        }
        .coordinateSpace(name: "dragArea")
    }

    private func basketView(letter: String, state: SoundBasketsViewModel.BasketState) -> some View {
        let baseColor = Color.white.opacity(0.9)
        let activeStroke = Color.white.opacity(0.6)
        let correctStroke = Color.green.opacity(0.85)
        let incorrectStroke = Color.red.opacity(0.85)

        let stroke: Color
        switch state {
        case .idle:
            stroke = activeStroke.opacity(0.4)
        case .active:
            stroke = activeStroke
        case .correct:
            stroke = correctStroke
        case .incorrect:
            stroke = incorrectStroke
        }

        return VStack(spacing: 8) {
            Image(systemName: "basket.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 110)
                .foregroundColor(state == .incorrect ? Color.red.opacity(0.8) : (state == .correct ? Color.green.opacity(0.85) : baseColor))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 6)

            Text(letter)
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(baseColor)
                .shadow(radius: 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.black.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(stroke, lineWidth: 4)
                )
        )
    }

    private func feedbackOverlay(symbol: String, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 260, height: 260)
            Image(systemName: symbol)
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .foregroundColor(color)
                .shadow(radius: 12)
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.showCheckmark)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.showXMark)
    }
}

// MARK: - ViewModel

final class SoundBasketsViewModel: ObservableObject {
    enum BasketState {
        case idle
        case active
        case correct
        case incorrect
    }

    @Published var leftLetter: String = "A"
    @Published var rightLetter: String = "B"
    @Published var wordQueue: [WordItem] = []
    @Published var currentIndex: Int = 0
    @Published var showCheckmark = false
    @Published var showXMark = false
    @Published var leftState: BasketState = .idle
    @Published var rightState: BasketState = .idle

    private var unusedLetters: [String] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }
    private var audioPlayer: AVAudioPlayer?

    var currentWord: WordItem {
        guard currentIndex < wordQueue.count else {
            return WordItem(word: "cat", imageName: "cat", startingLetter: "C")
        }
        return wordQueue[currentIndex]
    }

    var currentWordImage: Image {
        if let ui = UIImage(named: currentWord.imageName) {
            return Image(uiImage: ui)
        } else {
            return Image(systemName: "photo")
        }
    }

    init() {
        startNewRound()
    }

    func prepareAudio() {
        // Placeholder: simple system sound; customize with local asset if desired
    }

    func beginDrag() {
        leftState = .active
        rightState = .active
    }

    func updateHoverState(location: CGPoint, midX: CGFloat) {
        // keep both active; no-op for now but kept for future hover logic
        leftState = .active
        rightState = .active
    }

    func handleDrop(on letter: String) {
        let correct = currentWord.startingLetter.uppercased() == letter.uppercased()
        leftState = .active
        rightState = .active

        if correct {
            if letter.uppercased() == leftLetter.uppercased() {
                leftState = .correct
                rightState = .active
            } else {
                rightState = .correct
                leftState = .active
            }
            showCheckmark = true
            showXMark = false
            playSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                self.showCheckmark = false
                self.advanceWord()
                self.leftState = .idle
                self.rightState = .idle
            }
        } else {
            if letter.uppercased() == leftLetter.uppercased() {
                leftState = .incorrect
            } else {
                rightState = .incorrect
            }
            showCheckmark = false
            showXMark = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.showXMark = false
                self.leftState = .active
                self.rightState = .active
            }
        }
    }

    func advanceWord() {
        let next = currentIndex + 1
        if next >= wordQueue.count {
            startNewRound()
        } else {
            currentIndex = next
        }
    }

    func startNewRound() {
        ensureLettersAvailable()
        let pair = pickTwoLetters()
        leftLetter = pair.0
        rightLetter = pair.1
        wordQueue = makeRound(for: pair)
        currentIndex = 0
        showCheckmark = false
        showXMark = false
        leftState = .idle
        rightState = .idle
    }

    private func ensureLettersAvailable() {
        if unusedLetters.count < 2 {
            unusedLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }
        }
    }

    private func pickTwoLetters() -> (String, String) {
        unusedLetters.shuffle()
        let first = unusedLetters.removeFirst()
        let second = unusedLetters.removeFirst()
        return (first, second)
    }

    private func makeRound(for pair: (String, String)) -> [WordItem] {
        let candidates = WordBank.all.filter { word in
            word.startingLetter.uppercased() == pair.0 || word.startingLetter.uppercased() == pair.1
        }.shuffled()

        if candidates.count >= 10 {
            return Array(candidates.prefix(10))
        }

        var filled: [WordItem] = candidates
        let pool = candidates
        while filled.count < 10 {
            if let extra = pool.randomElement() {
                filled.append(extra)
            } else {
                filled.append(contentsOf: candidates)
            }
        }
        return Array(filled.prefix(10))
    }

    private func playSuccess() {
        AudioServicesPlaySystemSound(1108) // simple system "success" tick
    }
}

// MARK: - Models

struct WordItem: Identifiable {
    let id = UUID()
    let word: String
    let imageName: String
    let startingLetter: String
}

enum WordBank {
    static let all: [WordItem] = [
        WordItem(word: "apple", imageName: "apple", startingLetter: "A"),
        WordItem(word: "airplane", imageName: "airplane", startingLetter: "A"),
        WordItem(word: "ball", imageName: "ball", startingLetter: "B"),
        WordItem(word: "bear", imageName: "bear", startingLetter: "B"),
        WordItem(word: "cat", imageName: "cat", startingLetter: "C"),
        WordItem(word: "car", imageName: "car", startingLetter: "C"),
        WordItem(word: "dog", imageName: "dog", startingLetter: "D"),
        WordItem(word: "duck", imageName: "duck", startingLetter: "D"),
        WordItem(word: "elephant", imageName: "elephant", startingLetter: "E"),
        WordItem(word: "egg", imageName: "egg", startingLetter: "E"),
        WordItem(word: "fish", imageName: "fish", startingLetter: "F"),
        WordItem(word: "frog", imageName: "frog", startingLetter: "F"),
        WordItem(word: "goat", imageName: "goat", startingLetter: "G"),
        WordItem(word: "grapes", imageName: "grapes", startingLetter: "G"),
        WordItem(word: "hat", imageName: "hat", startingLetter: "H"),
        WordItem(word: "hippo", imageName: "hippo", startingLetter: "H"),
        WordItem(word: "icecream", imageName: "icecream", startingLetter: "I"),
        WordItem(word: "igloo", imageName: "igloo", startingLetter: "I"),
        WordItem(word: "juice", imageName: "juice", startingLetter: "J"),
        WordItem(word: "jelly", imageName: "jelly", startingLetter: "J"),
        WordItem(word: "kite", imageName: "kite", startingLetter: "K"),
        WordItem(word: "koala", imageName: "koala", startingLetter: "K"),
        WordItem(word: "lion", imageName: "lion", startingLetter: "L"),
        WordItem(word: "leaf", imageName: "leaf", startingLetter: "L"),
        WordItem(word: "moon", imageName: "moon", startingLetter: "M"),
        WordItem(word: "mouse", imageName: "mouse", startingLetter: "M"),
        WordItem(word: "nest", imageName: "nest", startingLetter: "N"),
        WordItem(word: "noodle", imageName: "noodle", startingLetter: "N"),
        WordItem(word: "orange", imageName: "orange", startingLetter: "O"),
        WordItem(word: "owl", imageName: "owl", startingLetter: "O"),
        WordItem(word: "pig", imageName: "pig", startingLetter: "P"),
        WordItem(word: "panda", imageName: "panda", startingLetter: "P"),
        WordItem(word: "queen", imageName: "queen", startingLetter: "Q"),
        WordItem(word: "quail", imageName: "quail", startingLetter: "Q"),
        WordItem(word: "rainbow", imageName: "rainbow", startingLetter: "R"),
        WordItem(word: "robot", imageName: "robot", startingLetter: "R"),
        WordItem(word: "sun", imageName: "sun", startingLetter: "S"),
        WordItem(word: "star", imageName: "star", startingLetter: "S"),
        WordItem(word: "turtle", imageName: "turtle", startingLetter: "T"),
        WordItem(word: "tree", imageName: "tree", startingLetter: "T"),
        WordItem(word: "umbrella", imageName: "umbrella", startingLetter: "U"),
        WordItem(word: "unicorn", imageName: "unicorn", startingLetter: "U"),
        WordItem(word: "violin", imageName: "violin", startingLetter: "V"),
        WordItem(word: "van", imageName: "van", startingLetter: "V"),
        WordItem(word: "whale", imageName: "whale", startingLetter: "W"),
        WordItem(word: "watermelon", imageName: "watermelon", startingLetter: "W"),
        WordItem(word: "xylophone", imageName: "xylophone", startingLetter: "X"),
        WordItem(word: "xray", imageName: "xray", startingLetter: "X"),
        WordItem(word: "yogurt", imageName: "yogurt", startingLetter: "Y"),
        WordItem(word: "yoyo", imageName: "yoyo", startingLetter: "Y"),
        WordItem(word: "zebra", imageName: "zebra", startingLetter: "Z"),
        WordItem(word: "zipper", imageName: "zipper", startingLetter: "Z")
    ]
}

// Reuse the playful background used on other ABC screens
private struct ABCsBackgroundLayer: View {
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
    SoundBaskets()
}
