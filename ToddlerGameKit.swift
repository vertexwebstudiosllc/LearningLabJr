import AVFoundation
import Combine
import SwiftUI
import UIKit

/// Parent-facing curriculum information, independent of a game's presentation.
struct LearningActivity: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let skill: String
    let interaction: String
    let ageBand: String
    let caregiverTip: String
}

private struct LearningActivityKey: EnvironmentKey {
    static let defaultValue: LearningActivity? = nil
}

extension EnvironmentValues {
    var learningActivity: LearningActivity? {
        get { self[LearningActivityKey.self] }
        set { self[LearningActivityKey.self] = newValue }
    }
}

extension View {
    func learningActivity(_ activity: LearningActivity) -> some View {
        environment(\.learningActivity, activity)
            .onDisappear { GameNarrator.stopAll() }
    }
}

/// All new activities share one speech channel, so rapid taps never build a queue.
@MainActor
final class GameNarrator: ObservableObject {
    private let owner = UUID()

    static func promptsEnabled(in defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: "parents.voicePromptsEnabled") == nil || defaults.bool(forKey: "parents.voicePromptsEnabled")
    }

    func speak(_ text: String, allowUnrecorded: Bool = false) {
        #if DEBUG
        if !allowUnrecorded, ProcessInfo.processInfo.arguments.contains("-validateNarrationCoverage"), !text.isEmpty {
            assert(NarrationAudioCatalog.shared.url(for: text) != nil, "Missing recorded narration: \(text)")
        }
        #endif
        guard Self.promptsEnabled(),
              !UIAccessibility.isVoiceOverRunning, !text.isEmpty,
              UIApplication.shared.applicationState == .active,
              !SessionTimerManager.shared.isLocked else { return }
        ActivitySpeech.shared.speak(text, owner: owner)
    }

    /// Plays a finished story as one interruptible sequence, using actual clip completion.
    func speakSequence(_ lines: [String], onLine: @escaping (Int) -> Void, onFinish: @escaping () -> Void) {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-validateNarrationCoverage") {
            for line in lines { assert(NarrationAudioCatalog.shared.url(for: line) != nil, "Missing recorded narration: \(line)") }
        }
        #endif
        guard Self.promptsEnabled(), !UIAccessibility.isVoiceOverRunning,
              UIApplication.shared.applicationState == .active,
              !SessionTimerManager.shared.isLocked else { onFinish(); return }
        ActivitySpeech.shared.speakSequence(lines, owner: owner, onLine: onLine, onFinish: onFinish)
    }

    func stop() {
        ActivitySpeech.shared.stop(owner: owner)
    }

    static func stopAll() {
        ActivitySpeech.shared.stopAll()
    }
}

struct NarrationPlaylist {
    let lines: [String]
    private(set) var index = 0
    var current: String? { lines.indices.contains(index) ? lines[index] : nil }
    mutating func advance() { if index < lines.count { index += 1 } }
}

@MainActor
private final class ActivitySpeech: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = ActivitySpeech()
    private let synthesizer = AVSpeechSynthesizer()
    private let recording = RecordedNarrationPlayer()
    private var owner: UUID?
    private var currentUtterance: ObjectIdentifier?
    private var currentRecording: UUID?
    private var playlist: NarrationPlaylist?
    private var onLine: ((Int) -> Void)?
    private var onFinish: (() -> Void)?

    private override init() {
        super.init()
        synthesizer.delegate = self
    }
    func speak(_ text: String, owner: UUID) {
        stopAll(); self.owner = owner; play(text)
    }
    func speakSequence(_ lines: [String], owner: UUID, onLine: @escaping (Int) -> Void, onFinish: @escaping () -> Void) {
        stopAll()
        guard !lines.isEmpty else { onFinish(); return }
        self.owner = owner; playlist = NarrationPlaylist(lines: lines)
        self.onLine = onLine; self.onFinish = onFinish
        playNext()
    }
    private func playNext() {
        guard GameNarrator.promptsEnabled(), !UIAccessibility.isVoiceOverRunning,
              UIApplication.shared.applicationState == .active, !SessionTimerManager.shared.isLocked,
              let playlist, let line = playlist.current else { stopAll(); return }
        onLine?(playlist.index)
        play(line)
    }
    private func play(_ text: String) {
        if NarrationVoice.prefersRecordedNarration,
           let url = NarrationAudioCatalog.shared.url(for: text) {
            let token = UUID(); currentRecording = token
            BackgroundMusicManager.shared.setNarrating(true)
            if recording.play(url: url, onFinish: { [weak self] in
                guard let self, self.currentRecording == token else { return }
                self.currentRecording = nil; self.completeClip()
            }) { return }
            currentRecording = nil
        }
        let utterance = AVSpeechUtterance(string: text)
        guard NarrationVoice.configure(utterance) else { stopAll(); return }
        currentUtterance = ObjectIdentifier(utterance)
        BackgroundMusicManager.shared.setNarrating(true)
        synthesizer.speak(utterance)
    }
    func stop(owner: UUID) {
        guard self.owner == owner else { return }
        stopAll()
    }
    func stopAll() {
        let finish = onFinish
        onFinish = nil; onLine = nil; playlist = nil
        currentRecording = nil; recording.stop()
        currentUtterance = nil; synthesizer.stopSpeaking(at: .immediate)
        owner = nil; BackgroundMusicManager.shared.setNarrating(false)
        finish?()
    }
    private func completeClip() {
        if playlist != nil {
            playlist?.advance()
            if playlist?.current != nil { playNext(); return }
        }
        stopAll()
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let token = ObjectIdentifier(utterance)
        Task { @MainActor in
            guard self.currentUtterance == token else { return }
            self.currentUtterance = nil; self.completeClip()
        }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let token = ObjectIdentifier(utterance)
        Task { @MainActor in
            guard self.currentUtterance == token else { return }
            self.stopAll()
        }
    }
}

private struct GameViewportSizeKey: EnvironmentKey {
    static let defaultValue: CGSize? = nil
}

private struct GameContentScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1
}

private struct GameContentIsInvertedKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var gameContentIsInverted: Bool {
        get { self[GameContentIsInvertedKey.self] }
        set { self[GameContentIsInvertedKey.self] = newValue }
    }
    /// The actual space available for play in a landscape window. Nil uses the portrait layout.
    var gameViewportSize: CGSize? {
        get { self[GameViewportSizeKey.self] }
        set { self[GameViewportSizeKey.self] = newValue }
    }
    /// Converts screen-space drag displacement back into the fitted board's coordinates.
    var gameContentScale: CGFloat {
        get { self[GameContentScaleKey.self] }
        set { self[GameContentScaleKey.self] = newValue }
    }
}

/// Keeps legacy fixed-size boards completely visible while viewport-aware games lay themselves out at full size.
/// The same content subtree is retained when rotating, so a game never starts over just to change its layout.
struct GameFittedContent<Content: View>: View {
    let viewport: CGSize?
    @ViewBuilder var content: () -> Content
    @State private var measuredSize = CGSize.zero

    private var scale: CGFloat {
        guard let viewport, measuredSize.width > 0, measuredSize.height > 0 else { return 1 }
        return min(1, viewport.width / measuredSize.width, viewport.height / measuredSize.height)
    }

    var body: some View {
        content()
            .environment(\.gameViewportSize, viewport)
            .environment(\.gameContentScale, scale)
            .frame(width: viewport?.width)
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGSize.self) { $0.size } action: { measuredSize = $0 }
            .scaleEffect(scale, anchor: .top)
            .frame(width: viewport?.width, height: viewport?.height, alignment: .top)
    }
}

struct ToddlerGameScaffold<Content: View>: View {
    let title: String
    let prompt: String
    var accent: Color = .teal
    var completion: Bool = false
    var onReplay: (() -> Void)? = nil
    var scrollToTopOnPromptChange = false
    var autoNarratePrompt = true
    var allowUnrecordedPrompt = false
    @ViewBuilder let content: () -> Content
    @Environment(\.dismiss) private var dismiss
    @Environment(\.learningActivity) private var activity
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @StateObject private var narrator = GameNarrator()
    @State private var showingTogether = false

    var body: some View {
        GeometryReader { geometry in
            // A short window needs two independently bounded panes, not a portrait stack in a wide ScrollView.
            let landscape = geometry.size.width >= 600 && geometry.size.width > geometry.size.height
                && !dynamicTypeSize.isAccessibilitySize
            let margin: CGFloat = landscape ? 10 : 20
            let gap: CGFloat = landscape ? 16 : 22
            let availableWidth = max(0, min(geometry.size.width - margin * 2, landscape ? 1180 : 740))
            let availableHeight = max(1, geometry.size.height - margin * 2)
            let directionsWidth = min(260, max(190, availableWidth * 0.27))
            let viewport = landscape ? CGSize(width: max(1, availableWidth - directionsWidth - gap), height: availableHeight) : nil
            let layout = landscape
                ? AnyLayout(HStackLayout(alignment: .top, spacing: gap))
                : AnyLayout(VStackLayout(spacing: gap))

            ScrollViewReader { scroll in
                ScrollView {
                    layout {
                        VStack(spacing: landscape ? 10 : 16) {
                            directions(compact: landscape)
                            if landscape {
                                if completion {
                                    finishControls(compact: true)
                                } else if activity != nil {
                                    Button { showingTogether = true } label: {
                                        Label("Play together", systemImage: "person.2.fill")
                                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                                            .frame(maxWidth: .infinity, minHeight: 44)
                                            .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 16))
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityIdentifier("game.play-together")
                                    .popover(isPresented: $showingTogether) {
                                        VStack(alignment: .leading, spacing: 14) {
                                            Label("Play together", systemImage: "person.2.fill").font(.headline)
                                            Text(activity?.caregiverTip ?? "")
                                            Button("Done") { showingTogether = false }
                                                .frame(maxWidth: .infinity, minHeight: 44)
                                        }
                                        .padding(20).frame(idealWidth: 280, maxWidth: 340)
                                        .presentationCompactAdaptation(.popover)
                                        .environment(\.gameViewportSize, nil)
                                        .environment(\.gameContentScale, 1)
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                        }
                        .frame(width: landscape ? directionsWidth : nil, height: landscape ? availableHeight : nil, alignment: .top)
                        .id("activity-top")

                        GameFittedContent(viewport: viewport) {
                            VStack(spacing: landscape ? 10 : 22) {
                                if completion && !landscape {
                                    finishControls(compact: false)
                                        .transition(reduceMotion ? .identity : .opacity)
                                }
                                content()
                                    .frame(maxWidth: .infinity)
                                    .disabled(completion)
                                if !landscape, let activity, !completion {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Label("Play together", systemImage: "person.2.fill")
                                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                                        Text(activity.caregiverTip).font(.system(.subheadline, design: .rounded))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(18)
                                    .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 20))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("game.play-area")
                    }
                    .frame(width: availableWidth)
                    .padding(margin)
                    .frame(maxWidth: .infinity)
                }
                .scrollDisabled(landscape)
                .scrollBounceBehavior(.basedOnSize)
                .onChange(of: prompt) { _, _ in
                    if !landscape && scrollToTopOnPromptChange { scroll.scrollTo("activity-top", anchor: .top) }
                }
                .onChange(of: completion) { _, finished in
                    if finished && !landscape { scroll.scrollTo("activity-top", anchor: .top) }
                }
            }
        }
        .background(Color(red: 0.98, green: 0.97, blue: 0.93).ignoresSafeArea())
        .foregroundStyle(Color(red: 0.13, green: 0.21, blue: 0.27))
        .tint(accent)
        .navigationTitle("Let's play")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: "\(completion):\(prompt)") {
            if autoNarratePrompt { narrator.speak(completion ? "We did it together! You can play again or choose all done." : prompt, allowUnrecorded: allowUnrecordedPrompt) }
        }
        .onDisappear { narrator.stop() }
    }

    private func directions(compact: Bool) -> some View {
        VStack(spacing: compact ? 10 : 16) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.system(compact ? .title3 : .title, design: .rounded, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button { narrator.speak(prompt, allowUnrecorded: allowUnrecordedPrompt) } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(compact ? .title3.bold() : .title2.bold())
                        .frame(width: compact ? 44 : 64, height: compact ? 44 : 64)
                        .background(accent.opacity(0.13), in: Circle())
                }
                .accessibilityLabel("Hear the directions again")
            }
            Text(prompt)
                .font(.system(compact ? .subheadline : .title3, design: .rounded, weight: .semibold))
                .multilineTextAlignment(compact ? .leading : .center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: compact ? 0 : 56, alignment: compact ? .leading : .center)
                .accessibilityAddTraits(.isHeader)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("game.directions")
    }

    private func finishControls(compact: Bool) -> some View {
        VStack(spacing: compact ? 8 : 14) {
            Label("We did it together!", systemImage: "checkmark.seal.fill")
                .font(.system(compact ? .headline : .title2, design: .rounded, weight: .bold))
            if !compact {
                Text(activity?.caregiverTip ?? "Try this play idea with a grown-up away from the screen.")
                    .multilineTextAlignment(.center)
            }
            Button { dismiss() } label: {
                Label("All done", systemImage: "house.fill")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity, minHeight: compact ? 44 : 64)
                    .background(accent.opacity(0.19), in: RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
            if let onReplay {
                Button { narrator.stop(); onReplay() } label: {
                    Text("Play again").font(.system(.headline, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: compact ? 44 : 64)
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)
            }
        }
        .padding(compact ? 10 : 22)
        .frame(maxWidth: .infinity)
        .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 22))
    }
}

struct ToddlerActionButton: View {
    let title: String
    var systemImage: String? = nil
    var color: Color = .teal
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    if let systemImage { Image(systemName: systemImage) }
                    Text(title)
                }
                .fixedSize()
                VStack(spacing: 8) {
                    if let systemImage { Image(systemName: systemImage) }
                    Text(title).multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .font(.system(.title3, design: .rounded, weight: .bold))
            .frame(maxWidth: .infinity, minHeight: 64)
            .padding(.horizontal, 16)
            .foregroundStyle(Color(red: 0.1, green: 0.18, blue: 0.24))
            .background(color.opacity(0.19), in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(color.opacity(0.5), lineWidth: 2))
            .contentShape(RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct ToddlerArt: View {
    var asset: String? = nil
    var symbol: String = "star.fill"
    var size: CGFloat = 96

    private var resolvedImage: UIImage? {
        guard let asset else { return nil }
        // Keep original artwork intact while using the cleaned cutouts in games.
        let cleanedName = ["dolphin": "dolphinClean", "Apple": "AppleClean"][asset]
        return cleanedName.flatMap { UIImage(named: $0) }
            ?? UIImage(named: asset)
            ?? UIImage(named: "Space/\(asset)")
    }

    var body: some View {
        Group {
            if let image = resolvedImage {
                Image(uiImage: image).resizable().scaledToFit()
            } else if symbol.hasPrefix("nature."), let activity = NatureActivity(rawValue: String(symbol.dropFirst(7))) {
                NatureMenuIcon(activity: activity).padding(size * 0.16)
            } else if symbol.hasPrefix("stories."), let activity = StoryActivity(rawValue: String(symbol.dropFirst(8))) {
                StoryMenuIcon(activity: activity).padding(size * 0.16)
            } else if symbol == "toolbox.fill" {
                SolutionToolboxIcon().padding(size * 0.12)
            } else if symbol == "frog.fill" {
                FrogMenuSymbol().padding(size * 0.16)
            } else {
                Image(systemName: symbol).resizable().scaledToFit().padding(size * 0.16)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// A vector frog that inherits the same accent as the neighboring menu symbols.
private struct FrogMenuSymbol: View {
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                Ellipse().frame(width: w * 0.74, height: h * 0.62).offset(y: h * 0.05)
                ForEach([-1.0, 1.0], id: \.self) { side in
                    Ellipse().frame(width: w * 0.4, height: h * 0.22).offset(x: side * w * 0.27, y: h * 0.33)
                    Circle().frame(width: w * 0.36).offset(x: side * w * 0.23, y: -h * 0.23)
                    Circle().fill(.white).frame(width: w * 0.22).offset(x: side * w * 0.23, y: -h * 0.23)
                    Circle().frame(width: w * 0.1).offset(x: side * w * 0.23, y: -h * 0.23)
                }
                Path { path in
                    path.move(to: CGPoint(x: w * 0.34, y: h * 0.53))
                    path.addQuadCurve(to: CGPoint(x: w * 0.66, y: h * 0.53), control: CGPoint(x: w * 0.5, y: h * 0.77))
                }.stroke(.white, style: StrokeStyle(lineWidth: w * 0.05, lineCap: .round))
            }.frame(width: w, height: h)
        }
    }
}

private struct CompactActivityMenuKey: EnvironmentKey {
    static let defaultValue = false
}

private extension EnvironmentValues {
    var compactActivityMenu: Bool {
        get { self[CompactActivityMenuKey.self] }
        set { self[CompactActivityMenuKey.self] = newValue }
    }
}

struct ActivityMenu<Content: View>: View {
    let title: String
    let subtitle: String
    let accent: Color
    var activityCount: Int = 12
    @ViewBuilder let content: () -> Content
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width >= 600 && geometry.size.width > geometry.size.height
                && !dynamicTypeSize.isAccessibilitySize {
                landscapeMenu(size: geometry.size)
            } else {
                portraitMenu
            }
        }
        .background(Color(red: 0.98, green: 0.97, blue: 0.93).ignoresSafeArea())
        .foregroundStyle(Color(red: 0.13, green: 0.21, blue: 0.27))
        .tint(accent)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var portraitMenu: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(title).font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text(subtitle).font(.system(.body, design: .rounded))
                Label("\(activityCount) ways to play together", systemImage: "hand.wave.fill")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .padding(12)
                    .background(accent.opacity(0.12), in: Capsule())
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 260), spacing: 16)], spacing: 16) {
                    content()
                }
            }
            .padding(20)
            .frame(maxWidth: 960)
            .frame(maxWidth: .infinity)
        }
        .environment(\.compactActivityMenu, false)
    }

    private func landscapeMenu(size: CGSize) -> some View {
        let width = min(max(0, size.width - 24), 1180)
        let height = max(1, size.height - 24)
        let headingWidth = min(260, max(180, width * 0.26))
        let gridWidth = max(1, width - headingWidth - 20)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: gridWidth >= 780 ? 3 : 2)

        return HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.system(.subheadline, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)
                Label("\(activityCount) ways to play together", systemImage: "hand.wave.fill")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
            }
            .frame(width: headingWidth, height: height, alignment: .topLeading)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("activity-menu.heading")

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    content()
                }
                .environment(\.compactActivityMenu, true)
                .padding(2)
            }
            .scrollBounceBehavior(.basedOnSize)
            .frame(width: gridWidth, height: height)
            .accessibilityIdentifier("activity-menu.activities")
        }
        .frame(width: width, height: height)
        .frame(width: size.width, height: size.height)
    }
}

struct ActivityCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    var asset: String? = nil
    let accent: Color
    @Environment(\.compactActivityMenu) private var compact

    var body: some View {
        Group {
            if compact {
                HStack(alignment: .center, spacing: 10) {
                    ToddlerArt(asset: asset, symbol: symbol, size: 48)
                        .foregroundStyle(accent)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(subtitle)
                            .font(.system(size: 12, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                portraitContent
            }
        }
        .foregroundStyle(Color(red: 0.13, green: 0.21, blue: 0.27))
        .padding(compact ? 12 : 18)
        .frame(maxWidth: .infinity, minHeight: compact ? 104 : 210, alignment: compact ? .leading : .topLeading)
        .background(.white, in: RoundedRectangle(cornerRadius: compact ? 20 : 26))
        .overlay(RoundedRectangle(cornerRadius: compact ? 20 : 26).strokeBorder(accent.opacity(0.23), lineWidth: 2))
        .contentShape(RoundedRectangle(cornerRadius: compact ? 20 : 26))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityHint("Opens this activity")
        .accessibilityIdentifier("activity-card.\(title)")
    }

    private var portraitContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            ToddlerArt(asset: asset, symbol: symbol, size: 68)
                .foregroundStyle(accent)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.system(.subheadline, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}
