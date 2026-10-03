import SwiftUI

/// A stable free sample in each section; new activities require Premium by default.
enum GameAccessPolicy {
    static let freeActivityIDs: Set<String> = [
        "phonics.letter-match", "shapes.post", "counting.pile-match",
        "nature.habitats", "stories.library", "feelings.faces"
    ]

    static let freeBookIDs: Set<String> = ["books.owen-onion"]

    static func canPlay(_ activityID: String, hasPremium: Bool) -> Bool {
        hasPremium || freeActivityIDs.contains(activityID) || freeBookIDs.contains(activityID)
    }

    static let premiumDescription = "Try a free activity in each section, including the first Read Together book. Subscribe to unlock the other 66 activities and three more books."
}

struct PremiumActivityLink<Destination: View, Label: View>: View {
    let activity: LearningActivity
    @ViewBuilder var destination: () -> Destination
    @ViewBuilder var label: () -> Label
    @ObservedObject private var store = StoreManager.shared
    @State private var showPremiumGate = false

    private var unlocked: Bool {
        GameAccessPolicy.canPlay(activity.id, hasPremium: store.hasPremium)
    }

    var body: some View {
        Group {
            if unlocked {
                NavigationLink {
                    PremiumActivityDestination(activityID: activity.id, destination: destination)
                } label: { card }
            } else {
                Button { showPremiumGate = true } label: { card }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("activity.\(activity.id)")
        .accessibilityLabel("\(activity.title). \(activity.ageBand). \(unlocked ? activity.skill : "Premium, grown-up required")")
        .sheet(isPresented: $showPremiumGate) { PremiumPromptView() }
    }

    private var card: some View {
        label().overlay(alignment: .topTrailing) {
            if !unlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .frame(width: 32, height: 32)
                    .background(.regularMaterial, in: Circle())
                    .padding(14)
                    .accessibilityHidden(true)
            }
        }
    }
}

/// Also checks an already-open destination if the subscription expires or is revoked.
private struct PremiumActivityDestination<Destination: View>: View {
    let activityID: String
    @ViewBuilder var destination: () -> Destination
    @ObservedObject private var store = StoreManager.shared

    var body: some View {
        Group {
            if GameAccessPolicy.canPlay(activityID, hasPremium: store.hasPremium) {
                destination()
            } else {
                PremiumParentGateView()
            }
        }
        .onChange(of: store.hasPremium) { _, active in
            if !active && !GameAccessPolicy.canPlay(activityID, hasPremium: false) {
                GameNarrator.stopAll()
                ItemSoundManager.shared.stop()
            }
        }
    }
}
