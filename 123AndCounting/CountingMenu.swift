import SwiftUI
import Combine

struct CountingMenu: View {
    static let activities: [LearningActivity] = [
        .init(id: "counting.pile-match", title: "Number Picnic", skill: "Connect a small quantity to a numeral", interaction: "Count fruit groups from three to ten across twenty-four rounds", ageBand: "Ages 3–4", caregiverTip: "Touch each item together before choosing its number."),
        .init(id: "counting.touch-count", title: "Touch & Count", skill: "One-to-one counting", interaction: "Touch each animal once to count the whole group", ageBand: "Ages 2–4", caregiverTip: "Say one number for every animal you touch."),
        .init(id: "counting.picnic-share", title: "Picnic Share", skill: "One item for each person", interaction: "Give every picnic plate one apple", ageBand: "Ages 2–4", caregiverTip: "Set one spoon at each place at your own table."),
        .init(id: "counting.bedtime", title: "Sleepy Sheep", skill: "Notice a group getting smaller", interaction: "Tuck sheep into bed and hear how many are still awake", ageBand: "Ages 2–4", caregiverTip: "Say 'one fewer' when a sheep goes to sleep."),
        .init(id: "counting.trail", title: "Treasure Trail", skill: "Counting order from one to five", interaction: "Follow numbered stepping stones in order", ageBand: "Ages 3–4", caregiverTip: "Point to the dots if the numerals are unfamiliar."),
        .init(id: "counting.more", title: "Which Has More?", skill: "Compare small groups", interaction: "Compare two visible groups without math symbols", ageBand: "Ages 2–4", caregiverTip: "Line up real toys in two rows to see which has more."),
        .init(id: "counting.garden", title: "Five-Frame Garden", skill: "Make a requested quantity", interaction: "Plant or remove flowers in five garden spaces", ageBand: "Ages 3–4", caregiverTip: "Count flowers, then notice the empty spaces."),
        .init(id: "counting.tickets", title: "Ticket Train", skill: "Match equivalent quantities", interaction: "Choose the dot ticket that fits the train's passengers", ageBand: "Ages 3–4", caregiverTip: "Match one ticket dot to each passenger."),
        .init(id: "counting.tower", title: "Twin Towers", skill: "Compare height and count units", interaction: "Build a block tower the same height as a model", ageBand: "Ages 2–4", caregiverTip: "Try building matching towers with real blocks afterward."),
        .init(id: "counting.dots", title: "Dot Detective", skill: "Recognize small dot patterns", interaction: "Remember a dot card and uncover its matching pattern", ageBand: "Ages 3–4", caregiverTip: "Keep the clue open as long as your child wants."),
        .init(id: "counting.hops", title: "Frog Hops", skill: "Count actions", interaction: "Make a frog hop a requested number of times", ageBand: "Ages 2–4", caregiverTip: "Clap or make seated arm movements along with each hop."),
        .init(id: "counting.drum", title: "Counting Drum", skill: "Count and remember a short rhythm", interaction: "Hear a beat group, then tap the same number of beats", ageBand: "Ages 3–4", caregiverTip: "Echo the beat with claps; there is no speed test.")
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

/// Round changes are deliberate: children can finish listening before continuing.
@MainActor
private final class CountingPlay: ObservableObject {
    @Published var round = 0
    @Published var count = 0
    @Published var marked: Set<Int> = []
    @Published var selected: Int?
    @Published var revealed = false
    @Published var solved = false
    @Published var complete = false
    @Published var feedback = ""
    @Published private(set) var feedbackRevision = 0
    let total = 3

    func say(_ text: String) { guard !complete else { return }; feedback = text; feedbackRevision += 1 }
    func win(_ text: String) { guard !complete else { return }; solved = true; say(text) }
    func advance() {
        guard solved, !complete else { return }
        if round + 1 == total { complete = true; return }
        round += 1
        clearRound()
    }
    func replay() { round = 0; complete = false; clearRound() }
    private func clearRound() {
        count = 0; marked = []; selected = nil; revealed = false; solved = false; feedback = ""
    }
}

private struct CountingStage<Content: View>: View {
    let title: String
    let prompt: String
    @ObservedObject var play: CountingPlay
    @ViewBuilder var content: () -> Content
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ToddlerGameScaffold(title: title, prompt: prompt, accent: .indigo, completion: play.complete, onReplay: play.replay) {
            VStack(spacing: 20) {
                Text("Adventure \(play.round + 1) of \(play.total)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                content().disabled(play.solved)
                if !play.feedback.isEmpty {
                    Text(play.feedback)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.indigo)
                }
                if play.solved {
                    ToddlerActionButton(title: play.round + 1 == play.total ? "All done" : "Next adventure", systemImage: "arrow.right.circle.fill", color: .indigo, action: play.advance)
                }
            }
        }
        .onChange(of: play.feedbackRevision) { _, _ in
            if !play.feedback.isEmpty { narrator.speak(play.feedback) }
        }
        .onDisappear { narrator.stop() }
    }
}

private struct CountingPicture: View {
    let asset: String
    var size: CGFloat = 70
    var body: some View { ToddlerArt(asset: asset, size: size).accessibilityHidden(true) }
}

private struct QuantityDots: View {
    let count: Int
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<count, id: \.self) { _ in Circle().fill(Color.indigo).frame(width: 13, height: 13) }
        }
        .frame(minHeight: 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(count) dots")
    }
}

private struct CountNumberButton: View {
    let number: Int
    var selected = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text("\(number)").font(.system(size: 36, weight: .bold, design: .rounded))
                QuantityDots(count: number)
            }
            .frame(maxWidth: .infinity, minHeight: 92)
            .background(selected ? Color.indigo.opacity(0.2) : Color.white, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.indigo.opacity(0.35), lineWidth: 2))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.indigo)
        .accessibilityLabel("\(number)")
        .accessibilityValue(selected ? "Selected" : "")
    }
}

private struct TouchCountGame: View {
    @StateObject private var play = CountingPlay()
    private var target: Int { [2, 3, 5][play.round] }
    var body: some View {
        CountingStage(title: "Touch & Count", prompt: "Touch each duck once. Let's count together.", play: play) {
            VStack(spacing: 20) {
                Text("\(play.marked.count)").font(.system(size: 60, weight: .bold, design: .rounded))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 14) {
                    ForEach(0..<target, id: \.self) { index in
                        Button {
                            guard !play.marked.contains(index) else { return }
                            play.marked.insert(index)
                            if play.marked.count == target { play.win("\(target). You counted every duck!") }
                            else { play.say("\(play.marked.count)") }
                        } label: {
                            VStack {
                                CountingPicture(asset: "duck")
                                Image(systemName: play.marked.contains(index) ? "checkmark.circle.fill" : "circle")
                            }.padding(10).frame(maxWidth: .infinity).background(.white, in: RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Duck \(index + 1), \(play.marked.contains(index) ? "counted" : "touch to count")")
                    }
                }
            }
        }
    }
}

private struct PicnicShareGame: View {
    @StateObject private var play = CountingPlay()
    private var target: Int { [2, 3, 4][play.round] }
    var body: some View {
        CountingStage(title: "Picnic Share", prompt: "Give one apple to every plate. Tap an empty plate.", play: play) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 20) {
                ForEach(0..<target, id: \.self) { index in
                    Button {
                        guard !play.marked.contains(index) else { play.say("This plate has one. Find an empty plate."); return }
                        play.marked.insert(index)
                        if play.marked.count == target { play.win("One apple for each friend. Everyone has one!") }
                        else { play.say("One apple for this friend.") }
                    } label: {
                        ZStack {
                            Circle().fill(.white).overlay(Circle().stroke(Color.indigo.opacity(0.25), lineWidth: 7))
                            if play.marked.contains(index) { CountingPicture(asset: "Apple") }
                            else { Image(systemName: "plus").font(.largeTitle).foregroundStyle(.indigo) }
                        }.frame(height: 110)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Plate \(index + 1), \(play.marked.contains(index) ? "one apple" : "empty")")
                }
            }
        }
    }
}

private struct SleepySheepGame: View {
    @StateObject private var play = CountingPlay()
    private var target: Int { [3, 2, 4][play.round] }
    var body: some View {
        CountingStage(title: "Sleepy Sheep", prompt: "Tap each sheep to tuck it in. How many are still awake?", play: play) {
            VStack(spacing: 18) {
                Text("\(target - play.marked.count) awake").font(.title.bold())
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 14) {
                    ForEach(0..<target, id: \.self) { index in
                        Button {
                            guard !play.marked.contains(index) else { return }
                            play.marked.insert(index)
                            let left = target - play.marked.count
                            if left == 0 { play.win("No sheep awake. All the sheep are asleep. Good night!") }
                            else { play.say("\(left) \(left == 1 ? "sheep is" : "sheep are") still awake.") }
                        } label: {
                            VStack {
                                if play.marked.contains(index) {
                                    Image(systemName: "moon.zzz.fill").font(.system(size: 48)).frame(height: 70)
                                } else { CountingPicture(asset: "sheep") }
                                Text(play.marked.contains(index) ? "Asleep" : "Awake").font(.headline)
                            }.frame(maxWidth: .infinity, minHeight: 112).background(.white, in: RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Sheep \(index + 1), \(play.marked.contains(index) ? "asleep" : "awake, tuck in")")
                    }
                }
            }
        }
    }
}

private struct TreasureTrailGame: View {
    @StateObject private var play = CountingPlay()
    private var values: [Int] { [[2, 1, 3], [3, 1, 4, 2], [4, 2, 5, 1, 3]][play.round] }
    var body: some View {
        CountingStage(title: "Treasure Trail", prompt: "Follow the counting stones. Start at one.", play: play) {
            VStack(spacing: 18) {
                Label(play.count == 0 ? "Start at 1" : "You reached \(play.count)", systemImage: "map.fill").font(.title2.bold())
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 12) {
                    ForEach(values, id: \.self) { value in
                        CountNumberButton(number: value, selected: value <= play.count) {
                            guard value > play.count else { return }
                            if value == play.count + 1 {
                                play.count += 1
                                if play.count == values.count { play.win("You followed every counting stone. Treasure found!") }
                                else { play.say("\(value). Next comes \(value + 1).") }
                            } else { play.say("Look for \(play.count + 1). Count the dots on the stones.") }
                        }
                    }
                }
                if play.solved { ToddlerArt(asset: "Star", size: 92) }
            }
        }
    }
}

private struct MoreGroupsGame: View {
    @StateObject private var play = CountingPlay()
    private var amounts: [Int] { [[1, 3], [4, 2], [2, 5]][play.round] }
    var body: some View {
        CountingStage(title: "Which Has More?", prompt: "Which group has more oranges? Tap that group.", play: play) {
            VStack(spacing: 16) {
                ForEach(0..<2, id: \.self) { index in
                    Button {
                        if amounts[index] == amounts.max() { play.win("Yes! \(amounts[index]) oranges is more than \(amounts[1 - index]).") }
                        else { play.say("Let's count each row. Which has more oranges?") }
                    } label: {
                        HStack(spacing: 2) {
                            ForEach(0..<amounts[index], id: \.self) { _ in CountingPicture(asset: "Orange", size: 44) }
                            Spacer(minLength: 0)
                        }.padding(16).frame(maxWidth: .infinity, minHeight: 100).background(.white, in: RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Group with \(amounts[index]) oranges")
                }
            }
        }
    }
}

private struct FiveFrameGardenGame: View {
    @StateObject private var play = CountingPlay()
    private var target: Int { [2, 3, 5][play.round] }
    var body: some View {
        CountingStage(title: "Five-Frame Garden", prompt: "Plant \(target) flowers. Tap a space to plant. Tap a flower to take it out.", play: play) {
            VStack(spacing: 18) {
                Text("Grow \(target)").font(.title.bold())
                // Wrapping retains a full 72-point planting target on small phones.
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 10) {
                    ForEach(0..<5, id: \.self) { index in
                        Button {
                            if play.marked.contains(index) { play.marked.remove(index) } else { play.marked.insert(index) }
                            play.say("\(play.marked.count) flowers")
                        } label: {
                            Image(systemName: play.marked.contains(index) ? "camera.macro" : "plus")
                                .font(.system(size: 32)).frame(maxWidth: .infinity, minHeight: 80)
                                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Garden space \(index + 1), \(play.marked.contains(index) ? "flower planted" : "empty")")
                    }
                }
                ToddlerActionButton(title: "Check my flowers", systemImage: "checkmark.circle.fill", color: .indigo) {
                    if play.marked.count == target { play.win("Exactly \(target) flowers. Your garden is growing!") }
                    else { play.say(play.marked.count < target ? "Add another flower, then count again." : "Take out a flower, then count again.") }
                }
            }
        }
    }
}

private struct TicketTrainGame: View {
    @StateObject private var play = CountingPlay()
    private var target: Int { [1, 3, 2][play.round] }
    var body: some View {
        CountingStage(title: "Ticket Train", prompt: "Each passenger needs one ticket dot. Choose the ticket with enough dots for everyone.", play: play) {
            VStack(spacing: 22) {
                HStack {
                    Image(systemName: "tram.fill").font(.system(size: 44)).accessibilityHidden(true)
                    ForEach(0..<target, id: \.self) { _ in CountingPicture(asset: "rabbit", size: 54) }
                }.accessibilityElement(children: .ignore).accessibilityLabel("Train with \(target) passengers")
                ForEach([2, 1, 3], id: \.self) { value in
                    Button {
                        if value == target { play.win("One dot for each passenger. All aboard!") }
                        else { play.say("Match each rabbit with one dot. Try another ticket.") }
                    } label: {
                        HStack {
                            Image(systemName: "ticket.fill").font(.largeTitle)
                            Spacer()
                            QuantityDots(count: value)
                            Spacer()
                        }.padding(20).frame(minHeight: 80).background(.white, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Ticket with \(value) dots")
                }
            }
        }
    }
}

private struct TwinTowersGame: View {
    @StateObject private var play = CountingPlay()
    private var target: Int { [2, 4, 3][play.round] }
    var body: some View {
        CountingStage(title: "Twin Towers", prompt: "Build a tower the same height as mine. Add or take away blocks.", play: play) {
            VStack(spacing: 18) {
                HStack(alignment: .bottom, spacing: 32) {
                    tower(target, label: "My tower", color: .orange)
                    tower(play.count, label: "Your tower", color: .indigo)
                }
                HStack {
                    ToddlerActionButton(title: "Take one", systemImage: "minus.circle.fill", color: .indigo) {
                        if play.count > 0 { play.count -= 1; play.say("\(play.count) blocks") }
                    }.disabled(play.count == 0)
                    ToddlerActionButton(title: "Add one", systemImage: "plus.circle.fill", color: .indigo) {
                        if play.count < 5 { play.count += 1; play.say("\(play.count) blocks") }
                    }.disabled(play.count == 5)
                }
                ToddlerActionButton(title: "Same height?", systemImage: "checkmark.circle.fill", color: .indigo) {
                    if play.count == target { play.win("Both towers have \(target) blocks. They are the same height!") }
                    else { play.say(play.count < target ? "Your tower is shorter. Add a block." : "Your tower is taller. Take one block away.") }
                }
            }
        }
    }
    private func tower(_ count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            VStack(spacing: 4) {
                Spacer(minLength: 0)
                ForEach(0..<count, id: \.self) { _ in RoundedRectangle(cornerRadius: 6).fill(color).frame(width: 80, height: 30) }
            }.frame(height: 174)
            Rectangle().fill(Color.secondary).frame(width: 96, height: 3)
            Text(label).font(.headline)
        }.accessibilityElement(children: .ignore).accessibilityLabel("\(label), \(count) blocks")
    }
}

private struct DotDetectiveGame: View {
    @StateObject private var play = CountingPlay()
    private var target: Int { [2, 1, 3][play.round] }
    var body: some View {
        CountingStage(title: "Dot Detective", prompt: "Look at the clue dots. Hide the clue when you are ready, then find its twin.", play: play) {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("Clue card").font(.headline)
                    if play.revealed { Image(systemName: "questionmark").font(.largeTitle).frame(height: 30) }
                    else { QuantityDots(count: target).frame(height: 30) }
                }.frame(maxWidth: .infinity, minHeight: 100).background(Color.yellow.opacity(0.25), in: RoundedRectangle(cornerRadius: 20))
                ToddlerActionButton(title: play.revealed ? "See the clue again" : "Hide the clue", systemImage: "eye.fill", color: .indigo) { play.revealed.toggle() }
                HStack {
                    ForEach([1, 3, 2], id: \.self) { value in
                        Button {
                            if value == target { play.win("You found the twin: \(target) dots!") }
                            else { play.say("You can peek at the clue again. Look for the same dots.") }
                        } label: {
                            QuantityDots(count: value).frame(maxWidth: .infinity, minHeight: 96).background(.white, in: RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Card with \(value) dots")
                    }
                }
            }
        }
    }
}

private struct FrogHopsGame: View {
    @StateObject private var play = CountingPlay()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var target: Int { [2, 3, 4][play.round] }
    var body: some View {
        CountingStage(title: "Frog Hops", prompt: "Help the frog make \(target) hops. Then tap All hopped.", play: play) {
            VStack(spacing: 18) {
                Image(systemName: "leaf.circle.fill").font(.system(size: 110)).foregroundStyle(.green)
                    .offset(x: play.count.isMultiple(of: 2) ? -25 : 25)
                    .animation(reduceMotion ? nil : .spring(duration: 0.3), value: play.count)
                    .overlay(Text("🐸").font(.system(size: 52)).accessibilityHidden(true))
                Text("\(play.count) hops").font(.title.bold())
                ToddlerActionButton(title: "Hop!", systemImage: "arrow.up.circle.fill", color: .indigo) {
                    guard play.count < 5 else { return }
                    play.count += 1; play.say("\(play.count)")
                }.disabled(play.count >= 5)
                ToddlerActionButton(title: "All hopped", systemImage: "checkmark.circle.fill", color: .indigo) {
                    if play.count == target { play.win("\(target) hops! The frog reached the pond.") }
                    else { play.say(play.count < target ? "Make one more hop, then count again." : "Let's start the hops again."); if play.count > target { play.count = 0 } }
                }
                ToddlerActionButton(title: "Start hops again", systemImage: "arrow.counterclockwise", color: .indigo) { play.count = 0; play.feedback = "" }
            }
        }
    }
}

private struct CountingDrumGame: View {
    @StateObject private var play = CountingPlay()
    @StateObject private var narrator = GameNarrator()
    @State private var demonstration = 0
    @Environment(\.scenePhase) private var scenePhase
    @State private var playing = false
    @State private var beat = 0
    private var target: Int { [1, 2, 3][play.round] }
    var body: some View {
        CountingStage(title: "Counting Drum", prompt: "Listen to my counting beats. Tap the drum the same number of times.", play: play) {
            VStack(spacing: 18) {
                ToddlerActionButton(title: "Hear my beats", systemImage: "speaker.wave.2.fill", color: .indigo) { demonstration += 1 }
                Text(playing ? "Listen: \(beat)" : "Your beats: \(play.count)").font(.title.bold())
                Button {
                    guard !playing, play.count < 5 else { return }
                    play.count += 1
                    narrator.speak("\(play.count)")
                } label: {
                    Image(systemName: "circle.inset.filled").font(.system(size: 110)).foregroundStyle(.orange)
                        .frame(maxWidth: .infinity, minHeight: 160).background(.white, in: RoundedRectangle(cornerRadius: 28))
                }.buttonStyle(.plain).disabled(playing).accessibilityLabel("Drum. Tap one beat")
                ToddlerActionButton(title: "Check my beats", systemImage: "checkmark.circle.fill", color: .indigo) {
                    if play.count == target { play.win("\(target) beats. You echoed my drum!") }
                    else { play.count = 0; play.say("Let's listen again, then tap along."); demonstration += 1 }
                }.disabled(playing)
                ToddlerActionButton(title: "Clear my beats", systemImage: "arrow.counterclockwise", color: .indigo) { play.count = 0 }
            }
        }
        .task(id: demonstration) {
            let request = demonstration
            guard request > 0 else { playing = false; beat = 0; return }
            playing = true; beat = 0; play.count = 0
            // Explicit playback avoids interrupting the initial directions.
            // Task cancellation handles another playback request or leaving this game.
            do {
                try await Task.sleep(for: .milliseconds(600))
                for value in 1...target {
                    try Task.checkCancellation()
                    beat = value; narrator.speak("\(value). Boom.")
                    try await Task.sleep(for: .milliseconds(1200))
                }
                if request == demonstration { playing = false }
            } catch {
                if request == demonstration { narrator.stop(); playing = false }
            }
        }
        .onChange(of: play.round) { _, _ in demonstration = 0 }
        .onChange(of: play.complete) { _, _ in demonstration = 0 }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { demonstration = 0; narrator.stop() }
        }
        .onDisappear { narrator.stop() }
    }
}
