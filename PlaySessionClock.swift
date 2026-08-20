import Foundation

/// Monotonic time prevents wall-clock changes and backgrounding from extending a session.
struct PlaySessionClock {
    private(set) var deadline: TimeInterval?

    mutating func start(minutes: Int, now: TimeInterval) {
        deadline = now + TimeInterval(min(30, max(1, minutes)) * 60)
    }

    mutating func stop() { deadline = nil }

    func remaining(at now: TimeInterval) -> Int {
        guard let deadline else { return 0 }
        return max(0, Int(ceil(deadline - now)))
    }
}
