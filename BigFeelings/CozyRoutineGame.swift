import SwiftUI

struct CozyEveningPathGame: View {
    let onReplay: () -> Void
    @State private var play = CozyRoutinePlay()
    @State private var pathOrder = CozyRoutine.bank.shuffled()
    @State private var started = false
    @State private var dragging = false
    @State private var selectedItem = 0
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ToddlerGameScaffold(title: "Cozy Evening Path", prompt: play.prompt, accent: .indigo,
                            completion: play.phase == .complete, onReplay: onReplay) {
            if play.phase == .paths {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(pathOrder) { path in
                        Button { play.choosePath(path.id); selectedItem = 0 } label: {
                            VStack(spacing: 8) {
                                Image(systemName: path.symbol).font(.largeTitle)
                                Text(path.title).font(.headline)
                                if play.completed.contains(path.id) { Image(systemName: "checkmark.seal.fill").foregroundStyle(.green) }
                            }.frame(maxWidth: .infinity, minHeight: 110)
                                .background(.white, in: RoundedRectangle(cornerRadius: 20))
                        }.buttonStyle(.plain).accessibilityIdentifier("routine.path.\(path.id)")
                    }
                }
                Text("\(play.completed.count) of \(CozyRoutine.bank.count) paths explored").font(.headline)
                    .accessibilityIdentifier("routine.collection")
            } else if let path = play.routine {
                HStack {
                    Text(path.title).font(.title3.bold())
                    Spacer()
                    Text("\(play.completedSteps.count) of \(path.steps.count) steps").font(.subheadline.bold())
                }.accessibilityIdentifier("routine.progress")
                CozyInteractiveScene(play: play, dragging: $dragging, selectedItem: selectedItem, act: act)
                    .overlay {
                        if play.phase == .feedback {
                            VStack(spacing: 10) {
                                Label("Great job!", systemImage: "checkmark.seal.fill").font(.title2.bold()).foregroundStyle(.green)
                                Text(play.current.response).font(.headline).multilineTextAlignment(.center)
                                Button(play.completedSteps.count == path.steps.count ? "Finish this path" : "Keep going") {
                                    narrator.stop(); play.next(); selectedItem = firstUnusedItem
                                }.font(.headline).frame(minWidth: 130, minHeight: 44)
                                    .background(.indigo.opacity(0.12), in: Capsule())
                                    .accessibilityIdentifier("routine.next")
                            }.padding(18).frame(maxWidth: 310)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
                                .padding(12).accessibilityElement(children: .contain).accessibilityIdentifier("routine.success-popup")
                        }
                    }
                if play.phase == .acting || play.phase == .feedback {
                    Text("Tap a picture to try that step").font(.subheadline.bold())
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(Array(path.steps.enumerated()), id: \.offset) { index, id in
                            let step = CozyRoutineStep.named(id)
                            Button {
                                play.selectStep(index); selectedItem = firstUnusedItem
                                narrator.speak(play.current.instruction)
                            } label: {
                                VStack(spacing: 3) {
                                    CozyRoutineItemArt(step: step).scaleEffect(0.65).frame(width: 46, height: 42)
                                    Text(step.title).font(.system(size: 12, weight: .bold, design: .rounded)).multilineTextAlignment(.center)
                                    if play.completedSteps.contains(id) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                                }.frame(maxWidth: .infinity, minHeight: 76).padding(5)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(index == play.index ? Color.orange : .clear, lineWidth: 3))
                            }.buttonStyle(.plain).disabled(play.phase != .acting || play.completedSteps.contains(id))
                                .accessibilityLabel(step.title)
                                .accessibilityValue(play.completedSteps.contains(id) ? "Completed" : index == play.index ? "Selected" : "Choose this step")
                                .accessibilityIdentifier("routine.step.\(id)")
                        }
                    }
                    if play.current.kind == .pack && play.phase == .acting {
                        HStack(spacing: 10) {
                            ForEach(0..<3) { index in
                                Button { selectedItem = index } label: {
                                    Image(systemName: play.current.items[index]).font(.title2)
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .background(selectedItem == index ? .orange.opacity(0.18) : .white, in: RoundedRectangle(cornerRadius: 12))
                                }.buttonStyle(.plain).disabled(play.used.contains(index))
                                    .accessibilityLabel("Choose packing item \(index + 1)")
                                    .accessibilityIdentifier("routine.select-item.\(index)")
                            }
                        }
                    }
                    HStack {
                        Button("Choose another path") { narrator.stop(); play.pause(); play.paths(); selectedItem = 0 }
                            .frame(maxWidth: .infinity, minHeight: 44).accessibilityIdentifier("routine.paths")
                        Button("Take a break") { narrator.stop(); play.pause() }
                            .frame(maxWidth: .infinity, minHeight: 44).accessibilityIdentifier("routine.pause")
                    }
                } else if play.phase == .finished || play.phase == .paused {
                    if play.phase == .finished {
                        Label("Path explored!", systemImage: "star.fill").font(.title2.bold()).foregroundStyle(.orange)
                    }
                    ToddlerActionButton(title: "Choose another path", systemImage: "map.fill", color: .teal) { narrator.stop(); play.paths(); selectedItem = 0 }
                        .accessibilityIdentifier("routine.paths")
                    ToddlerActionButton(title: "Finish our play", systemImage: "checkmark", color: .indigo) { narrator.stop(); play.finish() }
                        .accessibilityIdentifier("routine.finish")
                }
            }
            Text("Pretend together with a grown-up. Your family's order may be different, and a pause is always okay.")
                .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.scrollDisabled(dragging)
            .onAppear {
                guard !started else { return }
                started = true; play.choosePath("bedtime")
            }
            .onDisappear { narrator.stop(); dragging = false }
    }
    private var firstUnusedItem: Int { (0..<play.current.goal).first { !play.used.contains($0) } ?? 0 }
    private func act(_ value: Int, token: String) {
        if play.act(value, token: token) { selectedItem = firstUnusedItem }
        else if play.phase == .acting { narrator.speak(CozyRoutine.actionRetry) }
    }
}

private struct CozyInteractiveScene: View {
    let play: CozyRoutinePlay
    @Binding var dragging: Bool
    let selectedItem: Int
    let act: (Int, String) -> Void
    @State private var dropFrame = CGRect.zero
    @State private var pickedUp = false
    private var step: CozyRoutineStep { play.current }
    private var puttingAway: Bool { ["shoesoff", "coatoff"].contains(step.id) }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                if let path = play.routine {
                    CozyRoutineScene(path: path, step: step, accomplished: play.completedSteps.contains(step.id),
                                     completedSteps: Array(play.completedSteps), showsItem: false, showsTeddy: step.kind != .pack)
                        .allowsHitTesting(false).accessibilityHidden(true)
                }
                if play.phase == .acting {
                    if step.kind == .dress || step.kind == .pack {
                        let targetX = geometry.size.width * (puttingAway ? 0.76 : 0.4)
                        Button { if pickedUp { act(selectedItem, play.token); pickedUp = false } } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20).fill(.clear)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.orange, style: StrokeStyle(lineWidth: 3, dash: [7, 5])))
                                if step.kind == .pack || puttingAway {
                                    Image(systemName: puttingAway ? (step.id == "coatoff" ? "hanger" : "shippingbox.fill") : step.symbol)
                                        .font(.system(size: 64)).foregroundStyle(.teal)
                                }
                            }.frame(width: min(130, geometry.size.width * 0.36), height: 160).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { dropFrame = $0 }
                            .position(x: targetX, y: 125)
                            .accessibilityLabel(puttingAway ? "Put it away here" : step.kind == .pack ? "Pack it here" : "Dress Teddy")
                            .accessibilityIdentifier("routine.drop")
                        Button { pickedUp = true } label: {
                            Group {
                                if step.kind == .pack {
                                    Image(systemName: step.items[selectedItem]).font(.system(size: 44)).foregroundStyle(.indigo)
                                } else { CozyRoutineItemArt(step: step) }
                            }.frame(width: 76, height: 76)
                                .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(pickedUp ? Color.orange : .indigo.opacity(0.2), lineWidth: 2))
                        }.buttonStyle(.plain)
                            .modifier(ImmediatePictureDrag(dragging: $dragging, target: dropFrame,
                                tap: { pickedUp = true }, drop: { act(selectedItem, play.token); pickedUp = false }))
                            .position(x: geometry.size.width * (puttingAway ? 0.4 : 0.78), y: puttingAway && step.id == "shoesoff" ? 175 : 125)
                            .accessibilityLabel(step.kind == .pack ? "Packing item \(selectedItem + 1)" : step.title)
                            .accessibilityIdentifier("routine.item.\(selectedItem)")
                    } else {
                        actions.frame(width: geometry.size.width * 0.4)
                            .position(x: geometry.size.width * 0.76, y: 135)
                    }
                }
            }
        }.frame(height: 210)
            .contentShape(.accessibility, Rectangle())
            .accessibilityElement(children: .contain).accessibilityIdentifier("routine.scene")
            .onChange(of: play.token) { _, _ in pickedUp = false }
    }
    @ViewBuilder private var actions: some View {
        switch step.kind {
        case .wash, .scrub, .walk:
            let names = step.kind == .wash ? ["Wet", "Soap", "Rub", "Rinse", "Dry"] : ["1", "2", "3"]
            let symbols = step.kind == .wash ? ["drop.fill", "bubbles.and.sparkles.fill", "hands.clap.fill", "spigot.fill", "rectangle.fill"] : Array(repeating: step.kind == .walk ? "shoeprints.fill" : "sparkles", count: 3)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(0..<step.goal, id: \.self) { index in
                    Button { act(index, play.token) } label: {
                        VStack(spacing: 3) {
                            Image(systemName: play.used.contains(index) ? "checkmark.circle.fill" : symbols[index]).font(.title3)
                            Text(names[index]).font(.caption.bold())
                        }.frame(maxWidth: .infinity, minHeight: 48).padding(3)
                            .background(.white, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(index == play.actions || step.kind == .scrub ? Color.orange : .clear, lineWidth: 2))
                    }.buttonStyle(.plain).disabled(play.used.contains(index))
                        .accessibilityIdentifier("routine.action.\(index)")
                }
            }
        case .pages, .tap:
            Button { act(play.actions, play.token) } label: {
                VStack(spacing: 8) {
                    CozyRoutineItemArt(step: step)
                    Text(step.kind == .pages ? "Turn a page" : "Try this step").font(.subheadline.bold()).multilineTextAlignment(.center)
                    if step.kind == .pages { Text("\(play.actions) of 3 pages").font(.caption.bold()) }
                }.padding(8).frame(maxWidth: .infinity, minHeight: 100)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.orange, lineWidth: 3))
            }.buttonStyle(.plain).accessibilityIdentifier("routine.action.\(play.actions)")
        case .dress, .pack: EmptyView()
        }
    }
}

struct CozyRoutineScene: View {
    let path: CozyRoutine
    let step: CozyRoutineStep
    let accomplished: Bool
    var completedSteps: [String] = []
    var showsItem = true
    var showsTeddy = true
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
                if showsTeddy {
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
                }
                if showsItem {
                VStack(spacing: 12) {
                    CozyRoutineItemArt(step: step)
                    Image(systemName: accomplished ? "checkmark.seal.fill" : "questionmark.bubble.fill").font(.title).foregroundStyle(accomplished ? .green : .orange)
                }.position(x: g.size.width * 0.76, y: 140)
                }
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
