import SwiftUI

private struct StoryPiece: Identifiable {
    let id: String
    let title: String
    let asset: String?
    let symbol: String
    init(_ id: String, _ title: String, asset: String? = nil, symbol: String = "star.fill") {
        self.id = id; self.title = title; self.asset = asset; self.symbol = symbol
    }
}

private struct StoryPictureChoice: View {
    let piece: StoryPiece
    var selected = false
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ToddlerArt(asset: piece.asset, symbol: piece.symbol, size: 80)
                Text(piece.title).font(.system(.headline, design: .rounded)).multilineTextAlignment(.center)
            }.foregroundStyle(Color(red: 0.13, green: 0.21, blue: 0.27)).frame(maxWidth: .infinity, minHeight: 130).padding(10)
                .background(selected ? Color.purple.opacity(0.14) : Color.white, in: RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(selected ? Color.purple : Color.purple.opacity(0.16), lineWidth: selected ? 4 : 2))
        }.buttonStyle(.plain).accessibilityLabel(piece.title)
            .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct StorySequenceGame: View {
    private let routines = [
        [StoryPiece("wash", "Wash hands", symbol: "hands.sparkles.fill"), StoryPiece("eat", "Eat lunch", symbol: "fork.knife"), StoryPiece("clean", "Clear the table", symbol: "sparkles")],
        [StoryPiece("shirt", "Put on a shirt", symbol: "tshirt.fill"), StoryPiece("shoes", "Put on shoes", symbol: "shoe.2.fill"), StoryPiece("walk", "Go for a walk", symbol: "figure.walk")],
        [StoryPiece("bath", "Have a bath", symbol: "bathtub.fill"), StoryPiece("book", "Read a book", symbol: "book.fill"), StoryPiece("bed", "Go to bed", symbol: "bed.double.fill")]
    ]
    @State private var round = 0
    @State private var placed = 0
    @State private var choiceOrder = [2, 0, 1]
    @StateObject private var narrator = GameNarrator()
    private var complete: Bool { round == 3 }
    private var prompt: String {
        if complete { return "You told three little stories in order!" }
        if placed == 3 { return routines[round].map(\.title).joined(separator: ". ") + "." }
        return ["What happens first?", "What happens next?", "What happens last?"][placed]
    }
    var body: some View {
        ToddlerGameScaffold(title: "First, Next, Last", prompt: prompt, accent: .purple, completion: complete, onReplay: { round = 0; placed = 0; choiceOrder.shuffle() }) {
            if !complete {
                Text("Our \(["lunchtime", "going outside", "bedtime"][round]) story").font(.title3.bold())
                VStack(spacing: 10) {
                    ForEach(0..<3) { index in
                        HStack(spacing: 16) {
                            Text(["First", "Next", "Last"][index]).font(.headline).frame(width: 54)
                            if index < placed {
                                ToddlerArt(symbol: routines[round][index].symbol, size: 45)
                                Text(routines[round][index].title).font(.headline)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.purple)
                            } else { Text("…").font(.largeTitle); Spacer() }
                        }.padding(12).frame(minHeight: 72).background(Color.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
                    }
                }
                if placed == 3 {
                    ToddlerActionButton(title: round == 2 ? "Finish our stories" : "Another little story", systemImage: "arrow.right", color: .purple) {
                        guard placed == 3, !complete else { return }
                        round += 1; placed = 0; choiceOrder.shuffle()
                    }
                } else {
                    ForEach(choiceOrder, id: \.self) { index in
                        if index >= placed {
                            StoryPictureChoice(piece: routines[round][index]) {
                                guard round < routines.count, placed < 3 else { return }
                                if index == placed { placed += 1 }
                                else { narrator.speak("In our story, we \(routines[round][placed].title.lowercased()) \(placed == 0 ? "first" : "next").") }
                            }
                        }
                    }
                }
            }
        }.onDisappear { narrator.stop() }
    }
}

struct PuppetFriendsGame: View {
    @State private var turn = 0
    @State private var performed = false
    @State private var complete = false
    @StateObject private var narrator = GameNarrator()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let lines = [("dog", "Dog", "Hello, Cat! Would you like to play?"), ("cat", "Cat", "Hello, Dog! Yes, let’s roll a ball."), ("dog", "Dog", "Here comes the ball. Your turn!"), ("cat", "Cat", "Thank you! I’ll roll it back."), ("dog", "Dog", "That was fun. Goodbye, Cat!"), ("cat", "Cat", "Goodbye, Dog. See you soon!")]
    var body: some View {
        ToddlerGameScaffold(title: "Puppet Friends", prompt: complete ? "You helped two friends tell a story!" : "It is \(lines[turn].1)’s turn. Tap the puppet and try its voice.", accent: .purple, completion: complete, onReplay: { turn = 0; performed = false; complete = false }) {
            HStack(alignment: .bottom, spacing: 16) {
                puppet("dog", name: "Dog")
                puppet("cat", name: "Cat")
            }.padding(20).background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 28))
            if performed {
                Text(lines[turn].2).font(.system(.title3, design: .rounded)).multilineTextAlignment(.center)
                Text("Pause and make up your own reply together.").foregroundStyle(.secondary).multilineTextAlignment(.center)
                ToddlerActionButton(title: turn == 5 ? "End puppet show" : "Next friend’s turn", systemImage: "arrow.right", color: .purple) {
                    guard performed, !complete else { return }
                    if turn == 5 { complete = true } else { turn += 1; performed = false }
                }
            }
        }.onDisappear { narrator.stop() }
    }
    private func puppet(_ asset: String, name: String) -> some View {
        Button {
            guard !complete else { return }
            guard lines[turn].0 == asset else { narrator.speak("It is \(lines[turn].1)’s turn. Your turn is coming."); return }
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { performed = true }
            narrator.speak(lines[turn].2)
        } label: {
            VStack {
                ToddlerArt(asset: asset, size: 105).offset(y: performed && lines[turn].0 == asset && !reduceMotion ? -12 : 0)
                RoundedRectangle(cornerRadius: 5).fill(Color.brown).frame(width: 12, height: 55)
                Text(name).font(.headline)
                if lines[turn].0 == asset { Label("Your turn", systemImage: "hand.wave.fill").font(.subheadline.bold()) }
            }.frame(maxWidth: .infinity, minHeight: 225).foregroundStyle(.purple)
        }.buttonStyle(.plain).accessibilityLabel("\(name) puppet\(lines[turn].0 == asset ? ", your turn" : "")")
    }
}

struct FinishSentenceGame: View {
    private let sentences = [
        ("When I am thirsty, I drink from a…", "cup", "When I am thirsty, I drink from a cup.", [StoryPiece("shoe", "Shoe", symbol: "shoe.fill"), StoryPiece("cup", "Cup", symbol: "cup.and.saucer.fill"), StoryPiece("ball", "Ball", asset: "basketball")]),
        ("When it rains, I stay dry under an…", "umbrella", "When it rains, I stay dry under an umbrella.", [StoryPiece("umbrella", "Umbrella", symbol: "umbrella.fill"), StoryPiece("apple", "Apple", asset: "Apple"), StoryPiece("book", "Book", symbol: "book.fill")]),
        ("At bedtime, I get cozy in my…", "bed", "At bedtime, I get cozy in my bed.", [StoryPiece("car", "Car", asset: "carBlue"), StoryPiece("ball", "Ball", asset: "basketball"), StoryPiece("bed", "Bed", symbol: "bed.double.fill")])
    ]
    @State private var round = 0
    @State private var answered = false
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Finish My Sentence", prompt: round == 3 ? "You helped finish three sentences!" : answered ? sentences[round].2 : sentences[round].0, accent: .purple, completion: round == 3, onReplay: { round = 0; answered = false }) {
            if round < 3 {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 128))], spacing: 14) {
                    ForEach(sentences[round].3) { piece in
                        StoryPictureChoice(piece: piece, selected: answered && piece.id == sentences[round].1) {
                            guard round < sentences.count, !answered else { return }
                            if piece.id == sentences[round].1 { answered = true }
                            else { narrator.speak("A \(piece.title.lowercased())? Let’s listen again. \(sentences[round].0)") }
                        }.disabled(answered)
                    }
                }
                if answered {
                    ToddlerActionButton(title: round == 2 ? "All sentences finished" : "Another sentence", systemImage: "arrow.right", color: .purple) {
                        guard answered, round < sentences.count else { return }
                        round += 1; answered = false
                    }
                }
            }
        }.onDisappear { narrator.stop() }
    }
}

struct NoisyStoryGame: View {
    private let scenes: [(String, [StoryPiece], [String])] = [
        ("Duck wakes up at the farm. Who does Duck hear?", [StoryPiece("duck", "Duck", asset: "duck"), StoryPiece("cow", "Cow", asset: "cow")], ["Quack, quack! Good morning, says Duck.", "Moo, moo! Good morning, says Cow."]),
        ("Duck walks to the pond. Rain starts to fall.", [StoryPiece("rain", "Raindrops", symbol: "cloud.rain.fill"), StoryPiece("water", "Puddle", symbol: "water.waves")], ["Pitter patter, pitter patter. Rain taps on the leaves.", "Splish, splash! Duck steps in a puddle."]),
        ("The rain stops. Duck takes a ride home.", [StoryPiece("tractor", "Tractor", asset: "tractor"), StoryPiece("duck", "Duck", asset: "duck")], ["Chug, chug, chug! The tractor takes Duck home.", "Quack, quack! What a noisy day, says Duck."])
    ]
    @State private var page = 0
    @State private var heard: Set<String> = []
    @State private var caption = ""
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "A Noisy Little Story", prompt: page == 3 ? "Quack, moo, splash, and chug! You brought our story to life." : scenes[page].0 + " Tap both story pictures.", accent: .purple, completion: page == 3, onReplay: { page = 0; heard = []; caption = "" }) {
            if page < 3 {
                ForEach(scenes[page].1.indices, id: \.self) { index in
                    StoryPictureChoice(piece: scenes[page].1[index], selected: heard.contains(scenes[page].1[index].id)) {
                        guard page < scenes.count else { return }
                        heard.insert(scenes[page].1[index].id)
                        caption = scenes[page].2[index]
                        narrator.speak(caption)
                    }
                }
                Text(caption).font(.headline).multilineTextAlignment(.center)
                if heard.count == 2 {
                    ToddlerActionButton(title: page == 2 ? "The end" : "Turn the page", systemImage: "book.fill", color: .purple) {
                        guard heard.count == 2, page < scenes.count else { return }
                        page += 1; heard = []; caption = ""
                    }
                }
            }
        }.onDisappear { narrator.stop() }
    }
}

struct StoryBagGame: View {
    private let bags = [[StoryPiece("rabbit", "Bunny", asset: "rabbit"), StoryPiece("ball", "a ball", asset: "basketball"), StoryPiece("moon", "the Moon", asset: "Space/Moon")], [StoryPiece("duck", "Duck", asset: "duck"), StoryPiece("apple", "an apple", asset: "Apple"), StoryPiece("car", "a car", asset: "carBlue")]]
    @State private var bag = 0
    @State private var revealed = 0
    @State private var complete = false
    var body: some View {
        ToddlerGameScaffold(title: "The Story Bag", prompt: complete ? "A story only you could tell!" : revealed == 0 ? "Open the bag to meet your story character." : revealed == 1 ? "Who is \(bags[bag][0].title)? Open the bag for a story prop." : revealed == 2 ? "What will happen with \(bags[bag][1].title)? Open the last surprise." : "Tell a tiny story using your three surprises. Point, talk, or make sounds together.", accent: .purple, completion: complete, onReplay: { bag = (bag + 1) % bags.count; revealed = 0; complete = false }) {
            ForEach(0..<revealed, id: \.self) { index in
                HStack(spacing: 20) {
                    ToddlerArt(asset: bags[bag][index].asset, size: 70)
                    Text(bags[bag][index].title).font(.title3.bold())
                    Spacer()
                }.padding(14).background(Color.purple.opacity(0.07), in: RoundedRectangle(cornerRadius: 22))
            }
            if revealed < 3 {
                Button { revealed = min(revealed + 1, 3) } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "bag.fill").font(.system(size: 110))
                        Text("Open a surprise").font(.title3.bold())
                    }.frame(maxWidth: .infinity, minHeight: 200).foregroundStyle(.purple)
                }.buttonStyle(.plain).accessibilityLabel("Open story surprise \(revealed + 1)")
            } else {
                Text("Once upon a time, \(bags[bag][0].title) found \(bags[bag][1].title)…").font(.title3).multilineTextAlignment(.center)
                ToddlerActionButton(title: "We told our story", systemImage: "text.bubble.fill", color: .purple) { complete = true }
            }
        }
    }
}

struct SillyStoryGame: View {
    private let scenes: [(String, StoryPiece, StoryPiece, StoryPiece, String)] = [
        ("Bunny is trying to eat lunch with a shoe! Tap the silly shoe.", StoryPiece("shoe", "Shoe", symbol: "shoe.fill"), StoryPiece("fork", "Fork", symbol: "fork.knife"), StoryPiece("ball", "Ball", asset: "basketball"), "A fork helps Bunny eat lunch."),
        ("Bunny is trying to bounce an apple! Tap the silly apple.", StoryPiece("apple", "Apple", asset: "Apple"), StoryPiece("ball", "Ball", asset: "basketball"), StoryPiece("book", "Book", symbol: "book.fill"), "A ball is fun to bounce."),
        ("Bunny is using a book to dry off after a bath! Tap the silly book.", StoryPiece("book", "Book", symbol: "book.fill"), StoryPiece("towel", "Towel", symbol: "rectangle.fill"), StoryPiece("cup", "Cup", symbol: "cup.and.saucer.fill"), "A towel helps Bunny dry off.")
    ]
    @State private var round = 0
    @State private var removed = false
    @State private var fixed = false
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Silly Story Fixer", prompt: round == 3 ? "You fixed three silly stories!" : fixed ? scenes[round].4 : removed ? "What could Bunny use instead?" : scenes[round].0, accent: .purple, completion: round == 3, onReplay: { round = 0; removed = false; fixed = false }) {
            if round < 3 {
                ToddlerArt(asset: "rabbit", size: 120)
                if fixed {
                    ToddlerArt(asset: scenes[round].2.asset, symbol: scenes[round].2.symbol, size: 110)
                    ToddlerActionButton(title: round == 2 ? "The end" : "Another silly story", systemImage: "arrow.right", color: .purple) {
                        guard fixed, round < scenes.count else { return }
                        round += 1; removed = false; fixed = false
                    }
                } else if removed {
                    HStack {
                        choice(round == 1 ? scenes[round].3 : scenes[round].2)
                        choice(round == 1 ? scenes[round].2 : scenes[round].3)
                    }
                } else { StoryPictureChoice(piece: scenes[round].1) { removed = true } }
            }
        }.onDisappear { narrator.stop() }
    }
    private func choice(_ piece: StoryPiece) -> some View {
        StoryPictureChoice(piece: piece) {
            guard round < scenes.count, !fixed else { return }
            if piece.id == scenes[round].2.id { fixed = true }
            else { narrator.speak("That might be silly too. \(scenes[round].4)") }
        }
    }
}

struct BunnyPositionGame: View {
    @State private var round = 0
    @State private var position: Int? = nil
    @State private var correct = false
    @StateObject private var narrator = GameNarrator()
    private let words = ["in", "on", "beside"]
    var body: some View {
        ToddlerGameScaffold(title: "Where Is Bunny?", prompt: round == 3 ? "Bunny went in, on, and beside the box!" : correct ? "Bunny is \(words[round]) the box." : "Put Bunny \(words[round]) the box. Tap a landing spot.", accent: .purple, completion: round == 3, onReplay: { round = 0; position = nil; correct = false }) {
            if round < 3 {
                HStack(alignment: .bottom, spacing: 12) {
                    VStack(spacing: 0) {
                        landing(1)
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.brown.opacity(0.25))
                                .frame(maxWidth: .infinity, minHeight: 135)
                                .overlay(alignment: .top) {
                                    Capsule().fill(Color.brown).frame(height: 8)
                                }
                            landing(0)
                        }
                    }.frame(maxWidth: .infinity)
                    landing(2)
                }.padding(16).background(Color.purple.opacity(0.06), in: RoundedRectangle(cornerRadius: 26))
                if correct {
                    ToddlerActionButton(title: round == 2 ? "Bunny is all done" : "Another hiding place", systemImage: "arrow.right", color: .purple) {
                        guard correct, round < words.count else { return }
                        round += 1; position = nil; correct = false
                    }
                } else if position == nil { ToddlerArt(asset: "rabbit", size: 90) }
            }
        }.onDisappear { narrator.stop() }
    }
    private func landing(_ index: Int) -> some View {
        Button {
            guard round < words.count, !correct else { return }
            position = index
            if index == round { correct = true }
            else { narrator.speak("Bunny is \(words[index]) the box. Can you put Bunny \(words[round]) the box?") }
        } label: {
            VStack(spacing: 6) {
                Text(words[index].capitalized).font(.headline).foregroundStyle(.purple)
                if position == index { ToddlerArt(asset: "rabbit", size: 70) }
                else { Image(systemName: "circle.dashed").font(.system(size: 48)).foregroundStyle(.purple.opacity(0.55)) }
            }.frame(maxWidth: .infinity, minHeight: 116, alignment: .bottom)
                .contentShape(Rectangle())
        }.buttonStyle(.plain).disabled(correct).accessibilityLabel("Put Bunny \(words[index]) the box")
    }
}

struct PicnicChatGame: View {
    private let turns: [(String, [StoryPiece], [String])] = [
        ("Bunny says, Hello! I am happy to see you. What could you say?", [StoryPiece("hello", "Hello, Bunny!", symbol: "hand.wave.fill"), StoryPiece("wave", "Give a wave", symbol: "hand.raised.fill")], ["Hello, friend! Come sit with me.", "I see your wave! Come sit with me."]),
        ("Bunny asks, Would you like an apple or some bread?", [StoryPiece("apple", "Apple, please", asset: "Apple"), StoryPiece("bread", "Bread, please", asset: "Bread")], ["Here is an apple for you. Crunch, crunch!", "Here is some bread for you. Yum!"]),
        ("Bunny asks, What would you like to do after our picnic?", [StoryPiece("ball", "Play with a ball", asset: "basketball"), StoryPiece("book", "Read a book", symbol: "book.fill")], ["Let’s take turns rolling the ball.", "Let’s look at a book together."]),
        ("Bunny says, It is time for me to go home. What could you say?", [StoryPiece("bye", "Goodbye, Bunny!", symbol: "hand.wave.fill"), StoryPiece("thanks", "Thank you for the picnic", symbol: "heart.fill")], ["Goodbye! I enjoyed our picnic.", "You are welcome. I enjoyed our picnic too!"])
    ]
    @State private var turn = 0
    @State private var reply: String? = nil
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Picnic Chat", prompt: turn == 4 ? "You took turns talking with Bunny!" : reply ?? turns[turn].0, accent: .purple, completion: turn == 4, onReplay: { turn = 0; reply = nil }) {
            ToddlerArt(asset: "rabbit", size: 140)
            if turn < 4 {
                if reply == nil {
                    Text("Say it, point, or choose a picture.").foregroundStyle(.secondary)
                    ForEach(turns[turn].1.indices, id: \.self) { index in
                        StoryPictureChoice(piece: turns[turn].1[index]) {
                            guard turn < turns.count, reply == nil else { return }
                            reply = turns[turn].2[index]
                        }
                    }
                } else {
                    ToddlerActionButton(title: turn == 3 ? "Finish our chat" : "Keep chatting", systemImage: "bubble.left.and.bubble.right.fill", color: .purple) {
                        guard reply != nil, turn < turns.count else { return }
                        turn += 1; reply = nil
                    }
                }
            }
        }.onDisappear { narrator.stop() }
    }
}

struct ChooseAdventureGame: View {
    @State private var choices: [Int] = []
    @State private var complete = false
    private var prompt: String {
        if complete { return "The end. Your choices made a special adventure!" }
        switch choices.count {
        case 0: return "Bunny is ready for an adventure. Where should Bunny go?"
        case 1: return "At the \(choices[0] == 0 ? "pond" : "garden"), Bunny meets a friend. Who is there?"
        case 2: return "Bunny and \(choices[1] == 0 ? "Duck" : "Cat") want to do something together. What happens next?"
        default: return story
        }
    }
    private var story: String {
        guard choices.count == 3 else { return "" }
        return "Bunny went to the \(choices[0] == 0 ? "pond" : "garden"). Bunny met \(choices[1] == 0 ? "Duck" : "Cat"). They \(choices[2] == 0 ? "shared a picnic" : "played with a ball"). Then Bunny went home with a happy memory."
    }
    private var pieces: [StoryPiece] {
        switch choices.count {
        case 0: [StoryPiece("pond", "The pond", symbol: "water.waves"), StoryPiece("garden", "The garden", symbol: "leaf.fill")]
        case 1: [StoryPiece("duck", "Duck", asset: "duck"), StoryPiece("cat", "Cat", asset: "cat")]
        default: [StoryPiece("picnic", "Share a picnic", asset: "Apple"), StoryPiece("ball", "Play ball", asset: "basketball")]
        }
    }
    var body: some View {
        ToddlerGameScaffold(title: "Choose Our Adventure", prompt: prompt, accent: .purple, completion: complete, onReplay: { choices = []; complete = false }) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 86), spacing: 12)], spacing: 12) {
                ToddlerArt(asset: "rabbit", size: 85)
                if !choices.isEmpty { ToddlerArt(symbol: choices[0] == 0 ? "water.waves" : "leaf.fill", size: 75) }
                if choices.count > 1 { ToddlerArt(asset: choices[1] == 0 ? "duck" : "cat", size: 85) }
            }.frame(maxWidth: .infinity).padding(16).background(Color.green.opacity(0.09), in: RoundedRectangle(cornerRadius: 24))
            if choices.count < 3 {
                let displayedBranch = choices.count
                ForEach(pieces.indices, id: \.self) { index in
                    StoryPictureChoice(piece: pieces[index]) {
                        guard choices.count == displayedBranch, !complete else { return }
                        choices.append(index)
                    }
                }
            } else if !complete {
                ToddlerArt(asset: choices[2] == 0 ? "Apple" : "basketball", size: 110)
                ToddlerActionButton(title: "The end", systemImage: "book.closed.fill", color: .purple) { complete = true }
            }
        }
    }
}

struct SentenceBuilderGame: View {
    private let sets = [
        [StoryPiece("rabbit", "Bunny", asset: "rabbit"), StoryPiece("dog", "Dog", asset: "dog"), StoryPiece("cat", "Cat", asset: "cat")],
        [StoryPiece("finds", "finds", symbol: "magnifyingglass"), StoryPiece("carries", "carries", symbol: "hand.raised.fill"), StoryPiece("looks", "looks at", symbol: "eye.fill")],
        [StoryPiece("apple", "an apple", asset: "Apple"), StoryPiece("ball", "a ball", asset: "basketball"), StoryPiece("book", "a book", symbol: "book.fill")]
    ]
    @State private var words: [Int] = []
    @State private var complete = false
    private var sentence: String { words.enumerated().map { sets[$0.offset][$0.element].title }.joined(separator: " ") + "." }
    private var prompt: String {
        if complete { return "You made a sentence! \(sentence)" }
        return words.count == 3 ? sentence : ["Choose who is in your sentence.", "Choose what they do.", "Choose the thing in your sentence."][words.count]
    }
    var body: some View {
        ToddlerGameScaffold(title: "Make a Sentence", prompt: prompt, accent: .purple, completion: complete, onReplay: { words = []; complete = false }) {
            VStack(spacing: 10) {
                ForEach(words.indices, id: \.self) { index in
                    HStack(spacing: 16) {
                        ToddlerArt(asset: sets[index][words[index]].asset, symbol: sets[index][words[index]].symbol, size: 60)
                        Text(sets[index][words[index]].title).font(.title3.bold())
                        Spacer()
                    }.padding(12).background(Color.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
                }
            }
            if words.count < 3 {
                let displayedWord = words.count
                ForEach(sets[displayedWord].indices, id: \.self) { index in
                    StoryPictureChoice(piece: sets[displayedWord][index]) {
                        guard words.count == displayedWord, !complete else { return }
                        words.append(index)
                    }
                }
            } else if !complete {
                Text("Act out your sentence together.").font(.headline)
                ToddlerActionButton(title: "We told our sentence", systemImage: "checkmark", color: .purple) { complete = true }
            }
            if !words.isEmpty && !complete {
                ToddlerActionButton(title: "Change the last word", systemImage: "arrow.uturn.backward", color: .purple) { _ = words.popLast() }
            }
        }
    }
}
