import SwiftUI
import Combine
import AVFoundation

struct CountingMenu: View {
    static let activities: [LearningActivity] = [
        .init(id: "counting.pile-match", title: "Number Picnic", skill: "Connect a small quantity to a numeral", interaction: "Count twelve kinds of fruit in shuffled groups from one to ten across thirty rounds", ageBand: "Ages 3–4", caregiverTip: "Touch each item together before choosing its number."),
        .init(id: "counting.touch-count", title: "Touch & Count", skill: "One-to-one counting", interaction: "Find and count a named animal in twenty mixed grids growing from 3×3 to 5×5", ageBand: "Ages 2–4", caregiverTip: "Say one number for every animal you touch."),
        .init(id: "counting.picnic-share", title: "Picnic Share", skill: "Find the missing amount in addition and subtraction", interaction: "Solve ten new picnic math puzzles with totals up to ten", ageBand: "Ages 2–4", caregiverTip: "Use real snacks to show how adding or taking away reaches the total."),
        .init(id: "counting.bedtime", title: "Sleepy Sheep", skill: "Count forward one at a time to one hundred", interaction: "Welcome one hopping sheep at a time and count with Ruth to one hundred", ageBand: "Ages 2–4", caregiverTip: "Say the next number together when each sheep lands."),
        .init(id: "counting.trail", title: "Treasure Trail", skill: "Compare quantities from ten to one hundred", interaction: "Choose more or less treasure across forty-six comparisons", ageBand: "Ages 3–4", caregiverTip: "Count full rows by tens, then count the extra coins together."),
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
    var showsNext = true
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
            if showsNext && play.solved && !play.complete {
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
    private var gridWidth: CGFloat { CGFloat(columns * 14 - 4) }
    private var gridHeight: CGFloat { CGFloat(max(1, (count + columns - 1) / columns) * 14 - 4) }
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(10), spacing: 4), count: columns), spacing: 4) {
            ForEach(0..<count, id: \.self) { _ in Circle().fill(.indigo).frame(width: 10, height: 10) }
        }.frame(width: gridWidth, height: gridHeight)
            .accessibilityElement(children: .ignore).accessibilityLabel("\(count) dots")
    }
}

private struct PicnicShareGame: View {
    @StateObject private var play = CountingPlay(kind: .share)
    var body: some View {
        CountingStage(play: play, showsNext: false) {
            HStack(alignment: .top, spacing: 12) {
                pile(title: "We have", count: play.lesson.start, id: "have")
                pile(title: "We need", count: play.lesson.goal, id: "need")
            }
            Text("\(play.lesson.start) \(play.lesson.picnicAdds ? "+" : "−") \(play.solved ? String(play.target) : "?") = \(play.lesson.goal)")
                .font(.system(.title, design: .rounded, weight: .bold))
                .accessibilityIdentifier("counting.share.equation")
            Text(play.lesson.picnicAdds ? "How many should we add?" : "How many should we take away?")
                .font(.headline).accessibilityIdentifier("counting.ext.clue")
            HStack(spacing: 12) {
                ForEach(play.lesson.choices, id: \.self) { value in
                    Button { play.choose(value) } label: {
                        VStack(spacing: 6) {
                            Text("\(value)").font(.system(size: 36, weight: .bold, design: .rounded))
                            Text(play.lesson.picnicAdds ? "Add" : "Take away").font(.subheadline.bold())
                        }.frame(maxWidth: .infinity, minHeight: 90)
                            .background(.white, in: RoundedRectangle(cornerRadius: 18))
                    }.buttonStyle(.plain)
                        .accessibilityLabel("\(play.lesson.picnicAdds ? "Add" : "Take away") \(value)")
                        .accessibilityIdentifier("counting.ext.choice.\(value)")
                }
            }
        }
        .task(id: play.solved) {
            guard play.solved, !play.complete else { return }
            // Leave the solved equation visible until its Ruth explanation finishes.
            let duration: TimeInterval
            if GameNarrator.promptsEnabled(), let url = NarrationAudioCatalog.shared.url(for: play.lesson.picnicSuccess),
               let audio = try? AVAudioPlayer(contentsOf: url) {
                duration = max(2, audio.duration + 0.5)
            } else { duration = 2 }
            do { try await Task.sleep(for: .seconds(duration)) } catch { return }
            play.advance()
        }
    }
    private func pile(title: String, count: Int, id: String) -> some View {
        VStack(spacing: 8) {
            Text("\(title): \(count)").font(.headline)
                .accessibilityIdentifier("counting.share.\(id)")
            Text(count == 1 ? play.lesson.food.id : play.lesson.food.plural).font(.subheadline)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 4) {
                ForEach(0..<count, id: \.self) { _ in
                    CountingPicture(asset: play.lesson.food.asset, size: 34)
                        .accessibilityIdentifier("counting.share.\(id).item")
                }
            }
        }.padding(12).frame(maxWidth: .infinity, minHeight: 215, alignment: .top)
            .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct TreasureTrailGame: View {
    @StateObject private var play = CountingPlay(kind: .trail)
    var body: some View {
        CountingStage(play: play) {
            Text(play.lesson.fewer ? "Find less treasure" : "Find more treasure")
                .font(.title2.bold()).accessibilityIdentifier("counting.ext.clue")
            Text("Each full row = 10 coins").font(.subheadline)
            HStack(alignment: .top, spacing: 12) {
                ForEach(play.lesson.choices, id: \.self) { value in
                    VStack(spacing: 8) {
                        Button { play.choose(value) } label: {
                            VStack(spacing: 10) {
                                Image(systemName: "shippingbox.fill").font(.largeTitle).foregroundStyle(.brown)
                                // Fixed slots keep coin size and spacing identical in both piles.
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 10), spacing: 5) {
                                    ForEach(0..<100, id: \.self) { index in
                                        Circle().fill(Color.yellow.gradient)
                                            .overlay(Circle().stroke(Color.orange, lineWidth: 1))
                                            .aspectRatio(1, contentMode: .fit)
                                            .opacity(index < value ? 1 : 0)
                                    }
                                }.accessibilityHidden(true)
                                Text("\(value)").font(.system(size: 34, weight: .bold, design: .rounded))
                                Text("coins").font(.headline)
                            }.padding(10).frame(maxWidth: .infinity)
                                .background(.white, in: RoundedRectangle(cornerRadius: 20))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.orange.opacity(0.5), lineWidth: 2))
                        }.buttonStyle(.plain)
                            .accessibilityLabel("Pile with \(value) coins")
                            .accessibilityIdentifier("counting.ext.choice.\(value)")
                        Button { play.say("\(value) coins.") } label: {
                            Label("Hear \(value)", systemImage: "speaker.wave.2.fill")
                                .font(.headline).frame(maxWidth: .infinity, minHeight: 48)
                        }.buttonStyle(.bordered).accessibilityIdentifier("counting.trail.hear.\(value)")
                    }
                }
            }
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
