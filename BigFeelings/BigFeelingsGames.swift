import SwiftUI

private struct BFNote: View {
    let text: String
    var body: some View {
        Text(text).font(.system(.body, design: .rounded, weight: .medium))
            .multilineTextAlignment(.center).frame(maxWidth: .infinity, minHeight: 58)
            .padding(16).background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22))
            .accessibilityAddTraits(.updatesFrequently)
    }
}

struct SeeYouSoonGame: View {
    let onReplay: () -> Void
    @State private var step = 0
    @State private var goodbye = ""
    @State private var comfort = ""
    private let prompts = ["Let's pretend Teddy is saying goodbye for a little while. Choose a goodbye Teddy likes.", "Teddy will stay with a trusted grown-up. Choose something comforting to do together.", "Teddy's friend says goodbye and goes behind the curtain. Your real grown-up stays right here.", "Teddy's friend is back! Practice a warm hello together."]
    var body: some View {
        ToddlerGameScaffold(title: "See You Soon", prompt: step == 4 ? "Hello again! Teddy and a friend practiced a goodbye and a reunion." : prompts[min(step, 3)], accent: .pink, completion: step == 4, onReplay: onReplay) {
            HStack(spacing: 30) {
                Image(systemName: "teddybear.fill").font(.system(size: 95)).foregroundStyle(.brown)
                ZStack {
                    RoundedRectangle(cornerRadius: 24).fill(step == 2 ? Color.purple : Color.pink.opacity(0.1))
                    Image(systemName: step == 2 ? "star.fill" : "hare.fill").font(.system(size: 65))
                        .foregroundStyle(step == 2 ? .yellow : .pink)
                }.frame(width: 130, height: 155)
            }.frame(height: 185).accessibilityLabel(step == 2 ? "Teddy beside a closed pretend curtain" : "Teddy and a rabbit friend together")
            if step == 0 {
                ForEach(["A little wave", "A high five if both want one", "Kind words: see you soon"], id: \.self) { choice in
                    ToddlerActionButton(title: choice, systemImage: "hand.wave.fill", color: .pink) { goodbye = choice; step = 1 }
                }
            } else if step == 1 {
                ForEach(["Read a book together", "Hold a favorite toy", "Sit beside my grown-up"], id: \.self) { choice in
                    ToddlerActionButton(title: choice, systemImage: "heart.fill", color: .purple) { comfort = choice; step = 2 }
                }
            } else if step == 2 {
                BFNote(text: "Our goodbye: \(goodbye).\nOur cozy plan: \(comfort).")
                ToddlerActionButton(title: "Open the pretend curtain", systemImage: "door.left.hand.open", color: .purple) { step = 3 }
            } else if step == 3 {
                ToddlerActionButton(title: "Hello again, friend!", systemImage: "hand.wave.fill", color: .pink) { step = 4 }
            }
            BFNote(text: "Grown-up: this is a pretend story. Stay together and talk about the familiar person who cares for your child.")
        }
    }
}
