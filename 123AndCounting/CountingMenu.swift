import SwiftUI
import Combine

struct CountingMenu: View {
    static let activities: [LearningActivity] = [
        .init(id: "counting.pile-match", title: "Number Picnic", skill: "Connect a small quantity to a numeral", interaction: "Count twelve kinds of fruit in growing groups across twenty-four rounds", ageBand: "Ages 3–4", caregiverTip: "Touch each item together before choosing its number."),
        .init(id: "counting.touch-count", title: "Touch & Count", skill: "One-to-one counting", interaction: "Count twelve kinds of animals across twenty-seven growing levels", ageBand: "Ages 2–4", caregiverTip: "Say one number for every animal you touch."),
        .init(id: "counting.picnic-share", title: "Picnic Share", skill: "One item for each person", interaction: "Share twelve kinds of fruit, one then two per friend", ageBand: "Ages 2–4", caregiverTip: "Set one spoon at each place at your own table."),
        .init(id: "counting.bedtime", title: "Sleepy Sheep", skill: "Notice a group getting smaller", interaction: "Tuck twelve kinds of animal friends in across eighteen levels", ageBand: "Ages 2–4", caregiverTip: "Say 'one fewer' when an animal goes to sleep."),
        .init(id: "counting.trail", title: "Treasure Trail", skill: "Counting order from one to ten", interaction: "Follow twenty-four shuffled trails growing from three to ten stones", ageBand: "Ages 3–4", caregiverTip: "Point to the dots if the numerals are unfamiliar."),
        .init(id: "counting.more", title: "Which Has More?", skill: "Compare small groups", interaction: "Compare more, then fewer across twenty increasingly close pairs", ageBand: "Ages 2–4", caregiverTip: "Line up real toys in two rows to see which has more."),
        .init(id: "counting.garden", title: "Five-Frame Garden", skill: "Make a requested quantity", interaction: "Build and adjust groups from one to ten in one or two five-frames with eight flower styles", ageBand: "Ages 3–4", caregiverTip: "Count flowers, then notice the empty spaces."),
        .init(id: "counting.tickets", title: "Ticket Train", skill: "Match equivalent quantities", interaction: "Match exact dot tickets across twenty-four trains of two to nine passengers", ageBand: "Ages 3–4", caregiverTip: "Match one ticket dot to each passenger."),
        .init(id: "counting.tower", title: "Twin Towers", skill: "Compare height and count units", interaction: "Build and adjust eighteen towers from two to ten blocks", ageBand: "Ages 2–4", caregiverTip: "Try building matching towers with real blocks afterward."),
        .init(id: "counting.dots", title: "Dot Detective", skill: "Recognize small dot patterns", interaction: "Explore eighteen dot clues from one to six with optional hiding", ageBand: "Ages 3–4", caregiverTip: "Keep the clue open as long as your child wants."),
        .init(id: "counting.hops", title: "Frog Hops", skill: "Count actions", interaction: "Guide twenty-four trips of two to nine hops with count checks", ageBand: "Ages 2–4", caregiverTip: "Clap or make seated arm movements along with each hop."),
        .init(id: "counting.drum", title: "Counting Drum", skill: "Count and remember a short rhythm", interaction: "Echo eighteen groups of one to six beats at your own pace", ageBand: "Ages 3–4", caregiverTip: "Echo the beat with claps; there is no speed test.")
    ]

    var body: some View {
        ActivityMenu(title: "123s & Counting", subtitle: "12 little adventures with counting and quantities", accent: .indigo) {
            ForEach(Array(Self.activities.enumerated()), id: \.element.id) { index, activity in
                NavigationLink {
                    destination(index).learningActivity(activity)
                } label: {
                    ActivityCard(title: activity.title, subtitle: "\(activity.ageBand) · \(activity.skill)", symbol: Self.symbols[index], accent: .indigo)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private static let symbols = ["number.circle.fill", "hand.tap.fill", "fork.knife", "moon.stars.fill", "map.fill", "circle.grid.2x2.fill", "leaf.fill", "tram.fill", "square.stack.3d.up.fill", "die.face.3.fill", "figure.jumprope", "music.note"]

    @ViewBuilder private func destination(_ index: Int) -> some View {
        switch index {
        case 0: NumberPicnicGame()
        case 1: TouchCountGame()
        case 2: PicnicShareGame()
        case 3: SleepySheepGame()
        case 4: TreasureTrailGame()
        case 5: MoreGroupsGame()
        case 6: FiveFrameGardenGame()
        case 7: TicketTrainGame()
        case 8: TwinTowersGame()
        case 9: DotDetectiveGame()
        case 10: FrogHopsGame()
        default: CountingDrumGame()
        }
    }
}

private struct CountingStage<Content: View>: View {
    @ObservedObject var play: CountingPlay
    @ViewBuilder var content: () -> Content
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: play.kind.title, prompt: play.complete ? play.kind.completion : play.prompt,
                            accent: .indigo, completion: play.complete, onReplay: play.replay) {
            Text("Level \(play.round + 1) of \(play.total)")
                .font(.system(.headline, design: .rounded)).accessibilityIdentifier("counting.ext.level")
            content().disabled(play.solved || play.complete)
            if !play.feedback.isEmpty {
                Text(play.feedback).font(.system(.title3, design: .rounded, weight: .medium)).multilineTextAlignment(.center)
                    .accessibilityIdentifier("counting.ext.feedback")
            }
            if play.solved && !play.complete {
                ToddlerActionButton(title: play.round + 1 == play.total ? "Finish our adventure" : "Next level", systemImage: "arrow.right.circle.fill", color: .indigo, action: play.advance)
                    .accessibilityIdentifier("counting.ext.next")
            }
        }.id(play.round)
        .onChange(of: play.feedbackRevision) { _, _ in if !play.feedback.isEmpty { narrator.speak(play.feedback) } }
        .onDisappear { narrator.stop() }
    }
}

private struct CountingPicture: View {
    let asset: String
    var size: CGFloat = 48
    var body: some View { ToddlerArt(asset: asset, size: size).accessibilityHidden(true) }
}

private struct QuantityDots: View {
    let count: Int
    var variant = 0
    private var columns: Int { [5, 3, 2][variant % 3] }
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(10), spacing: 4), count: columns), spacing: 4) {
            ForEach(0..<count, id: \.self) { _ in Circle().fill(.indigo).frame(width: 10, height: 10) }
        }.frame(width: CGFloat(columns * 14 - 4), height: CGFloat(max(1, (count + columns - 1) / columns) * 14 - 4))
            .accessibilityElement(children: .ignore).accessibilityLabel("\(count) dots")
    }
}

private struct CountNumberButton: View {
    let number: Int
    var selected = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text("\(number)").font(.system(size: 30, weight: .bold, design: .rounded))
                QuantityDots(count: number)
            }.frame(maxWidth: .infinity, minHeight: 94)
                .background(selected ? Color.indigo.opacity(0.16) : .white, in: RoundedRectangle(cornerRadius: 18))
        }.buttonStyle(.plain).foregroundStyle(.indigo).accessibilityLabel("\(number)")
            .accessibilityValue(selected ? "Visited" : "")
    }
}

private struct PicnicShareGame: View {
    @StateObject private var play = CountingPlay(kind: .share)
    var body: some View {
        CountingStage(play: play) {
            Text("\(play.target) friends · \(play.lesson.amount) \(play.lesson.amount == 1 ? play.lesson.food.id : play.lesson.food.plural) each").font(.headline)
                .accessibilityIdentifier("counting.ext.clue")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(0..<play.target, id: \.self) { index in
                    let amount = play.servings[index, default: 0]
                    Button { play.serve(index) } label: {
                        ZStack {
                            Circle().fill(.white).overlay(Circle().stroke(.indigo.opacity(0.25), lineWidth: 4))
                            if amount == 0 { Image(systemName: "plus").font(.title) }
                            else { HStack(spacing: 0) { ForEach(0..<amount, id: \.self) { _ in CountingPicture(asset: play.lesson.food.asset, size: amount == 1 ? 48 : 32) } } }
                        }.frame(height: 92)
                    }.buttonStyle(.plain)
                        .accessibilityLabel("Plate \(index + 1), \(amount) \(amount == 1 ? play.lesson.food.id : play.lesson.food.plural)")
                        .accessibilityIdentifier("counting.ext.plate.\(index)")
                        .disabled(amount == play.lesson.amount)
                }
            }
        }
    }
}

private struct SleepySheepGame: View {
    @StateObject private var play = CountingPlay(kind: .sheep)
    var body: some View {
        CountingStage(play: play) {
            Text("\(play.target - play.marked.count) awake").font(.title.bold()).accessibilityIdentifier("counting.ext.remaining")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: play.target <= 6 ? 3 : 4), spacing: 10) {
                ForEach(0..<play.target, id: \.self) { index in
                    Button { play.tuck(index) } label: {
                        VStack(spacing: 4) {
                            if play.marked.contains(index) { Image(systemName: "moon.zzz.fill").font(.system(size: 34)).frame(height: 48) }
                            else { CountingPicture(asset: play.lesson.animal.id) }
                            Text(play.marked.contains(index) ? "Asleep" : "Awake").font(.caption)
                        }.frame(maxWidth: .infinity, minHeight: 88).background(.white, in: RoundedRectangle(cornerRadius: 18))
                    }.buttonStyle(.plain).disabled(play.marked.contains(index))
                        .accessibilityLabel("\(play.lesson.animal.id.capitalized) \(index + 1), \(play.marked.contains(index) ? "asleep" : "awake")")
                        .accessibilityIdentifier("counting.ext.sheep.\(index)")
                }
            }
        }
    }
}

private struct TreasureTrailGame: View {
    @StateObject private var play = CountingPlay(kind: .trail)
    var body: some View {
        CountingStage(play: play) {
            Text(play.count == 0 ? "Start at 1" : "You reached \(play.count)").font(.title2.bold()).accessibilityIdentifier("counting.ext.reached")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(play.lesson.stones, id: \.self) { value in
                    CountNumberButton(number: value, selected: value <= play.count) { play.stone(value) }
                        .disabled(value <= play.count).accessibilityIdentifier("counting.ext.stone.\(value)")
                }
            }
            HStack(spacing: 12) {
                ToddlerArt(asset: play.lesson.theme.asset, size: 64)
                Text(play.solved ? "Treasure found!" : "Find the trail treasure").font(.headline)
            }.accessibilityElement(children: .ignore).accessibilityLabel("\(play.lesson.theme.id) treasure")
        }
    }
}

private struct MoreGroupsGame: View {
    @StateObject private var play = CountingPlay(kind: .more)
    var body: some View {
        CountingStage(play: play) {
            Text(play.lesson.fewer ? "Find fewer" : "Find more").font(.title2.bold()).accessibilityIdentifier("counting.ext.clue")
            ForEach(play.lesson.choices, id: \.self) { amount in
                Button { play.choose(amount) } label: {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 5), spacing: 6) {
                        ForEach(0..<amount, id: \.self) { _ in CountingPicture(asset: play.lesson.food.asset, size: 40) }
                    }.padding(12).frame(maxWidth: .infinity, minHeight: 112).background(.white, in: RoundedRectangle(cornerRadius: 20))
                }.buttonStyle(.plain).accessibilityLabel("Group with \(amount) \(play.lesson.food.plural)").accessibilityIdentifier("counting.ext.choice.\(amount)")
            }
        }
    }
}

private struct FiveFrameGardenGame: View {
    @StateObject private var play = CountingPlay(kind: .garden)
    var body: some View {
        CountingStage(play: play) {
            Text("Grow \(play.target)").font(.title.bold()).accessibilityIdentifier("counting.ext.clue")
            Text(play.lesson.gardenSize == 5 ? "One five-frame" : "Two five-frames").font(.subheadline)
            VStack(spacing: 12) {
                ForEach(0..<(play.lesson.gardenSize / 5), id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(0..<5, id: \.self) { column in
                            let index = row * 5 + column
                            Button { play.plant(index) } label: {
                                Group {
                                    if play.marked.contains(index) { CountingFlower(theme: play.lesson.theme) }
                                    else { Image(systemName: "plus").font(.system(size: 25)) }
                                }.frame(maxWidth: .infinity, minHeight: 66)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                            }.buttonStyle(.plain)
                                .accessibilityLabel("Space \(index + 1), \(play.marked.contains(index) ? "planted" : "empty")")
                                .accessibilityIdentifier("counting.ext.plot.\(index)")
                        }
                    }
                }
            }
            Text("\(play.marked.count) planted").accessibilityIdentifier("counting.ext.planted")
            ToddlerActionButton(title: "Check my flowers", systemImage: "checkmark.circle.fill", color: .indigo, action: play.check)
                .accessibilityIdentifier("counting.ext.check")
        }
    }
}

private struct TicketTrainGame: View {
    @StateObject private var play = CountingPlay(kind: .tickets)
    var body: some View {
        CountingStage(play: play) {
            Image(systemName: "tram.fill").font(.system(size: 42)).foregroundStyle(.indigo)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                ForEach(0..<play.target, id: \.self) { _ in CountingPicture(asset: play.lesson.animal.id, size: 40) }
            }.accessibilityElement(children: .ignore).accessibilityLabel("\(play.target) \(play.lesson.animal.plural) riding the train").accessibilityIdentifier("counting.ext.passengers")
            ForEach(play.lesson.choices, id: \.self) { value in
                Button { play.choose(value) } label: {
                    HStack {
                        Image(systemName: "ticket.fill").font(.title)
                        Spacer(); QuantityDots(count: value, variant: play.lesson.variant); Spacer()
                    }.padding(16).frame(minHeight: 76).background(.white, in: RoundedRectangle(cornerRadius: 18))
                }.buttonStyle(.plain).accessibilityLabel("Ticket with \(value) dots").accessibilityIdentifier("counting.ext.choice.\(value)")
            }
        }
    }
}

private struct TwinTowersGame: View {
    @StateObject private var play = CountingPlay(kind: .towers)
    var body: some View {
        CountingStage(play: play) {
            HStack(alignment: .bottom, spacing: 28) { tower(play.target, label: "My tower", color: play.lesson.theme.color); tower(play.count, label: "Your tower", color: play.lesson.theme.color) }
            HStack {
                ToddlerActionButton(title: "Take one", systemImage: "minus.circle.fill", color: .indigo) { play.changeBlocks(-1) }
                    .disabled(play.count == 0).accessibilityIdentifier("counting.ext.minus")
                ToddlerActionButton(title: "Add one", systemImage: "plus.circle.fill", color: .indigo) { play.changeBlocks(1) }
                    .disabled(play.count == 12).accessibilityIdentifier("counting.ext.plus")
            }
            ToddlerActionButton(title: "Same height?", systemImage: "checkmark.circle.fill", color: .indigo, action: play.check).accessibilityIdentifier("counting.ext.check")
        }
    }
    private func tower(_ count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            VStack(spacing: 4) {
                Spacer(minLength: 0)
                ForEach(0..<count, id: \.self) { _ in RoundedRectangle(cornerRadius: 4).fill(color).frame(width: 72, height: 16) }
            }.frame(height: 240)
            Rectangle().fill(.secondary).frame(width: 90, height: 3)
            HStack(spacing: 6) { ToddlerArt(asset: play.lesson.theme.asset, size: 28); Text(label).font(.headline) }
        }.accessibilityElement(children: .ignore).accessibilityLabel("\(label), \(count) blocks")
            .accessibilityIdentifier(label == "My tower" ? "counting.ext.model" : "counting.ext.built")
    }
}

private struct DotDetectiveGame: View {
    @StateObject private var play = CountingPlay(kind: .dots)
    var body: some View {
        CountingStage(play: play) {
            VStack(spacing: 10) {
                HStack { CountingPicture(asset: play.lesson.theme.asset, size: 32); Text("Clue card").font(.headline) }
                if play.revealed { Image(systemName: "questionmark").font(.title).frame(height: 42) }
                else { QuantityDots(count: play.target, variant: play.lesson.variant).frame(height: 42) }
            }.frame(maxWidth: .infinity, minHeight: 104).background(.yellow.opacity(0.2), in: RoundedRectangle(cornerRadius: 20))
                .accessibilityElement(children: .ignore).accessibilityLabel(play.revealed ? "Hidden clue" : "Clue with \(play.target) dots").accessibilityIdentifier("counting.ext.clue")
            ToddlerActionButton(title: play.revealed ? "See the clue again" : "Hide the clue", systemImage: "eye.fill", color: .indigo) { play.revealed.toggle() }
                .accessibilityIdentifier("counting.ext.peek")
            HStack(spacing: 10) {
                ForEach(play.lesson.choices, id: \.self) { value in
                    Button { play.choose(value) } label: {
                        VStack(spacing: 12) {
                            CountingPicture(asset: play.lesson.theme.asset, size: 28)
                            QuantityDots(count: value, variant: play.lesson.variant)
                        }.frame(maxWidth: .infinity, minHeight: 120).background(.white, in: RoundedRectangle(cornerRadius: 18))
                    }.buttonStyle(.plain).accessibilityLabel("Card with \(value) dots").accessibilityIdentifier("counting.ext.choice.\(value)")
                }
            }
        }
    }
}

private struct FrogHopsGame: View {
    @StateObject private var play = CountingPlay(kind: .hops)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        CountingStage(play: play) {
            Text("Make \(play.target) hops").font(.headline).accessibilityIdentifier("counting.ext.clue")
            CountingPond(theme: play.lesson.theme, progress: Double(min(play.count, play.target)) / Double(play.target))
                .animation(reduceMotion ? nil : .spring(duration: 0.3), value: play.count)
            Text("\(play.count) hops").font(.title.bold()).accessibilityIdentifier("counting.ext.count")
            ToddlerActionButton(title: "Hop!", systemImage: "arrow.up.circle.fill", color: .indigo, action: play.tap)
                .disabled(play.count >= play.limit).accessibilityIdentifier("counting.ext.tap")
            ToddlerActionButton(title: "All hopped", systemImage: "checkmark.circle.fill", color: .indigo, action: play.check).accessibilityIdentifier("counting.ext.check")
            ToddlerActionButton(title: "Start hops again", systemImage: "arrow.counterclockwise", color: .indigo, action: play.clear).accessibilityIdentifier("counting.ext.clear")
        }
    }
}

private struct CountingDrumGame: View {
    @StateObject private var play = CountingPlay(kind: .drum)
    @StateObject private var narrator = GameNarrator()
    @State private var demonstration = 0
    @State private var playing = false
    @State private var beat = 0
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        CountingStage(play: play) {
            ToddlerActionButton(title: "Hear my beats", systemImage: "speaker.wave.2.fill", color: .indigo) { demonstration += 1 }
                .accessibilityIdentifier("counting.ext.listen")
            Text(playing ? "Listen: \(beat)" : "Your beats: \(play.count)").font(.title.bold()).accessibilityIdentifier("counting.ext.count")
            Button { if !playing { play.tap() } } label: {
                ZStack {
                    Circle().fill(play.lesson.theme.color.opacity(0.18))
                    Circle().stroke(play.lesson.theme.color, lineWidth: 8).padding(5)
                    ToddlerArt(asset: play.lesson.theme.asset, size: 72)
                }.frame(width: 124, height: 124)
                    .scaleEffect(playing && beat > 0 ? 1.04 : 1)
                    .frame(maxWidth: .infinity, minHeight: 140).background(.white, in: RoundedRectangle(cornerRadius: 28))
            }.buttonStyle(.plain).disabled(playing || play.count >= play.limit).accessibilityLabel("Drum. Tap one beat").accessibilityIdentifier("counting.ext.tap")
            ToddlerActionButton(title: "Check my beats", systemImage: "checkmark.circle.fill", color: .indigo) {
                play.check()
                if !play.solved { demonstration += 1 }
            }.disabled(playing).accessibilityIdentifier("counting.ext.check")
            ToddlerActionButton(title: "Clear my beats", systemImage: "arrow.counterclockwise", color: .indigo, action: play.clear)
                .disabled(playing).accessibilityIdentifier("counting.ext.clear")
        }
        .task(id: demonstration) {
            let request = demonstration
            guard request > 0 else { playing = false; beat = 0; return }
            playing = true; beat = 0; play.clear()
            do {
                try await Task.sleep(for: .milliseconds(600))
                for value in 1...play.target {
                    try Task.checkCancellation()
                    beat = value; narrator.speak("\(value). Boom.")
                    try await Task.sleep(for: .milliseconds(1300))
                }
                if request == demonstration { playing = false }
            } catch {
                if request == demonstration { narrator.stop(); playing = false }
            }
        }
        .onChange(of: play.round) { _, _ in demonstration = 0 }
        .onChange(of: play.complete) { _, _ in demonstration = 0 }
        .onChange(of: scenePhase) { _, phase in if phase != .active { demonstration = 0; narrator.stop() } }
        .onDisappear { narrator.stop() }
    }
}
