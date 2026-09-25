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

struct BodyClueBuddiesGame: View {
    let onReplay: () -> Void
    @State private var explored: Set<Int> = []
    @State private var selected: Int?
    @State private var note = "Tap a body clue, then notice it in your own body with your grown-up."
    @StateObject private var narrator = GameNarrator()
    private let names = ["Hands", "Heartbeat", "Tummy", "Feet"]
    private let symbols = ["hand.raised.fill", "heart.fill", "circle.dotted", "shoeprints.fill"]
    private let clues = ["Open your hands, then softly close them. Do they feel warm, cool, or something else?", "Rest your own hand on your chest if you like. Can you notice your heartbeat? It is okay if you cannot.", "Notice your tummy. Does it feel hungry, full, fluttery, or something else? Only you can tell us.", "Notice your feet touching the floor or a cushion. Wiggle your toes, then let them rest."]
    var body: some View {
        ToddlerGameScaffold(title: "Body Clue Buddies", prompt: explored.count == 4 ? "You noticed clues from your hands, heartbeat, tummy, and feet!" : selected.map { clues[$0] } ?? "Our bodies can give us clues. Choose a place to notice.", accent: .orange, completion: explored.count == 4, onReplay: onReplay) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 118))], spacing: 14) {
                ForEach(0..<4, id: \.self) { index in
                    Button {
                        selected = index
                        note = clues[index]
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: symbols[index]).font(.system(size: 48))
                            Text(names[index]).font(.headline)
                            if explored.contains(index) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                        }.foregroundStyle(.orange).frame(maxWidth: .infinity, minHeight: 133)
                            .background(.white, in: RoundedRectangle(cornerRadius: 24))
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(selected == index ? Color.orange : .clear, lineWidth: 3))
                    }.buttonStyle(.plain)
                }
            }
            if let selected {
                ToddlerActionButton(title: "We noticed together", systemImage: "checkmark", color: .orange) {
                    explored.insert(selected)
                    self.selected = nil
                    note = "Thank you for noticing. A body clue can mean different things."
                    narrator.speak(note)
                }
            }
            BFNote(text: note)
        }
    }
}

struct FriendshipBridgeGame: View {
    let onReplay: () -> Void
    @State private var step = 0
    @State private var response: String?
    @StateObject private var narrator = GameNarrator()
    private let stories = ["A friend is building. You would like to play, too. What could you say?", "Your friend says, 'I am still using this block.' What could you try?", "You both want to build. How could you make a plan together?"]
    private let choices = [["Can I play with you?", "May I build beside you?"], ["I can wait for a turn", "I can choose another block"], ["Let's build one tower together", "Let's build two towers side by side"]]
    private let replies = [["Your friend says, 'Yes, let's make a plan.' Practice asking in your own words.", "Your friend says, 'Yes, there is space here.' Point to a place beside you."], ["Your friend says, 'I will tell you when I am done.' Waiting can be hard; a grown-up can help.", "You find another block. There is more than one way to keep playing."], ["One shared tower! Pretend to add a block, then invite your friend to add one.", "Two towers! Pretend to show your friend what you made."]]
    private var safeStep: Int { min(step, 2) }
    var body: some View {
        ToddlerGameScaffold(title: "Friendship Bridge", prompt: step == 3 ? "Your friendship bridge is ready. You practiced asking and making a plan together!" : stories[safeStep], accent: .teal, completion: step == 3, onReplay: onReplay) {
            HStack(spacing: 10) {
                Image(systemName: "person.fill").font(.system(size: 38)).foregroundStyle(.pink)
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10).fill(index < step || (index == step && response != nil) ? Color.teal : Color.teal.opacity(0.12))
                        .frame(maxWidth: .infinity).frame(height: 35)
                        .overlay { if index < step { Image(systemName: "heart.fill").foregroundStyle(.white) } }
                }
                Image(systemName: "person.fill").font(.system(size: 38)).foregroundStyle(.purple)
            }.frame(height: 140).accessibilityLabel("Friendship bridge, \(step) of 3 conversations")
            if let response {
                BFNote(text: response)
                ToddlerActionButton(title: step == 2 ? "Our bridge is ready" : "We tried the words", systemImage: "arrow.right", color: .teal) {
                    guard step < 3, self.response != nil else { return }
                    step += 1
                    self.response = nil
                }
            } else {
                ForEach(0..<2, id: \.self) { index in
                    ToddlerActionButton(title: choices[safeStep][index], systemImage: "bubble.left.fill", color: .teal) {
                        response = replies[safeStep][index]
                        narrator.speak(response ?? "")
                    }
                }
            }
            BFNote(text: "Practice with puppets or your grown-up. A friend can say no, and you can ask a grown-up for help.")
        }
    }
}

struct CozyEveningPathGame: View {
    let onReplay: () -> Void
    @State private var placed = 0
    @State private var note = "Teddy's plan is wash, pajamas, book, then rest. Your family's plan may be different."
    @StateObject private var narrator = GameNarrator()
    private let names = ["Wash", "Pajamas", "Book", "Rest"]
    private let symbols = ["hands.sparkles.fill", "tshirt.fill", "book.fill", "moon.stars.fill"]
    var body: some View {
        ToddlerGameScaffold(title: "Cozy Evening Path", prompt: placed == 4 ? "Teddy knows what comes next. Time to rest." : "Help Teddy follow the evening plan. Next comes \(names[placed].lowercased()).", accent: .indigo, completion: placed == 4, onReplay: onReplay) {
            HStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { index in
                    VStack {
                        Image(systemName: index < placed ? symbols[index] : "circle.dashed").font(.system(size: 28))
                        Text("\(index + 1)").font(.caption.bold())
                    }.foregroundStyle(.indigo).frame(maxWidth: .infinity, minHeight: 80)
                        .background(.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                        .accessibilityLabel(index < placed ? "Step \(index + 1), \(names[index])" : "Empty step \(index + 1)")
                }
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 118))], spacing: 14) {
                ForEach([2, 0, 3, 1], id: \.self) { index in
                    Button {
                        guard placed < 4 else { return }
                        if index == placed {
                            placed += 1
                            note = ["Splash, splash. Pretend to wash your hands.", "Cozy pajamas. Pretend to pull on a sleeve.", "Share a story. Pretend to turn a page.", "Teddy settles down. Say a gentle good night."][index]
                        } else { note = "For Teddy's plan, \(names[placed].lowercased()) comes next." }
                        narrator.speak(note)
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: symbols[index]).font(.system(size: 43))
                            Text(names[index]).font(.headline)
                        }.foregroundStyle(.indigo).frame(maxWidth: .infinity, minHeight: 120)
                            .background(.white, in: RoundedRectangle(cornerRadius: 23)).opacity(index < placed ? 0.35 : 1)
                    }.buttonStyle(.plain).disabled(index < placed)
                }
            }
            BFNote(text: note)
        }
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
