import SwiftUI

struct DayNightGame: View {
    @AppStorage("nature.dayNight.lastFirst") private var lastFirst = ""
    @AppStorage("nature.dayNight.lastLevel") private var lastLevel = ""
    @State private var play: DayNightPlay?

    var body: some View {
        ToddlerGameScaffold(title: "Day & Night", prompt: play?.prompt ?? DayNightRoutine.invitation,
                            accent: .indigo, completion: play?.complete == true, onReplay: { play = nil }) {
            if let session = play {
                if session.complete {
                    Label("18 routines explored together!", systemImage: "heart.fill")
                        .font(.title2.bold()).multilineTextAlignment(.center)
                } else {
                    activity(session)
                }
            } else {
                HStack(spacing: 24) {
                    RoutineWindow(night: false, closed: false)
                    RoutineWindow(night: true, closed: false)
                }.frame(height: 140).accessibilityHidden(true)
                Text("Daytime discoveries and cozy bedtime routines")
                    .font(.title2.bold()).multilineTextAlignment(.center)
                Text("Find what we need, put things in place, and practice routines together.")
                    .multilineTextAlignment(.center)
                ToddlerActionButton(title: "Let's explore", systemImage: "sun.max.fill", color: .indigo) {
                    let session = DayNightPlay(previousFirst: lastFirst, previousLevel: lastLevel)
                    play = session; lastFirst = session.current.id; lastLevel = session.current.id
                }.accessibilityIdentifier("routine.begin")
            }
        }
    }

    @ViewBuilder private func activity(_ session: DayNightPlay) -> some View {
        let routine = session.current
        let night = routine.time == .night
        HStack {
            Label(night ? "Nighttime" : "Daytime", systemImage: night ? "moon.stars.fill" : "sun.max.fill")
                .font(.headline).foregroundStyle(night ? .indigo : .orange)
            Spacer()
            Text("\(session.index + 1) of \(session.rounds.count)").font(.headline)
                .accessibilityIdentifier("routine.progress")
        }
        Text(routine.title).font(.system(.title2, design: .rounded, weight: .bold))
            .multilineTextAlignment(.center).accessibilityIdentifier("routine.level.\(routine.id)")
        RoutineScene(routine: routine, collected: session.collected, solved: session.solved)
            .frame(height: 165).accessibilityLabel("\(routine.time.rawValue)time: \(routine.title)")
        if session.solved {
            Label("We did it!", systemImage: "checkmark.circle.fill").font(.title2.bold()).foregroundStyle(.green)
            ToddlerActionButton(title: session.index == session.rounds.count - 1 ? "Finish exploring" : "Next activity", systemImage: "arrow.right", color: .indigo) {
                play?.advance(from: routine.id)
                if let next = play, !next.complete { lastLevel = next.current.id }
            }.accessibilityIdentifier("routine.next")
        } else {
            if routine.kind == .collect {
                Button {
                    if let selected = play?.selected { _ = play?.place(selected, in: routine.id) }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: RoutineDestination.symbol(routine.destination)).font(.largeTitle)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(RoutineDestination.name(routine.destination)).font(.headline)
                            Text(session.selected == nil ? "Drag here, or tap an item first" : "Tap here to place your item")
                                .font(.subheadline)
                        }
                        Spacer(minLength: 0)
                        Text("\(session.collected.count)/3").font(.headline)
                    }.padding(16).frame(maxWidth: .infinity, minHeight: 86)
                        .background(.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 22))
                        .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(.indigo, style: StrokeStyle(lineWidth: 2, dash: [7])))
                }.buttonStyle(.plain)
                    .accessibilityLabel("Place selected item in \(RoutineDestination.name(routine.destination))")
                    .accessibilityIdentifier("routine.destination")
                    .dropDestination(for: String.self) { items, _ in
                        guard items.count == 1, let item = items.first else { return false }
                        return play?.drop(item) ?? false
                    }
            } else if routine.kind == .sequence {
                Text("Step \(session.step + 1) of 3 · \(session.step == 0 ? "First" : session.step == 1 ? "Next" : "Last")")
                    .font(.headline).accessibilityIdentifier("routine.step")
            } else {
                Text("Tap the item we need").font(.headline)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: routine.kind == .collect ? 2 : 3), spacing: 12) {
                ForEach(session.choices[session.index], id: \.self) { id in
                    let item = RoutineItem.named(id)
                    let done = session.collected.contains(id)
                    Button { play?.choose(id, in: routine.id) } label: {
                        VStack(spacing: 8) {
                            if routine.kind == .collect && !done {
                                RoutineItemArt(item: item).frame(height: 68)
                                    .draggable("\(routine.id)|\(id)")
                            } else {
                                RoutineItemArt(item: item).frame(height: 68)
                            }
                            Text(item.name).font(.system(.subheadline, design: .rounded, weight: .bold))
                                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                            if done { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                        }.padding(10).frame(maxWidth: .infinity, minHeight: 120)
                            .background(done ? Color.green.opacity(0.1) : .white, in: RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(session.selected == id ? Color.indigo : Color.indigo.opacity(0.14), lineWidth: session.selected == id ? 3 : 1))
                            .opacity(done ? 0.6 : 1)
                    }.buttonStyle(.plain).disabled(done)
                        .accessibilityLabel(item.name + (done ? ", finished" : ""))
                        .accessibilityAddTraits(session.selected == id ? [.isSelected] : [])
                        .accessibilityIdentifier("routine.item.\(id)")
                }
            }
            if session.needsHelp {
                Label("Let's try again together", systemImage: "heart.fill")
                    .font(.headline).foregroundStyle(.indigo).accessibilityIdentifier("routine.retry")
            }
        }
    }
}

private enum RoutineDestination {
    static func name(_ id: String) -> String {
        switch id {
        case "backpack": return "Backpack"
        case "table": return "Table"
        case "artbox": return "Art tray"
        case "toybox": return "Toy box"
        case "basket": return "Clothes basket"
        default: return "Bed"
        }
    }
    static func symbol(_ id: String) -> String {
        switch id {
        case "backpack": return "backpack.fill"
        case "table": return "table.furniture.fill"
        case "artbox": return "tray.fill"
        case "toybox": return "shippingbox.fill"
        case "basket": return "basket.fill"
        case "sink": return "drop.fill"
        case "bath": return "bathtub.fill"
        case "door": return "door.left.hand.open"
        default: return "bed.double.fill"
        }
    }
}

private struct RoutineScene: View {
    let routine: DayNightRoutine
    let collected: Set<String>
    let solved: Bool
    var body: some View {
        let night = routine.time == .night
        ZStack {
            RoundedRectangle(cornerRadius: 24).fill(night ? Color.indigo.opacity(0.16) : Color.yellow.opacity(0.18))
            VStack {
                Spacer()
                Rectangle().fill(night ? .indigo.opacity(0.15) : .orange.opacity(0.15)).frame(height: 40)
            }.clipShape(RoundedRectangle(cornerRadius: 24))
            HStack(spacing: 24) {
                RoutineWindow(night: night, closed: routine.id == "curtains" && !solved)
                    .frame(width: 95, height: 105)
                VStack(spacing: 12) {
                    Image(systemName: RoutineDestination.symbol(routine.destination))
                        .font(.system(size: 58)).foregroundStyle(night ? .indigo : .brown)
                    if !collected.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(routine.items.filter { collected.contains($0) }, id: \.self) { id in
                                RoutineItemArt(item: .named(id)).frame(width: 30, height: 30)
                            }
                        }
                    }
                }.frame(maxWidth: .infinity)
            }.padding(24)
        }.accessibilityElement(children: .ignore)
    }
}

private struct RoutineWindow: View {
    let night: Bool
    let closed: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(night ? Color(red: 0.1, green: 0.16, blue: 0.36) : .cyan.opacity(0.4))
            Image(systemName: night ? "moon.stars.fill" : "sun.max.fill")
                .font(.system(size: 42)).foregroundStyle(.yellow)
            if closed {
                HStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 3).fill(.purple)
                    RoundedRectangle(cornerRadius: 3).fill(.purple)
                }.padding(5)
            }
            RoundedRectangle(cornerRadius: 16).strokeBorder(.brown.opacity(0.7), lineWidth: 6)
        }
    }
}

/// Small vector objects share the same clean background as the room and scale with the choice cards.
private struct RoutineItemArt: View {
    let item: RoutineItem
    var body: some View {
        GeometryReader { proxy in
            Group {
                if item.art.hasPrefix("asset:") {
                    Image(String(item.art.dropFirst(6))).resizable().scaledToFit()
                } else if item.art == "custom" {
                    custom.frame(width: 100, height: 100)
                        .scaleEffect(min(proxy.size.width, proxy.size.height) / 100)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                } else {
                    Image(systemName: item.art).resizable().scaledToFit()
                        .foregroundStyle(color).padding(5)
                }
            }.frame(width: proxy.size.width, height: proxy.size.height)
        }.accessibilityHidden(true)
    }
    private var color: Color {
        switch item.id {
        case "water", "bottle", "breathe": return .blue
        case "plant", "tree": return .green
        case "sun", "lamp": return .orange
        case "heart", "shirt": return .pink
        case "teddy", "shoes", "chair": return .brown
        default: return .indigo
        }
    }
    @ViewBuilder private var custom: some View {
        switch item.id {
        case "curtains": RoutineWindow(night: false, closed: true)
        case "pillow": RoundedRectangle(cornerRadius: 19).fill(.mint).frame(width: 88, height: 58).overlay(RoundedRectangle(cornerRadius: 16).stroke(.teal, lineWidth: 2).padding(7))
        case "blanket", "washcloth":
            RoundedRectangle(cornerRadius: 8).fill(item.id == "blanket" ? Color.purple : .cyan).frame(width: 76, height: 84)
                .overlay(VStack(spacing: 12) { ForEach(0..<3, id: \.self) { _ in Capsule().fill(.white.opacity(0.6)).frame(width: 61, height: 4) } })
        case "toothbrush":
            ZStack(alignment: .top) {
                Capsule().fill(.cyan).frame(width: 13, height: 80).offset(y: 8)
                RoundedRectangle(cornerRadius: 6).fill(.blue).frame(width: 19, height: 32)
                VStack(spacing: 3) { ForEach(0..<5, id: \.self) { _ in Capsule().fill(.white).frame(width: 15, height: 3) } }.offset(x: 7, y: 3)
            }.rotationEffect(.degrees(25))
        case "crayons":
            HStack(spacing: 9) {
                ForEach(0..<3, id: \.self) { i in
                    VStack(spacing: 0) {
                        Image(systemName: "triangle.fill").resizable().frame(width: 16, height: 17)
                        RoundedRectangle(cornerRadius: 2).frame(width: 16, height: 58).overlay(Rectangle().fill(.white.opacity(0.5)).frame(height: 26))
                    }.foregroundStyle([Color.red, .blue, .yellow][i])
                }
            }
        case "spoon":
            ZStack {
                Capsule().fill(.gray).frame(width: 10, height: 65).offset(y: 18)
                Ellipse().fill(.gray).frame(width: 29, height: 39).offset(y: -22)
                Ellipse().fill(.white.opacity(0.5)).frame(width: 18, height: 26).offset(y: -24)
            }.rotationEffect(.degrees(20))
        case "plate":
            Circle().fill(.white).frame(width: 80).overlay(Circle().stroke(.blue, lineWidth: 5).padding(6)).overlay(Circle().stroke(.cyan.opacity(0.4), lineWidth: 2).padding(17))
        case "hat":
            ZStack {
                Ellipse().fill(.orange).frame(width: 94, height: 24).offset(y: 19)
                RoundedRectangle(cornerRadius: 20).fill(.yellow).frame(width: 58, height: 49)
                Rectangle().fill(.orange).frame(width: 57, height: 8).offset(y: 13)
            }
        case "pants":
            ZStack(alignment: .top) {
                HStack(spacing: 8) { ForEach(0..<2, id: \.self) { _ in RoundedRectangle(cornerRadius: 6).fill(.purple).frame(width: 27, height: 72) } }
                RoundedRectangle(cornerRadius: 5).fill(.purple).frame(width: 62, height: 27)
                Capsule().fill(.pink).frame(width: 58, height: 5).offset(y: 6)
            }
        case "socks":
            HStack(spacing: 9) {
                ForEach(0..<2, id: \.self) { _ in
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 6).fill(.pink).frame(width: 23, height: 65)
                        Capsule().fill(.pink).frame(width: 38, height: 22)
                        Rectangle().fill(.white).frame(width: 23, height: 5).offset(y: -51)
                    }
                }
            }
        case "soap":
            ZStack {
                RoundedRectangle(cornerRadius: 17).fill(.mint).frame(width: 79, height: 49)
                Text("SOAP").font(.system(size: 15, weight: .bold, design: .rounded)).foregroundStyle(.teal)
                HStack(spacing: 5) { Circle().frame(width: 12); Circle().frame(width: 18); Circle().frame(width: 9) }.foregroundStyle(.cyan.opacity(0.6)).offset(y: -35)
            }
        case "wateringcan":
            ZStack {
                Circle().stroke(.teal, lineWidth: 9).frame(width: 39, height: 39).offset(x: 29, y: -5)
                Capsule().fill(.teal).frame(width: 14, height: 52).rotationEffect(.degrees(-42)).offset(x: -30, y: -16)
                RoundedRectangle(cornerRadius: 9).fill(.mint).frame(width: 56, height: 52).offset(y: 10)
                Ellipse().fill(.teal).frame(width: 52, height: 12).offset(y: -17)
            }
        default: EmptyView()
        }
    }
}
