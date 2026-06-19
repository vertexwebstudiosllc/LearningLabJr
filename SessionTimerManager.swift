import Combine
import Foundation
import SwiftUI

@MainActor
final class SessionTimerManager: ObservableObject {
    static let shared = SessionTimerManager()

    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var isRunning = false
    @Published var isLocked = false
    @Published var showMinuteWarning = false

    private var timerTask: Task<Void, Never>?
    private var didShowMinuteWarning = false

    private init() {}

    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return "\(minutes):" + String(format: "%02d", seconds)
    }

    var shouldEmphasizeTimer: Bool {
        isRunning && remainingSeconds <= 10
    }

    func start(minutes: Int) {
        stop()
        remainingSeconds = max(1, minutes) * 60
        isRunning = true
        isLocked = false
        showMinuteWarning = false
        didShowMinuteWarning = false

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self?.tick()
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
        isRunning = false
        showMinuteWarning = false
        didShowMinuteWarning = false
    }

    func unlock() {
        isLocked = false
        stop()
        remainingSeconds = 0
    }

    private func tick() {
        guard isRunning else { return }

        remainingSeconds = max(0, remainingSeconds - 1)

        if remainingSeconds == 60 && !didShowMinuteWarning {
            didShowMinuteWarning = true
            showMinuteWarning = true
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                await MainActor.run {
                    self?.showMinuteWarning = false
                }
            }
        }

        if remainingSeconds == 0 {
            stop()
            isLocked = true
        }
    }
}

struct SessionTimerOverlay: View {
    @ObservedObject private var timerManager = SessionTimerManager.shared
    @State private var unlockAnswer = ""
    @State private var showUnlockError = false

    private let unlockAnswerValue = "6"

    var body: some View {
        ZStack {
            if timerManager.isRunning {
                VStack {
                    HStack {
                        Spacer()

                        timerBadge
                            .padding(.top, 12)
                            .padding(.trailing, 14)
                    }

                    Spacer()
                }
                .allowsHitTesting(false)
            }

            if timerManager.showMinuteWarning {
                VStack {
                    Text("1 minute left")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.72))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .padding(.top, 72)

                    Spacer()
                }
                .transition(.opacity)
                .allowsHitTesting(false)
            }

            if timerManager.isLocked {
                lockoutView
            }
        }
        .animation(.easeInOut(duration: 0.2), value: timerManager.showMinuteWarning)
        .animation(.easeInOut(duration: 0.2), value: timerManager.shouldEmphasizeTimer)
    }

    private var timerBadge: some View {
        Text(timerManager.formattedTime)
            .font(.system(size: timerManager.shouldEmphasizeTimer ? 34 : 15, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundColor(.white)
            .padding(.horizontal, timerManager.shouldEmphasizeTimer ? 18 : 10)
            .padding(.vertical, timerManager.shouldEmphasizeTimer ? 12 : 6)
            .background(timerManager.shouldEmphasizeTimer ? Color.red.opacity(0.86) : Color.black.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    private var lockoutView: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "hourglass")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(red: 0.96, green: 0.78, blue: 0.34))

                Text("Time's Up")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Ask a grown-up to unlock the app.")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.86))
                    .multilineTextAlignment(.center)

                Text("2 + 4 = ?")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                TextField("Answer", text: $unlockAnswer)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .frame(maxWidth: 160)

                if showUnlockError {
                    Text("Please try again.")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.72))
                }

                Button {
                    if unlockAnswer.trimmingCharacters(in: .whitespacesAndNewlines) == unlockAnswerValue {
                        unlockAnswer = ""
                        showUnlockError = false
                        timerManager.unlock()
                    } else {
                        showUnlockError = true
                    }
                } label: {
                    Text("Unlock")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.12, green: 0.36, blue: 0.52))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .padding(24)
            .frame(maxWidth: 340)
            .background(Color.black.opacity(0.46))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .padding(24)
        }
    }
}
