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

    func speak(_ text: String) {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-validateNarrationCoverage"), !text.isEmpty {
            assert(NarrationAudioCatalog.shared.url(for: text) != nil, "Missing recorded narration: \(text)")
        }
        #endif
        guard Self.promptsEnabled(),
              !UIAccessibility.isVoiceOverRunning, !text.isEmpty,
              UIApplication.shared.applicationState == .active,
              !SessionTimerManager.shared.isLocked else { return }
        ActivitySpeech.shared.speak(text, owner: owner)
    }

    func stop() {
        ActivitySpeech.shared.stop(owner: owner)
    }

    static func stopAll() {
        ActivitySpeech.shared.stopAll()
    }
}

@MainActor
private final class ActivitySpeech: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = ActivitySpeech()
    private let synthesizer = AVSpeechSynthesizer()
    private let recording = RecordedNarrationPlayer()
    private var owner: UUID?
    private var currentUtterance: ObjectIdentifier?
    private var currentRecording: UUID?

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, owner: UUID) {
        stopAll()
        if NarrationVoice.prefersRecordedNarration,
           let url = NarrationAudioCatalog.shared.url(for: text) {
            let token = UUID()
            self.owner = owner
            currentRecording = token
            BackgroundMusicManager.shared.setNarrating(true)
            if recording.play(url: url, onFinish: { [weak self] in
                guard let self, self.currentRecording == token else { return }
                self.currentRecording = nil
                self.owner = nil
                BackgroundMusicManager.shared.setNarrating(false)
            }) { return }
            // A missing or damaged recording should never leave a game silent.
            stopAll()
        }
        let utterance = AVSpeechUtterance(string: text)
        guard NarrationVoice.configure(utterance) else { return }
        self.owner = owner
        currentUtterance = ObjectIdentifier(utterance)
        BackgroundMusicManager.shared.setNarrating(true)
        synthesizer.speak(utterance)
    }

    func stop(owner: UUID) {
        guard self.owner == owner else { return }
        stopAll()
    }

    func stopAll() {
        currentRecording = nil
        recording.stop()
        currentUtterance = nil
        synthesizer.stopSpeaking(at: .immediate)
        owner = nil
        BackgroundMusicManager.shared.setNarrating(false)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let token = ObjectIdentifier(utterance)
        Task { @MainActor in self.finish(token) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let token = ObjectIdentifier(utterance)
        Task { @MainActor in self.finish(token) }
    }

    private func finish(_ token: ObjectIdentifier) {
        guard currentUtterance == token else { return }
        currentUtterance = nil
        owner = nil
        BackgroundMusicManager.shared.setNarrating(false)
    }
}

struct ToddlerGameScaffold<Content: View>: View {
    let title: String
    let prompt: String
    var accent: Color = .teal
    var completion: Bool = false
    var onReplay: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content
    @Environment(\.dismiss) private var dismiss
    @Environment(\.learningActivity) private var activity
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ScrollViewReader { scroll in
            ScrollView {
                VStack(spacing: 22) {
                    HStack {
                        Text(title)
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button { narrator.speak(prompt) } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title2.bold())
                                .frame(width: 64, height: 64)
                                .background(accent.opacity(0.13), in: Circle())
                        }
                        .accessibilityLabel("Hear the directions again")
                    }
                    .id("activity-top")

                    Text(prompt)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .accessibilityAddTraits(.isHeader)

                    if !completion {
                        content()
                            .frame(maxWidth: .infinity)
                    }

                    if completion {
                        VStack(spacing: 14) {
                            Label("We did it together!", systemImage: "checkmark.seal.fill")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            Text(activity?.caregiverTip ?? "Try this play idea with a grown-up away from the screen.")
                                .multilineTextAlignment(.center)
                            ToddlerActionButton(title: "All done", systemImage: "house.fill", color: accent) { dismiss() }
                            if let onReplay {
                                Button {
                                    narrator.stop()
                                    onReplay()
                                } label: {
                                    Text("Play again")
                                        .font(.system(.headline, design: .rounded))
                                        .frame(minWidth: 100, minHeight: 64)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(22)
                        .frame(maxWidth: .infinity)
                        .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 26))
                        .transition(reduceMotion ? .identity : .opacity)

                        // Keep the child's creation visible below the finish controls.
                        content()
                            .frame(maxWidth: .infinity)
                            .disabled(true)
                    }

                    if let activity, !completion {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Play together", systemImage: "person.2.fill")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                            Text(activity.caregiverTip)
                                .font(.system(.subheadline, design: .rounded))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding(20)
                .frame(maxWidth: 780)
                .frame(maxWidth: .infinity)
            }
            .background(Color(red: 0.98, green: 0.97, blue: 0.93).ignoresSafeArea())
            .foregroundStyle(Color(red: 0.13, green: 0.21, blue: 0.27))
            .tint(accent)
            .navigationTitle("Let's play")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: "\(completion):\(prompt)") {
                narrator.speak(completion ? "We did it together! You can play again or choose all done." : prompt)
            }
            .onChange(of: completion) { _, finished in
                if finished { scroll.scrollTo("activity-top", anchor: .top) }
            }
            .onDisappear { narrator.stop() }
        }
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
            } else {
                Image(systemName: symbol).resizable().scaledToFit().padding(size * 0.16)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct ActivityMenu<Content: View>: View {
    let title: String
    let subtitle: String
    let accent: Color
    var activityCount: Int = 12
    @ViewBuilder let content: () -> Content

    var body: some View {
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
        .background(Color(red: 0.98, green: 0.97, blue: 0.93).ignoresSafeArea())
        .foregroundStyle(Color(red: 0.13, green: 0.21, blue: 0.27))
        .tint(accent)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ActivityCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    var asset: String? = nil
    let accent: Color

    var body: some View {
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
        .foregroundStyle(Color(red: 0.13, green: 0.21, blue: 0.27))
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 210, alignment: .topLeading)
        .background(.white, in: RoundedRectangle(cornerRadius: 26))
        .overlay(RoundedRectangle(cornerRadius: 26).strokeBorder(accent.opacity(0.23), lineWidth: 2))
        .contentShape(RoundedRectangle(cornerRadius: 26))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityHint("Opens this activity")
        .accessibilityIdentifier("activity-card.\(title)")
    }
}
