import Combine
import Foundation
import SwiftUI

@MainActor
final class SessionTimerManager: ObservableObject {
    static let shared = SessionTimerManager()
    @Published private(set) var remainingSeconds = 0
    @Published private(set) var isRunning = false
    @Published private(set) var isLocked = false
    @Published private(set) var showMinuteWarning = false
    private var clock = PlaySessionClock()
    private var timerTask: Task<Void, Never>?
    private let epoch = ContinuousClock.now

    private var elapsedTime: TimeInterval {
        let duration = epoch.duration(to: .now).components
        return Double(duration.seconds) + Double(duration.attoseconds) / 1e18
    }

    private init() {}

    var formattedTime: String {
        "\(remainingSeconds / 60):" + String(format: "%02d", remainingSeconds % 60)
    }

    func start(minutes: Int) {
        stop()
        clock.start(minutes: minutes, now: elapsedTime)
        isRunning = true
        isLocked = false
        refresh()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(1)) } catch { return }
                guard !Task.isCancelled else { return }
                self?.refresh()
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
        clock.stop()
        isRunning = false
        remainingSeconds = 0
        showMinuteWarning = false
    }

    func unlock() {
        stop()
        isLocked = false
    }

    func refresh() {
        guard isRunning else { return }
        remainingSeconds = clock.remaining(at: elapsedTime)
        showMinuteWarning = remainingSeconds > 0 && remainingSeconds <= 60
        if remainingSeconds == 0 {
            stop()
            isLocked = true
        }
    }
}

struct SessionTimerOverlay: View {
    @ObservedObject private var timer = SessionTimerManager.shared
    @State private var showParentCheck = false

    var body: some View {
        Group {
            if timer.isLocked {
                ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 72)).foregroundStyle(.orange)
                    Text("Time for a little break")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("Let's stretch, share a book, or find something to play with together.")
                        .font(.system(.title3, design: .rounded))
                        .multilineTextAlignment(.center)
                    ToddlerActionButton(title: "Grown-ups", systemImage: "lock.shield.fill") {
                        showParentCheck = true
                    }
                }
                .padding(28)
                .frame(maxWidth: 540)
                .frame(maxWidth: .infinity)
                }
                .background(Color(red: 0.98, green: 0.97, blue: 0.93).ignoresSafeArea())
                .foregroundStyle(Color(red: 0.13, green: 0.21, blue: 0.27))
                .sheet(isPresented: $showParentCheck) {
                    ParentChallengeView(onSuccess: {
                        showParentCheck = false
                        timer.unlock()
                    }, onCancel: { showParentCheck = false })
                }
            } else if timer.showMinuteWarning {
                VStack {
                    Spacer()
                    Text("One more minute, then a little break")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .padding(14)
                        .background(.regularMaterial, in: Capsule())
                        .padding(.bottom, 12)
                }
                .allowsHitTesting(false)
            }
        }
    }
}
