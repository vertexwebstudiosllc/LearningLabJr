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

private enum BFFeeling: Int, CaseIterable, Identifiable {
    case happy, sad, mad, worried, calm, unsure
    var id: Int { rawValue }
    var name: String { ["Happy", "Sad", "Mad", "Worried", "Calm", "Not sure"][rawValue] }
    var symbol: String { ["sun.max.fill", "cloud.rain.fill", "cloud.bolt.fill", "cloud.fill", "cloud.sun.fill", "questionmark.bubble.fill"][rawValue] }
    var color: Color { [.orange, .blue, .red, .purple, .teal, .indigo][rawValue] }
}

struct TeddyHelpingHandsGame: View {
    let onReplay: () -> Void
    @State private var scene = 0
    @State private var response: String?
    @StateObject private var narrator = GameNarrator()
    private let stories = ["Teddy's tower fell down. Teddy says, 'I feel sad.'", "There is a loud sound. Teddy says, 'I feel worried.'", "Teddy is tired after playing. Teddy wants some space."]
    private let options = [["Ask: would you like help?", "Sit nearby and listen"], ["Find a trusted grown-up", "Offer a quieter place"], ["Make a cozy spot nearby", "Say: I will give you space"]]
    private let responses = [["Teddy says, 'Yes, let's rebuild together.' Pretend to stack three blocks.", "Teddy says, 'Thank you for listening.' Practice sitting nearby without rushing."], ["A trusted grown-up stays with Teddy. Say, 'We are here together.'", "Teddy chooses a quiet corner. Pretend to walk there together."], ["Teddy says, 'Thank you. I can rest here.' Make a little nest with your hands.", "Teddy says, 'Thank you for asking.' Practice a little wave from nearby."]]
    private var safeScene: Int { min(scene, 2) }
    var body: some View {
        ToddlerGameScaffold(title: "Teddy's Helping Hands", prompt: scene == 3 ? "You explored three ways to care for Teddy!" : stories[safeScene], accent: .pink, completion: scene == 3, onReplay: onReplay) {
            Image(systemName: "teddybear.fill").font(.system(size: 135)).foregroundStyle(.brown)
                .frame(height: 165).accessibilityLabel("Teddy")
            HStack(spacing: 16) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < scene ? "heart.fill" : "heart").font(.title).foregroundStyle(.pink)
                }
            }
            if let response {
                BFNote(text: response)
                ToddlerActionButton(title: scene == 2 ? "We cared for Teddy" : "Another Teddy story", systemImage: "heart.fill", color: .pink) {
                    guard scene < 3, self.response != nil else { return }
                    scene += 1
                    self.response = nil
                }
            } else {
                ForEach(0..<2, id: \.self) { index in
                    ToddlerActionButton(title: options[safeScene][index], systemImage: index == 0 ? "hand.raised.fill" : "heart.fill", color: .pink) {
                        response = responses[safeScene][index]
                        narrator.speak(response ?? "")
                    }
                }
            }
            BFNote(text: "There are many ways to help. Ask before hugging or touching someone.")
        }
    }
}

struct RollItTogetherGame: View {
    let onReplay: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var passes = 0
    private var childTurn: Bool { passes.isMultiple(of: 2) }
    var body: some View {
        ToddlerGameScaffold(title: "Roll It Together", prompt: passes == 6 ? "You and your grown-up rolled the ball back and forth three times!" : childTurn ? "Your turn! Tap to roll the ball to your grown-up." : "Grown-up's turn! Roll the ball back to your child.", accent: .orange, completion: passes == 6, onReplay: onReplay) {
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 30).fill(.orange.opacity(0.1))
                    Path { path in
                        path.move(to: CGPoint(x: 65, y: 100))
                        path.addLine(to: CGPoint(x: geometry.size.width - 65, y: 100))
                    }.stroke(.orange.opacity(0.3), style: StrokeStyle(lineWidth: 5, dash: [8, 8]))
                    Image(systemName: "basketball.fill").font(.system(size: 76)).foregroundStyle(.orange)
                        .position(x: childTurn ? 65 : geometry.size.width - 65, y: 100)
                    HStack {
                        Label("You", systemImage: "person.fill")
                        Spacer()
                        Label("Grown-up", systemImage: "person.fill")
                    }.font(.headline).padding(20).offset(y: 74)
                }
            }.frame(height: 220).accessibilityLabel("Ball with \(childTurn ? "you" : "your grown-up")")
            ToddlerActionButton(title: childTurn ? "My turn: roll!" : "Grown-up: roll back!", systemImage: childTurn ? "arrow.right" : "arrow.left", color: .orange) {
                guard passes < 6 else { return }
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.65)) { passes += 1 }
            }
            Text("\(passes / 2) of 3 back-and-forth rolls").font(.headline)
            BFNote(text: "Pass the screen gently or sit side by side. Say 'my turn' and 'your turn' together.")
        }
    }
}

struct WiggleSlowStopGame: View {
    let onReplay: () -> Void
    @State private var step = 0
    private let prompts = ["Green: wiggle your fingers!", "Yellow: move your hands slowly.", "Red: rest your hands for a moment.", "Green: gently wiggle your toes!", "Yellow: make one slow stretch.", "Red: settle into a comfortable pause."]
    private let labels = ["Wiggle", "Slow", "Stop"]
    private let symbols = ["figure.flexibility", "tortoise.fill", "hand.raised.fill"]
    private let colors: [Color] = [.green, .orange, .red]
    private var cue: Int { min(step, 5) % 3 }
    var body: some View {
        ToddlerGameScaffold(title: "Wiggle, Slow, Stop", prompt: step == 6 ? "You practiced wiggling, slowing, and pausing together!" : prompts[min(step, 5)], accent: colors[cue], completion: step == 6, onReplay: onReplay) {
            Image(systemName: symbols[cue]).font(.system(size: 95)).foregroundStyle(.white)
                .frame(width: 190, height: 190).background(colors[cue], in: Circle())
                .accessibilityLabel(labels[cue])
            Text(labels[cue]).font(.system(size: 40, weight: .bold, design: .rounded))
            ToddlerActionButton(title: step == 5 ? "We played together" : "Ready for the next move", systemImage: "arrow.right", color: colors[cue]) { if step < 6 { step += 1 } }
            BFNote(text: "Follow your child's pace. Seated movements work, too. Your grown-up can model every move.")
        }
    }
}

struct FeelingWeatherGame: View {
    let onReplay: () -> Void
    @State private var feeling: BFFeeling?
    @State private var size: String?
    @State private var support: String?
    @StateObject private var narrator = GameNarrator()
    private var prompt: String {
        if feeling == nil { return "What is your feeling weather? You can choose any feeling, or not sure." }
        if size == nil { return "Does your feeling seem little, medium, or big? Every size is okay." }
        if support == nil { return "What would you like right now? Let your grown-up know." }
        return "Thank you for sharing. All feelings are welcome."
    }
    var body: some View {
        ToddlerGameScaffold(title: "My Feeling Weather", prompt: prompt, accent: .purple, completion: support != nil, onReplay: onReplay) {
            Image(systemName: feeling?.symbol ?? "cloud.sun.fill").font(.system(size: 100))
                .foregroundStyle(feeling?.color ?? .purple).frame(height: 140)
                .accessibilityLabel(feeling?.name ?? "Feeling weather")
            if feeling == nil {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 118))], spacing: 12) {
                    ForEach(BFFeeling.allCases) { choice in
                        ToddlerActionButton(title: choice.name, systemImage: choice.symbol, color: choice.color) { feeling = choice }
                    }
                }
            } else if size == nil {
                ForEach(["Little", "Medium", "Big", "Not sure"], id: \.self) { choice in
                    ToddlerActionButton(title: choice, systemImage: "circle.fill", color: feeling?.color ?? .purple) { size = choice }
                }
            } else if support == nil {
                ForEach(["Sit together", "Ask for a hug", "Some quiet space", "Keep playing"], id: \.self) { choice in
                    ToddlerActionButton(title: choice, systemImage: "heart.fill", color: .purple) {
                        support = choice
                        narrator.speak("You chose \(choice.lowercased()). Tell your grown-up.")
                    }
                }
            } else {
                BFNote(text: "My feeling: \(feeling?.name ?? "Not sure")\nIts size: \(size ?? "Not sure")\nI would like: \(support ?? "")")
            }
            BFNote(text: "Grown-up: accept your child's choice. This moment is not saved or scored.")
        }
    }
}

struct KindnessGardenGame: View {
    let onReplay: () -> Void
    @State private var planted: [Int] = []
    @State private var selected: Int?
    @StateObject private var narrator = GameNarrator()
    private let actions = ["Give a friendly wave", "Say or sign thank you", "Offer to help tidy"]
    private let prompts = ["Wave to your grown-up, or show how a puppet could wave.", "Think of someone who helped. Try saying or signing thank you.", "Find a toy nearby and offer to put it away together."]
    private let symbols = ["hand.wave.fill", "heart.fill", "basket.fill"]
    var body: some View {
        ToddlerGameScaffold(title: "Kindness Garden", prompt: planted.count == 3 ? "Three kindness flowers for caring together!" : selected.map { prompts[$0] } ?? "Choose a caring action. Try it together, then plant a flower.", accent: .green, completion: planted.count == 3, onReplay: onReplay) {
            HStack(alignment: .bottom, spacing: 20) {
                ForEach(0..<3, id: \.self) { index in
                    VStack(spacing: 0) {
                        Image(systemName: index < planted.count ? "camera.macro" : "leaf.fill")
                            .font(.system(size: index < planted.count ? 56 : 32))
                            .foregroundStyle(index < planted.count ? [Color.pink, .orange, .purple][index] : .green.opacity(0.4))
                        RoundedRectangle(cornerRadius: 3).fill(.green).frame(width: 7, height: index < planted.count ? 62 : 20)
                        Ellipse().fill(.brown.opacity(0.5)).frame(width: 65, height: 18)
                    }.frame(maxWidth: .infinity)
                }
            }.frame(height: 180).accessibilityLabel("\(planted.count) of 3 kindness flowers")
            if let selected {
                ToddlerActionButton(title: "Plant our kindness flower", systemImage: "leaf.fill", color: .green) {
                    guard planted.count < 3, !planted.contains(selected) else { return }
                    planted.append(selected)
                    self.selected = nil
                    narrator.speak("A flower for caring together.")
                }
            } else {
                ForEach(0..<3, id: \.self) { index in
                    ToddlerActionButton(title: actions[index], systemImage: symbols[index], color: .green) { selected = index }
                        .disabled(planted.contains(index))
                }
            }
            BFNote(text: "Pretending counts, too. Kindness can be a wave, a word, or help; it never requires a hug.")
        }
    }
}

struct CozyToolboxGame: View {
    let onReplay: () -> Void
    @State private var tool: Int?
    @State private var tried: Set<Int> = []
    @StateObject private var narrator = GameNarrator()
    private let names = ["Gentle hand press", "Listen together", "Cozy stretch"]
    private let symbols = ["hands.clap.fill", "ear.fill", "figure.flexibility"]
    private let instructions = ["Gently press your palms together, then let go. Try it once with your grown-up.", "Pause together. Listen for a sound nearby. Point or tell your grown-up what you hear.", "Reach your hands up as comfortably as you like, then let them rest. A tiny stretch is welcome."]
    var body: some View {
        ToddlerGameScaffold(title: "My Cozy Toolbox", prompt: tried.count == 3 ? "You explored three tools for a cozy pause!" : tool.map { instructions[$0] } ?? "Choose a tool to try together. Notice what feels comfortable for you.", accent: .indigo, completion: tried.count == 3, onReplay: onReplay) {
            Image(systemName: tool.map { symbols[$0] } ?? "shippingbox.fill").font(.system(size: 100)).foregroundStyle(.indigo).frame(height: 145)
            if let tool {
                ToddlerActionButton(title: "We explored this tool", systemImage: "checkmark", color: .indigo) {
                    tried.insert(tool)
                    self.tool = nil
                    narrator.speak("You explored one way to pause together.")
                }
                ToddlerActionButton(title: "Watch my grown-up try", systemImage: "person.fill", color: .purple) {
                    tried.insert(tool)
                    self.tool = nil
                }
            } else {
                ForEach(0..<3, id: \.self) { index in
                    ToddlerActionButton(title: names[index] + (tried.contains(index) ? " · explored" : ""), systemImage: symbols[index], color: .indigo) { tool = index }
                        .disabled(tried.contains(index))
                }
            }
            Text("\(tried.count) of 3 tools explored").font(.headline)
            BFNote(text: "A tool does not have to change a feeling. Your grown-up can help you decide what feels good.")
        }
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
