import SwiftUI

struct MoonMissionGame: View {
    @State private var step = 0
    private let prompts = ["We are on Earth. Put on a spacesuit for our pretend trip.", "The spacesuit is on. Tap the rocket to launch.", "We are traveling in space. Tap the Moon to land.", "We landed! Tap the astronaut to explore.", "Time to go home. Tap Earth.", "Welcome home to Earth! The Moon is our nearest neighbor in space."]
    private let actions = [("Put on spacesuit", "Space/SpaceSuit"), ("Launch rocket", "Space/Rocket"), ("Land on the Moon", "Space/Moon"), ("Explore the Moon", "Space/Spaceman_Child_1"), ("Return to Earth", "Space/Earth")]

    var body: some View {
        ToddlerGameScaffold(title: "Moon Mission", prompt: prompts[step], accent: .indigo, completion: step == 5, onReplay: { step = 0 }) {
            HStack {
                ToddlerArt(asset: "Space/Earth", size: 82)
                Image(systemName: "arrow.left.arrow.right").font(.largeTitle).foregroundStyle(.indigo)
                ToddlerArt(asset: "Space/Moon", size: 82)
            }
            if step < 5 {
                NaturePictureButton(title: actions[step].0, asset: actions[step].1) { step = min(step + 1, 5) }
                Text("Pretend adventure • Step \(step + 1) of 5").foregroundStyle(.secondary)
            }
        }
    }
}

struct NatureBarnGame: View {
    private let animals = [("cow", "Cow", "Moo, moo!"), ("duck", "Duck", "Quack, quack!"), ("sheep", "Sheep", "Baa, baa!"), ("pig", "Pig", "Oink, oink!")]
    @State private var round = 0
    @State private var open = false
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ToddlerGameScaffold(title: "Peekaboo Barnyard", prompt: round == 4 ? "You met four farm friends!" : open ? "It’s a \(animals[round].1.lowercased())! \(animals[round].2) Can you make that sound?" : "Who is in the barn? Open the doors.", completion: round == 4, onReplay: { round = 0; open = false }) {
            if round < 4 {
                Button {
                    guard round < animals.count else { return }
                    if open { narrator.speak("\(animals[round].1). \(animals[round].2)") }
                    else { open = true }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28).fill(Color.orange.opacity(0.12))
                        if open { ToddlerArt(asset: animals[round].0, size: 170) }
                        else {
                            HStack(spacing: 3) {
                                Image("barnDoorLeft").resizable().scaledToFit()
                                Image("barnDoorRight").resizable().scaledToFit()
                            }.padding(20)
                        }
                    }.frame(height: 250)
                }.buttonStyle(.plain).accessibilityLabel(open ? "Hear the \(animals[round].1.lowercased()) again" : "Open barn doors")
                if open {
                    ToddlerActionButton(title: round == 3 ? "Say goodbye" : "Meet another friend", systemImage: "hand.wave.fill", color: .orange) {
                        guard open, round < animals.count else { return }
                        round += 1; open = false
                    }
                }
            }
        }.onDisappear { narrator.stop() }
    }
}

struct LittleGardenGame: View {
    @State private var step = 0
    private let prompts = ["A seed can grow into a plant. Tap to put it in the pot.", "Cover the seed with a little soil.", "Give the seed a little water.", "Put the pot near sunlight.", "Growing takes many days. Pretend to wait as the days pass.", "A little plant has grown! Keep giving it the care it needs."]
    private let tools = [("Plant a seed", "circle.fill"), ("Add soil", "square.stack.3d.up.fill"), ("Water gently", "drop.fill"), ("Find sunlight", "sun.max.fill"), ("Days pass", "calendar")]
    var body: some View {
        ToddlerGameScaffold(title: "Little Garden", prompt: prompts[step], accent: .green, completion: step == 5, onReplay: { step = 0 }) {
            VStack(spacing: 0) {
                Image(systemName: step == 5 ? "leaf.fill" : step >= 4 ? "sun.max.fill" : step >= 3 ? "drop.fill" : "circle.fill")
                    .font(.system(size: step == 5 ? 95 : 52)).foregroundStyle(step == 5 ? Color.green : step >= 4 ? .orange : step == 3 ? .blue : .brown)
                    .frame(height: 120)
                UnevenRoundedRectangle(bottomLeadingRadius: 38, bottomTrailingRadius: 38)
                    .fill(Color.brown.opacity(0.7)).frame(width: 160, height: 105)
            }.accessibilityLabel(step == 5 ? "A leafy plant in a pot" : "A flower pot")
            if step < 5 {
                NaturePictureButton(title: tools[step].0, symbol: tools[step].1) { step = min(step + 1, 5) }
            }
        }
    }
}

struct OceanHelpersGame: View {
    @State private var collected: Set<Int> = []
    @StateObject private var narrator = GameNarrator()
    private let pieces: [(String, String?, String, Bool)] = [
        ("Sea turtle", "turtle", "leaf.fill", false), ("Plastic bottle", nil, "waterbottle.fill", true),
        ("Paper bag", nil, "bag.fill", true), ("Dolphin", "dolphin", "leaf.fill", false),
        ("Crab", "crab", "leaf.fill", false), ("Empty can", nil, "cylinder.fill", true)
    ]
    var body: some View {
        ToddlerGameScaffold(title: "Ocean Helpers", prompt: collected.count == 3 ? "The ocean is clear. The animals can stay in their home!" : "Tap the litter to put it in the bin. Leave the sea animals swimming.", accent: .blue, completion: collected.count == 3, onReplay: { collected = [] }) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(pieces.indices, id: \.self) { index in
                    if collected.contains(index) {
                        Image(systemName: "water.waves").font(.largeTitle).foregroundStyle(.blue.opacity(0.35))
                            .frame(maxWidth: .infinity, minHeight: 148).accessibilityLabel("Clear water")
                    } else {
                        NaturePictureButton(title: pieces[index].0, asset: pieces[index].1, symbol: pieces[index].2) {
                            if pieces[index].3 { collected.insert(index) }
                            else { narrator.speak("The \(pieces[index].0.lowercased()) belongs in the ocean. Look for litter.") }
                        }
                    }
                }
            }
            Label("\(collected.count) pieces in the bin", systemImage: "trash.fill").font(.headline).foregroundStyle(.blue)
        }.onDisappear { narrator.stop() }
    }
}

struct WeatherWindowGame: View {
    @State private var weather = 0
    @State private var observation = ""
    @State private var explored: Set<Int> = []
    @State private var complete = false
    @StateObject private var narrator = GameNarrator()
    private let types = [("Sunshine", "sun.max.fill", "The Sun gives us light. Make a big circle with your arms."), ("Rain", "cloud.rain.fill", "Rain falls from clouds. Pat your knees like raindrops."), ("Wind", "wind", "Wind is moving air. Sway like a tree in the breeze.")]
    var body: some View {
        ToddlerGameScaffold(title: "Weather Window", prompt: complete ? "You explored sunshine, rain, and wind!" : "Change the weather window. Tap inside to explore what happens.", accent: .cyan, completion: complete, onReplay: { weather = 0; explored = []; observation = ""; complete = false }) {
            Button {
                explored.insert(weather)
                observation = types[weather].2
                narrator.speak(observation)
            } label: {
                VStack(spacing: 20) {
                    Image(systemName: types[weather].1).font(.system(size: 100)).foregroundStyle(weather == 0 ? Color.orange : .blue)
                    Image(systemName: "tree.fill").font(.system(size: 70)).foregroundStyle(.green)
                    Text(types[weather].0).font(.title2.bold()).foregroundStyle(Color(red: 0.13, green: 0.21, blue: 0.27))
                }.frame(maxWidth: .infinity, minHeight: 300)
                    .background(Color.cyan.opacity(0.10), in: RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.brown.opacity(0.6), lineWidth: 8))
            }.buttonStyle(.plain).accessibilityLabel("Explore \(types[weather].0.lowercased())")
            HStack(spacing: 10) {
                ForEach(0..<3) { index in
                    Button {
                        weather = index
                        observation = ""
                        narrator.speak("\(types[index].0). Tap the window to explore.")
                    } label: {
                        VStack {
                            Image(systemName: types[index].1).font(.title)
                            Text(types[index].0).font(.system(.subheadline, design: .rounded)).bold()
                            if explored.contains(index) { Image(systemName: "checkmark.circle.fill") }
                        }.frame(maxWidth: .infinity, minHeight: 94)
                            .foregroundStyle(weather == index ? Color.white : .blue)
                            .background(weather == index ? Color.blue : Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))
                    }.buttonStyle(.plain).accessibilityLabel(types[index].0)
                }
            }
            Text(observation).font(.headline).multilineTextAlignment(.center)
            if explored.count == 3 { ToddlerActionButton(title: "Finish exploring", systemImage: "checkmark", color: .blue) { complete = true } }
        }.onDisappear { narrator.stop() }
    }
}

struct AnimalMovementGame: View {
    @State private var round = 0
    private let moves = [("rabbit", "A rabbit hops. Bounce your hands or hop together.", "We hopped!"), ("penguin", "A penguin waddles. Rock gently from side to side.", "We waddled!"), ("dolphin", "A dolphin swims. Sweep your arms like swimming flippers.", "We swam!")]
    var body: some View {
        ToddlerGameScaffold(title: "Move Like an Animal", prompt: round == 3 ? "You moved like three animals!" : moves[round].1, completion: round == 3, onReplay: { round = 0 }) {
            if round < 3 {
                ToddlerArt(asset: moves[round].0, size: 200)
                Text("Move with a grown-up. Seated movements are welcome.").font(.headline).multilineTextAlignment(.center)
                ToddlerActionButton(title: moves[round].2, systemImage: "checkmark.circle.fill") { round = min(round + 1, moves.count) }
            }
        }
    }
}

struct DayNightGame: View {
    @State private var night = false
    @State private var observation = ""
    @State private var discovered: Set<String> = []
    @State private var complete = false
    @StateObject private var narrator = GameNarrator()
    private var visibleKeys: [String] { night ? ["Moon", "Stars"] : ["Sun", "Butterfly"] }
    var body: some View {
        ToddlerGameScaffold(title: "Day & Night", prompt: complete ? "You explored a daytime sky and a nighttime sky!" : "Turn the sky from day to night. Tap both pictures in each sky.", accent: .indigo, completion: complete, onReplay: { night = false; discovered = []; observation = ""; complete = false }) {
            VStack(spacing: 20) {
                ForEach(visibleKeys, id: \.self) { key in
                    Button {
                        discovered.insert(key)
                        let fact: String
                        switch key {
                        case "Sun": fact = "The Sun gives us daylight. The Sun is a star."
                        case "Butterfly": fact = "Many butterflies are active during the day."
                        case "Moon": fact = "The Moon reflects sunlight. Sometimes we see it in the daytime too."
                        default: fact = "There are stars in the sky during the day too, but the bright sky hides them."
                        }
                        observation = fact
                        narrator.speak(fact)
                    } label: {
                        HStack(spacing: 20) {
                            ToddlerArt(asset: key == "Sun" || key == "Moon" ? "Space/\(key)" : nil, symbol: key == "Stars" ? "sparkles" : "butterfly.fill", size: 86)
                            Text(key).font(.title2.bold())
                            if discovered.contains(key) { Image(systemName: "checkmark.circle.fill").font(.title2) }
                        }.frame(maxWidth: .infinity, minHeight: 116)
                    }.buttonStyle(.plain).accessibilityLabel("Explore \(key.lowercased())")
                }
            }.padding(20).foregroundStyle(night ? Color.white : .indigo)
                .background(night ? Color.indigo : Color.cyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 28))
            ToddlerActionButton(title: night ? "Turn to day" : "Turn to night", systemImage: night ? "sun.max.fill" : "moon.fill", color: .indigo) { night.toggle(); observation = ""; narrator.speak(night ? "Nighttime sky." : "Daytime sky.") }
            Text(observation).font(.headline).multilineTextAlignment(.center)
            Text("\(discovered.count) of 4 discoveries").foregroundStyle(.secondary)
            if discovered.count == 4 { ToddlerActionButton(title: "Finish exploring", systemImage: "checkmark", color: .indigo) { complete = true } }
        }.onDisappear { narrator.stop() }
    }
}

struct CozyNestGame: View {
    @State private var twigs: Set<Int> = []
    @State private var woven: Set<Int> = []
    @State private var eggs = 0
    private var step: Int { twigs.count < 3 ? 0 : woven.count < 3 ? 1 : eggs < 3 ? 2 : 3 }
    private let prompts = ["Some birds build nests from twigs. Gather three twigs.", "Tap each twig to weave it into a cozy nest.", "Our pretend nest is ready. Tap to settle the eggs gently.", "A cozy nest for three eggs! Watch real nests from far away."]
    var body: some View {
        ToddlerGameScaffold(title: "A Cozy Nest", prompt: prompts[step], accent: .brown, completion: step == 3, onReplay: { twigs = []; woven = []; eggs = 0 }) {
            ZStack {
                Ellipse().stroke(Color.brown.opacity(0.7), lineWidth: 24).frame(width: 215, height: 115)
                HStack(spacing: 10) {
                    ForEach(0..<eggs, id: \.self) { _ in
                        Ellipse().fill(Color.cyan.opacity(0.45)).frame(width: 38, height: 50)
                    }
                }
                if !woven.isEmpty {
                    ForEach(0..<3) { index in
                        if woven.contains(index) {
                            Capsule().fill(Color.brown).frame(width: 180, height: 9)
                                .rotationEffect(.degrees(Double(index - 1) * 18)).offset(y: 25)
                        }
                    }
                }
            }.frame(height: 180).accessibilityLabel("Pretend bird nest with \(eggs) eggs")
            if step < 2 {
                let displayedStep = step
                ForEach(0..<3) { index in
                    if step == 0 ? !twigs.contains(index) : !woven.contains(index) {
                        Button {
                            guard step == displayedStep else { return }
                            if displayedStep == 0 { twigs.insert(index) } else { woven.insert(index) }
                        } label: {
                            HStack {
                                Capsule().fill(Color.brown).frame(width: 110, height: 12).rotationEffect(.degrees(Double(index - 1) * 8))
                                Text(step == 0 ? "Gather twig" : "Weave twig").font(.headline)
                            }.frame(maxWidth: .infinity, minHeight: 72).background(Color.brown.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
                        }.buttonStyle(.plain).accessibilityLabel(step == 0 ? "Gather twig \(index + 1)" : "Weave twig \(index + 1)")
                    }
                }
            } else if step == 2 {
                ToddlerActionButton(title: "Settle an egg", systemImage: "oval.fill", color: .brown) { eggs = min(eggs + 1, 3) }
            }
        }
    }
}
