import SwiftUI
import AVFoundation
import Combine

enum PatternDrum: Int, CaseIterable {
    case small, medium, big
    var name: String { ["Small drum", "Medium drum", "Big drum"][rawValue] }
    var color: Color { [.orange, .teal, .purple][rawValue] }
    var scale: CGFloat { [0.58, 0.77, 0.96][rawValue] }
    var soundName: String { "pattern-drum-\(rawValue)" }
}

struct DrumPatternRound {
    let notes: [PatternDrum]
    var signature: String { notes.map { String($0.rawValue) }.joined() }
    static func session(previousFirst: String? = nil) -> [Self] {
        var rounds: [Self] = []
        var used: Set<String> = []
        for length in 2...7 {
            for _ in 0..<3 {
                var round: Self
                repeat {
                    var notes: [PatternDrum] = []
                    for _ in 0..<length {
                        let choices = PatternDrum.allCases.filter { length > 3 || $0 != notes.last }
                        notes.append(choices.randomElement()!)
                    }
                    round = Self(notes: notes)
                } while Set(round.notes).count < 2 || used.contains(round.signature) || (rounds.isEmpty && round.signature == previousFirst)
                used.insert(round.signature); rounds.append(round)
            }
        }
        return rounds
    }
    static let prompt = "Watch our three drums! Then tap the same drums in the same order."
    static let watch = "Watch the pattern. My turn!"
    static let ready = "Your turn! Tap the drums in the same order."
    static let retry = "Let's watch that pattern again, from the beginning."
    static let success = "You played the whole pattern! What a wonderful drummer!"
    static let completion = "You copied every drum pattern! Let's give our drummer a cheer!"
}

struct DrumPatternSession {
    enum Phase { case showing, playing, solved }
    enum Answer { case ignored, retry, correct, solved }
    let rounds: [DrumPatternRound]
    private(set) var index = 0
    private(set) var position = 0
    private(set) var phase = Phase.showing
    var current: DrumPatternRound { rounds[min(index, rounds.count - 1)] }
    var finished: Bool { index == rounds.count }
    init(previousFirst: String? = nil) { rounds = DrumPatternRound.session(previousFirst: previousFirst) }
    mutating func beginDemo() {
        guard !finished, phase != .solved else { return }
        position = 0; phase = .showing
    }
    mutating func finishDemo() {
        guard !finished, phase == .showing else { return }
        phase = .playing
    }
    mutating func tap(_ drum: PatternDrum) -> Answer {
        guard !finished, phase == .playing else { return .ignored }
        guard current.notes[position] == drum else { beginDemo(); return .retry }
        position += 1
        if position == current.notes.count { phase = .solved; return .solved }
        return .correct
    }
    mutating func next() {
        guard !finished, phase == .solved else { return }
        index += 1
        if !finished { position = 0; phase = .showing }
    }
}

@MainActor
private final class PatternDrumAudio: ObservableObject {
    private var player: AVAudioPlayer?
    func play(_ drum: PatternDrum) {
        guard GameNarrator.promptsEnabled(), let url = Bundle.main.url(forResource: drum.soundName, withExtension: "wav") else { return }
        player?.stop()
        player = try? AVAudioPlayer(contentsOf: url)
        player?.volume = 0.45
        player?.play()
    }
    func stop() { player?.stop() }
}

private struct PatternDrumArt: View {
    let drum: PatternDrum
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                RoundedRectangle(cornerRadius: w * 0.1).fill(drum.color).frame(width: w, height: h * 0.65).offset(y: h * 0.12)
                HStack {
                    ForEach(0..<3, id: \.self) { _ in Capsule().fill(.white.opacity(0.7)).frame(width: w * 0.045, height: h * 0.38) }
                }.frame(width: w * 0.8).offset(y: h * 0.16)
                Ellipse().fill(Color(red: 1, green: 0.94, blue: 0.76))
                    .overlay(Ellipse().stroke(drum.color, lineWidth: 4))
                    .frame(width: w, height: h * 0.42).offset(y: -h * 0.23)
            }.frame(width: w, height: h)
        }
    }
}

struct CountingDrumGame: View {
    private static let previousKey = "drumPatterns.previousFirst"
    @State private var session = DrumPatternSession(previousFirst: UserDefaults.standard.string(forKey: Self.previousKey))
    @State private var request = 0
    @State private var lead = DrumPatternRound.prompt
    @State private var activeNote: Int?
    @State private var tapped: PatternDrum?
    @State private var feedback = ""
    @StateObject private var narrator = GameNarrator()
    @StateObject private var audio = PatternDrumAudio()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ToddlerGameScaffold(title: "Counting Drum", prompt: session.finished ? DrumPatternRound.completion : DrumPatternRound.prompt,
                            accent: .purple, completion: session.finished, onReplay: replay) {
            Text("Pattern \(min(session.index + 1, 18)) of 18 · \(session.current.notes.count) beats")
                .font(.headline).accessibilityIdentifier("counting.drum.level")
            Text(session.phase == .showing ? "Watch my pattern" : (session.phase == .solved ? "Pattern complete!" : "Your turn"))
                .font(.title2.bold()).accessibilityIdentifier("counting.drum.phase")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(session.current.notes.indices, id: \.self) { index in
                    VStack(spacing: 4) {
                        PatternDrumArt(drum: session.current.notes[index]).frame(width: 30 * session.current.notes[index].scale + 12, height: 28)
                        Text("\(index + 1)").font(.caption.bold())
                    }.frame(maxWidth: .infinity, minHeight: 56)
                        .background(activeNote == index ? Color.yellow : (index < session.position ? Color.green.opacity(0.2) : Color.white), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(activeNote == index ? Color.orange : Color.clear, lineWidth: 3))
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Beat \(index + 1), \(session.current.notes[index].name)")
                        .accessibilityIdentifier("counting.drum.example.\(index)")
                }
            }.accessibilityLabel("Example pattern, read left to right")
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(PatternDrum.allCases, id: \.self) { drum in
                    Button { tap(drum) } label: {
                        VStack(spacing: 10) {
                            GeometryReader { geometry in
                                PatternDrumArt(drum: drum)
                                    .frame(width: geometry.size.width * drum.scale, height: 84 * drum.scale)
                                    .position(x: geometry.size.width / 2, y: 84 - 42 * drum.scale)
                            }.frame(height: 88)
                            Text(drum.name).font(.subheadline.bold()).multilineTextAlignment(.center)
                        }.padding(8).frame(maxWidth: .infinity, minHeight: 142)
                            .background(isLit(drum) ? Color.yellow.opacity(0.5) : Color.white, in: RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(isLit(drum) ? Color.orange : drum.color.opacity(0.4), lineWidth: isLit(drum) ? 4 : 2))
                            .scaleEffect(isLit(drum) && !reduceMotion ? 1.025 : 1)
                            .contentShape(Rectangle())
                    }.buttonStyle(.plain).allowsHitTesting(session.phase == .playing && !session.finished)
                        .accessibilityLabel(drum.name)
                        .accessibilityValue(session.phase == .playing ? "Ready" : "Watch the example")
                        .accessibilityIdentifier("counting.drum.pad.\(drum.rawValue)")
                }
            }
            Text("\(session.position) of \(session.current.notes.count) beats copied").font(.headline)
                .accessibilityIdentifier("counting.drum.progress")
            if !feedback.isEmpty { Text(feedback).font(.headline).multilineTextAlignment(.center) }
            if session.phase == .solved && !session.finished {
                ToddlerActionButton(title: session.index == 17 ? "Finish drumming" : "Next pattern", systemImage: "music.note", color: .purple) {
                    narrator.stop(); audio.stop(); session.next(); activeNote = nil; tapped = nil; feedback = ""
                    lead = DrumPatternRound.watch; request += 1
                }.accessibilityIdentifier("counting.drum.next")
            } else if !session.finished {
                ToddlerActionButton(title: "Watch again", systemImage: "play.circle.fill", color: .purple) { startDemo(DrumPatternRound.watch) }
                    .disabled(session.phase == .showing).accessibilityIdentifier("counting.drum.watch")
            }
        }
        .task(id: "\(request):\(scenePhase)") { await demonstrate() }
        .task(id: tapped) {
            guard tapped != nil else { return }
            do { try await Task.sleep(for: .milliseconds(250)); tapped = nil } catch { }
        }
        .onAppear { rememberFirst() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { narrator.stop(); audio.stop(); session.beginDemo(); activeNote = nil; tapped = nil; lead = DrumPatternRound.watch; request += 1 }
        }
        .onDisappear { narrator.stop(); audio.stop() }
    }
    private func isLit(_ drum: PatternDrum) -> Bool {
        if let activeNote { return session.current.notes[activeNote] == drum }
        return tapped == drum
    }
    private func tap(_ drum: PatternDrum) {
        let result = session.tap(drum)
        guard result != .ignored else { return }
        audio.play(drum); tapped = drum
        switch result {
        case .retry: startDemo(DrumPatternRound.retry)
        case .solved: feedback = DrumPatternRound.success; narrator.speak(feedback)
        default: feedback = ""
        }
    }
    private func startDemo(_ text: String) {
        guard !session.finished, session.phase != .solved else { return }
        narrator.stop(); audio.stop(); session.beginDemo(); activeNote = nil; tapped = nil; feedback = ""
        lead = text; request += 1
    }
    private func duration(_ text: String) -> Double {
        guard GameNarrator.promptsEnabled(), let url = NarrationAudioCatalog.shared.url(for: text), let player = try? AVAudioPlayer(contentsOf: url) else { return 0.8 }
        return max(0.8, player.duration + 0.2)
    }
    private func demonstrate() async {
        guard scenePhase == .active, !session.finished, session.phase == .showing else { return }
        let token = request
        do {
            if lead != DrumPatternRound.prompt { narrator.speak(lead) }
            try await Task.sleep(for: .seconds(duration(lead)))
            for index in session.current.notes.indices {
                try Task.checkCancellation()
                guard token == request else { return }
                activeNote = index
                let drum = session.current.notes[index]
                audio.play(drum); narrator.speak(drum.name)
                try await Task.sleep(for: .seconds(duration(drum.name)))
                activeNote = nil
                try await Task.sleep(for: .milliseconds(220))
            }
            narrator.speak(DrumPatternRound.ready)
            try await Task.sleep(for: .seconds(duration(DrumPatternRound.ready)))
            try Task.checkCancellation()
            if token == request { session.finishDemo() }
        } catch { if token == request { activeNote = nil } }
    }
    private func rememberFirst() { UserDefaults.standard.set(session.rounds[0].signature, forKey: Self.previousKey) }
    private func replay() {
        narrator.stop(); audio.stop(); session = DrumPatternSession(previousFirst: session.rounds[0].signature)
        activeNote = nil; tapped = nil; feedback = ""; lead = DrumPatternRound.prompt; request += 1; rememberFirst()
    }
}
