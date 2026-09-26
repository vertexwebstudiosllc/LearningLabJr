import SwiftUI

struct CozyEveningPathGame: View {
    let onReplay: () -> Void
    @State private var play = CozyRoutinePlay()
    @State private var pathOrder = CozyRoutine.bank.shuffled()
    @State private var dragging = false
    @State private var dropFrame = CGRect.zero
    @State private var selectedItem: Int?
    @State private var feedback = ""
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Cozy Evening Path", prompt: play.prompt, accent: .indigo,
                            completion: play.phase == .complete, onReplay: onReplay,
                            scrollToTopOnPromptChange: play.phase != .acting) {
            if play.phase == .paths {
                Text("Bedtime and everyday adventures").font(.title2.bold()).multilineTextAlignment(.center)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(pathOrder) { path in
                        VStack {
                            Button { feedback = ""; play.choosePath(path.id) } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: path.symbol).font(.system(size: 48)).foregroundStyle(.indigo)
                                    Text(path.title).font(.headline)
                                    if play.completed.contains(path.id) { Image(systemName: "checkmark.seal.fill").foregroundStyle(.green) }
                                }.frame(maxWidth: .infinity, minHeight: 132).padding(10).background(.white, in: RoundedRectangle(cornerRadius: 23))
                            }.buttonStyle(.plain).accessibilityIdentifier("routine.path.\(path.id)")
                            Button { narrator.speak(path.title) } label: { Label("Hear", systemImage: "speaker.wave.2.fill").frame(minHeight: 44) }
                                .accessibilityLabel("Hear \(path.title)")
                        }
                    }
                }
                Text("\(play.completed.count) of 8 paths explored").font(.headline).accessibilityIdentifier("routine.collection")
            } else if let path = play.routine {
                Text(path.title).font(.title2.bold())
                CozyRoutineScene(path: path, step: play.current, accomplished: play.actions == play.current.goal, completedSteps: Array(path.steps.prefix(play.index)) + (play.actions == play.current.goal ? [play.current.id] : []))
                if play.phase != .complete {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(Array(path.steps.enumerated()), id: \.offset) { index, id in
                            VStack(spacing: 5) {
                                Image(systemName: CozyRoutineStep.named(id).symbol).font(.title3)
                                Text("\(index + 1)").font(.caption.bold())
                                if index < play.index || (index == play.index && [.feedback, .finished].contains(play.phase)) {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                }
                            }.frame(maxWidth: .infinity, minHeight: 60).background(index == play.index ? Color.indigo.opacity(0.16) : .gray.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
                                .accessibilityLabel("Step \(index + 1), \(CozyRoutineStep.named(id).title)")
                        }
                    }
                }
                switch play.phase {
                case .introduction:
                    ToddlerActionButton(title: "Start this path", systemImage: "play.fill", color: .indigo) { play.start() }
                        .accessibilityIdentifier("routine.start")
                case .choosing:
                    Text("Step \(play.index + 1) of \(path.steps.count)").font(.headline).accessibilityIdentifier("routine.progress")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(play.choices, id: \.self) { id in
                            let step = CozyRoutineStep.named(id)
                            VStack {
                                Button {
                                    if play.chooseStep(id) { feedback = ""; selectedItem = nil }
                                    else { feedback = CozyRoutine.retry; narrator.speak(feedback) }
                                } label: {
                                    VStack(spacing: 10) {
                                        CozyRoutineItemArt(step: step).frame(width: 70, height: 64)
                                        Text(step.title).font(.headline).multilineTextAlignment(.center)
                                    }.frame(maxWidth: .infinity, minHeight: 145).padding(7).background(.white, in: RoundedRectangle(cornerRadius: 20))
                                }.buttonStyle(.plain).accessibilityIdentifier("routine.choice.\(id)")
                                Button { narrator.speak(step.title) } label: { Image(systemName: "speaker.wave.2.fill").frame(width: 44, height: 44) }
                                    .accessibilityLabel("Hear \(step.title)")
                            }
                        }
                    }
                case .acting:
                    activity
                    Text("\(play.actions) of \(play.current.goal) actions").font(.headline).accessibilityIdentifier("routine.actions")
                case .feedback:
                    Label("One little step done!", systemImage: "checkmark.seal.fill").font(.title2.bold()).foregroundStyle(.green)
                    ToddlerActionButton(title: play.index == path.steps.count - 1 ? "Finish this path" : "What comes next?", systemImage: "arrow.right", color: .indigo) {
                        narrator.stop(); selectedItem = nil; feedback = ""; play.next()
                    }.accessibilityIdentifier("routine.next")
                case .finished, .paused:
                    if play.phase == .finished {
                        Label("Path explored!", systemImage: "star.fill").font(.title2.bold()).foregroundStyle(.orange)
                    }
                    ToddlerActionButton(title: "Choose another path", systemImage: "map.fill", color: .teal) { narrator.stop(); feedback = ""; selectedItem = nil; play.paths() }
                        .accessibilityIdentifier("routine.paths")
                    ToddlerActionButton(title: "Finish our play", systemImage: "checkmark", color: .indigo) { narrator.stop(); play.finish() }
                        .accessibilityIdentifier("routine.finish")
                case .paths, .complete: EmptyView()
                }
                if !feedback.isEmpty { Text(feedback).font(.headline).multilineTextAlignment(.center).accessibilityIdentifier("routine.feedback") }
                if [.introduction, .choosing, .acting, .feedback].contains(play.phase) {
                    Button("Take a break") { narrator.stop(); feedback = ""; selectedItem = nil; play.pause() }
                        .frame(minHeight: 48).accessibilityIdentifier("routine.pause")
                }
            }
            Text("These are Teddy's pretend plans. Your family's order may be different. A grown-up can help, and a pause is always okay.")
                .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.scrollDisabled(dragging)
            .onDisappear { narrator.stop(); dragging = false }
    }
    private func act(_ value: Int, token: String) {
        if play.act(value, token: token) { feedback = ""; selectedItem = nil }
        else if play.phase == .acting { feedback = CozyRoutine.actionRetry; narrator.speak(feedback) }
    }
    @ViewBuilder private var activity: some View {
        switch play.current.kind {
        case .dress, .pack:
            HStack(spacing: 12) {
                ForEach(0..<(play.current.kind == .pack ? 3 : 1), id: \.self) { index in
                    Button { selectedItem = index } label: {
                        Group {
                            if play.current.kind == .dress { CozyRoutineItemArt(step: play.current) }
                            else { Image(systemName: play.current.items[index]).font(.system(size: 42)).foregroundStyle(.indigo) }
                        }.frame(maxWidth: .infinity, minHeight: 80)
                            .background(.white, in: RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(selectedItem == index ? Color.orange : .clear, lineWidth: 3))
                    }.buttonStyle(.plain).disabled(play.used.contains(index)).opacity(play.used.contains(index) ? 0.2 : 1)
                        .modifier(ImmediatePictureDrag(dragging: $dragging, target: dropFrame,
                            tap: { selectedItem = index }, drop: { act(index, token: play.token) })).accessibilityLabel(play.current.kind == .dress ? play.current.title : "Packing item \(index + 1)")
                        .accessibilityIdentifier("routine.item.\(index)")
                }
            }
            Text("Drag the picture, or tap it and then tap its spot.").font(.subheadline).multilineTextAlignment(.center)
            Button { if let selectedItem { act(selectedItem, token: play.token) } } label: {
                VStack(spacing: 10) {
                    if play.current.kind == .dress && !["shoesoff", "coatoff"].contains(play.current.id) {
                        RescueTeddy(fur: .brown, identity: .boy, items: []).frame(width: 88, height: 124)
                    } else {
                        Image(systemName: play.current.kind == .pack ? play.current.symbol : play.current.id == "coatoff" ? "hanger" : "shippingbox.fill").font(.system(size: 62)).foregroundStyle(.teal)
                    }
                    Text(play.current.kind == .dress ? (["shoesoff", "coatoff"].contains(play.current.id) ? "Put it away here" : "Ready, Teddy!") : "Pack it here").font(.headline)
                    if play.current.kind == .pack {
                        HStack { ForEach(Array(play.used).sorted(), id: \.self) { i in Image(systemName: play.current.items[i]).foregroundStyle(.teal) } }
                    }
                }.frame(maxWidth: .infinity, minHeight: 150).padding(16).background(.teal.opacity(0.09), in: RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(.orange, lineWidth: 3))
            }.buttonStyle(.plain).accessibilityIdentifier("routine.drop")
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { dropFrame = $0 }
                .dropDestination(for: String.self) { values, _ in
                    guard values.count == 1, play.phase == .acting else { return false }
                    let parts = values[0].split(separator: ":")
                    guard parts.count == 4, let index = Int(parts[3]), parts.prefix(3).joined(separator: ":") == play.token else { return false }
                    let before = play.actions; act(index, token: play.token); return play.actions > before
                }
        case .wash:
            let names = ["Wet", "Soap", "Rub", "Rinse", "Dry"]
            let symbols = ["drop.fill", "bubbles.and.sparkles.fill", "hands.clap.fill", "spigot.fill", "rectangle.fill"]
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(0..<5) { index in
                    actionTile(index, title: names[index], symbol: symbols[index], active: index == play.actions)
                }
            }
        case .scrub:
            Image(systemName: play.current.symbol).font(.system(size: 78)).foregroundStyle(.indigo).frame(height: 100)
            HStack(spacing: 18) {
                ForEach(0..<3) { index in actionTile(index, title: "\(index + 1)", symbol: "sparkles", active: !play.used.contains(index)) }
            }
        case .pages:
            Button { act(play.actions, token: play.token) } label: {
                VStack(spacing: 12) {
                    ZStack {
                        Image(systemName: "book.fill").font(.system(size: 130)).foregroundStyle(.purple)
                        Image(systemName: ["star.fill", "hare.fill", "moon.fill"][min(play.actions, 2)]).font(.system(size: 40)).foregroundStyle(.yellow)
                    }
                    Text("Turn a page").font(.title2.bold())
                }.frame(maxWidth: .infinity).padding(20).background(.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 24))
            }.buttonStyle(.plain).accessibilityIdentifier("routine.action.\(play.actions)")
        case .walk:
            HStack(alignment: .center, spacing: 14) {
                ForEach(0..<3) { index in
                    actionTile(index, title: "\(index + 1)", symbol: "shoeprints.fill", active: index == play.actions)
                        .offset(y: index == 1 ? -14 : 14)
                }
            }.padding(.vertical, 20)
        case .tap:
            Button { act(0, token: play.token) } label: {
                VStack(spacing: 14) {
                    if play.current.id == "bed" { Image(systemName: "moon.fill").font(.system(size: 44)).foregroundStyle(.indigo) }
                    else { CozyRoutineItemArt(step: play.current) }
                    Text(play.current.id == "potty" ? "Pretend or watch together" : "Try this step together").font(.headline)
                }.frame(maxWidth: .infinity, minHeight: 125).padding(12).background(.white, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.orange, lineWidth: 3))
            }.buttonStyle(.plain).accessibilityIdentifier("routine.action.0")
        }
    }
    private func actionTile(_ index: Int, title: String, symbol: String, active: Bool) -> some View {
        Button { act(index, token: play.token) } label: {
            VStack(spacing: 10) {
                Image(systemName: play.used.contains(index) ? "checkmark.circle.fill" : symbol).font(.system(size: 35))
                Text(title).font(.headline).multilineTextAlignment(.center)
            }.foregroundStyle(.indigo).frame(maxWidth: .infinity, minHeight: 92).padding(8)
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(active ? Color.orange : .clear, lineWidth: 3))
        }.buttonStyle(.plain).disabled(play.used.contains(index)).opacity(play.used.contains(index) ? 0.4 : 1)
            .accessibilityIdentifier("routine.action.\(index)")
    }
}

struct CozyRoutineScene: View {
    let path: CozyRoutine
    let step: CozyRoutineStep
    let accomplished: Bool
    var completedSteps: [String] = []
    private var resting: Bool { step.id == "bed" && accomplished }
    private var outdoors: Bool { ["rain", "snow", "beach", "picnic"].contains(path.id) }
    var body: some View {
        GeometryReader { g in
            ZStack {
                RoundedRectangle(cornerRadius: 26).fill(path.id == "bedtime" ? Color.indigo.opacity(0.18) : Color.cyan.opacity(0.13))
                VStack {
                    HStack {
                        Image(systemName: path.symbol).font(.system(size: 37)).foregroundStyle(path.id == "bedtime" ? .indigo : .orange)
                        Spacer()
                        Image(systemName: outdoors ? (path.id == "beach" ? "beach.umbrella.fill" : "tree.fill") : (path.id == "bathroom" ? "toilet.fill" : "window.vertical.closed"))
                            .font(.system(size: 45)).foregroundStyle(.teal)
                    }.padding(16)
                    Spacer()
                    Rectangle().fill(path.id == "snow" ? .white : outdoors ? Color.green.opacity(0.22) : .brown.opacity(0.14)).frame(height: 40)
                }.clipShape(RoundedRectangle(cornerRadius: 26))
                if resting {
                    RoundedRectangle(cornerRadius: 14).fill(.purple.opacity(0.3)).frame(width: 170, height: 80).position(x: g.size.width * 0.4, y: 154)
                    RoundedRectangle(cornerRadius: 10).fill(.white).frame(width: 46, height: 65).position(x: g.size.width * 0.4 - 55, y: 143)
                }
                RescueTeddy(fur: .brown, identity: .boy, items: []).frame(width: 98, height: 144)
                    .rotationEffect(.degrees(resting ? -90 : 0)).position(x: g.size.width * 0.4, y: resting ? 145 : 125)
                if resting {
                    RoundedRectangle(cornerRadius: 10).fill(.indigo.opacity(0.9)).frame(width: 99, height: 72).position(x: g.size.width * 0.4 + 34, y: 157)
                    Image(systemName: "star.fill").foregroundStyle(.yellow).position(x: g.size.width * 0.4 + 34, y: 151)
                }
                let clothes = completedSteps.contains("pajamas") ? "tshirt.fill" : completedSteps.contains("raincoat") || completedSteps.contains("warmcoat") || (path.id == "home" && !completedSteps.contains("coatoff")) ? "jacket.fill" : completedSteps.contains("clothes") || path.id == "bathroom" ? "tshirt.fill" : nil
                if let clothes, !resting {
                    Image(systemName: clothes).font(.system(size: 59)).foregroundStyle(.indigo)
                        .position(x: g.size.width * 0.4, y: 134)
                }
                if completedSteps.contains("boots") || completedSteps.contains("snowboots") || (path.id == "home" && !completedSteps.contains("shoesoff")) {
                    SolutionToolArt(tool: .named("boots")).scaleEffect(0.65).frame(width: 59, height: 39)
                        .position(x: g.size.width * 0.4, y: 181)
                }
                if completedSteps.contains("hat") || completedSteps.contains("sunhat") {
                    if completedSteps.contains("sunhat") {
                        Image(systemName: "hat.widebrim.fill").font(.system(size: 44)).foregroundStyle(.orange).position(x: g.size.width * 0.4, y: 61)
                    } else {
                        SolutionToolArt(tool: .named("hat")).scaleEffect(0.65).frame(width: 59, height: 39).position(x: g.size.width * 0.4, y: 61)
                    }
                }
                if completedSteps.contains("umbrella") {
                    Image(systemName: "umbrella.fill").font(.system(size: 76)).foregroundStyle(.purple)
                        .position(x: g.size.width * 0.23, y: 70)
                }
                VStack(spacing: 12) {
                    CozyRoutineItemArt(step: step)
                    Image(systemName: accomplished ? "checkmark.seal.fill" : "questionmark.bubble.fill").font(.title).foregroundStyle(accomplished ? .green : .orange)
                }.position(x: g.size.width * 0.76, y: 140)
            }
        }.frame(height: 210).accessibilityElement(children: .ignore)
            .accessibilityLabel("Teddy's \(path.title) scene. \(step.title)\(accomplished ? " completed" : " is next")")
    }
}

struct CozyRoutineItemArt: View {
    let step: CozyRoutineStep
    var body: some View {
        Group {
            if step.id == "wipe" {
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(.white).frame(width: 35, height: 34).offset(x: 12, y: 13)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(.indigo.opacity(0.35), lineWidth: 2).frame(width: 35, height: 34).offset(x: 12, y: 13))
                    RoundedRectangle(cornerRadius: 9).fill(.white).frame(width: 53, height: 33).overlay(RoundedRectangle(cornerRadius: 9).stroke(.indigo.opacity(0.5), lineWidth: 2)).offset(y: -9)
                    Ellipse().fill(.indigo.opacity(0.15)).frame(width: 17, height: 30).overlay(Ellipse().stroke(.indigo.opacity(0.5), lineWidth: 2)).offset(x: -21, y: -9)
                    Ellipse().fill(.brown).frame(width: 7, height: 12).offset(x: -21, y: -9)
                    Path { p in p.move(to: CGPoint(x: 31, y: 38)); p.addLine(to: CGPoint(x: 60, y: 38)) }.stroke(.indigo.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [3, 3])).frame(width: 70, height: 64)
                }
            } else if ["boots", "snowboots"].contains(step.id) {
                SolutionToolArt(tool: .named("boots")).scaleEffect(0.78).frame(width: 70, height: 55)
            } else if step.id == "hat" {
                SolutionToolArt(tool: .named("hat")).scaleEffect(0.78).frame(width: 70, height: 55)
            } else {
                Image(systemName: step.symbol).font(.system(size: 42)).foregroundStyle(.indigo)
            }
        }.frame(width: 70, height: 64).accessibilityHidden(true)
    }
}
