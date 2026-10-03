import SwiftUI

struct SolutionToolboxGame: View {
    let onReplay: () -> Void
    @AppStorage("feelings.tools.lastFirst") private var lastFirst = ""
    @State private var play = SolutionPlay()
    @State private var started = false
    @State private var toolboxOpen = false
    @State private var feedback = ""
    @State private var nudge = 0
    @State private var showNudge = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var narrator = GameNarrator()
    private var prompt: String { play.solved ? play.current.resolution : play.current.question }
    var body: some View {
        ToddlerGameScaffold(title: "My Solution Toolbox", prompt: prompt, accent: .indigo,
                            completion: play.complete, onReplay: onReplay, scrollToTopOnPromptChange: true) {
            Text("Problem \(min(play.index + 1, play.rounds.count)) of \(play.rounds.count)")
                .font(.headline).accessibilityIdentifier("solution.progress")
            SolutionProblemScene(problem: play.current, solved: play.solved)
            if play.solved {
                Label("We found a solution!", systemImage: "checkmark.seal.fill").font(.title2.bold()).foregroundStyle(.green)
                ToddlerActionButton(title: play.index == play.rounds.count - 1 ? "Finish our adventures" : "Next problem", systemImage: "arrow.right", color: .indigo) {
                    narrator.stop(); feedback = ""; play.next()
                }.accessibilityIdentifier("solution.next")
            } else {
                requiredTools
                Button { feedback = ""; toolboxOpen = true } label: {
                    VStack(spacing: 10) {
                        SolutionToolboxIcon().foregroundStyle(.indigo).frame(width: 90, height: 74)
                        Text("Open the toolbox").font(.title2.bold())
                        Text("Find \(play.current.required.count) helpful \(play.current.required.count == 1 ? "tool" : "tools")").font(.headline)
                    }.frame(maxWidth: .infinity).padding(18).background(.indigo.opacity(0.12), in: RoundedRectangle(cornerRadius: 26))
                }.buttonStyle(.plain).accessibilityIdentifier("solution.open")
                    .accessibilityValue(showNudge ? "Tap to find the pictured tools" : "")
                    .overlay(RoundedRectangle(cornerRadius: 26).stroke(showNudge ? .orange : .clear, lineWidth: 3))
                    .phaseAnimator([0.0, -5, 5, -3, 3, 0], trigger: nudge) { content, angle in
                        content.rotationEffect(.degrees(reduceMotion ? 0 : angle))
                    } animation: { _ in .easeInOut(duration: 0.14) }
            }
            Text("Try pretend solutions together. Ask a grown-up to help with real repairs.")
                .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .sheet(isPresented: $toolboxOpen, onDismiss: { narrator.stop() }) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        Text(play.current.question).font(.title3.bold()).multilineTextAlignment(.center)
                        requiredTools
                        Button { narrator.speak(play.current.question) } label: {
                            Label("Hear the problem", systemImage: "speaker.wave.2.fill").padding(10)
                        }
                        Text("\(play.selected.count) of \(play.current.required.count) helpful tools found").font(.headline)
                        if !feedback.isEmpty { Text(feedback).font(.headline).foregroundStyle(.indigo).accessibilityIdentifier("solution.feedback") }
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(play.choices, id: \.self) { id in
                                let tool = SolutionTool.named(id)
                                VStack(spacing: 2) {
                                    Button {
                                        let accepted = play.choose(id, problem: play.current.id)
                                        if accepted && play.solved { toolboxOpen = false; feedback = "" }
                                        else {
                                            feedback = accepted ? SolutionProblem.found : SolutionProblem.tryAgain
                                            narrator.speak(feedback)
                                        }
                                    } label: {
                                        VStack(spacing: 12) {
                                            SolutionToolArt(tool: tool)
                                            Text(tool.title).font(.headline).multilineTextAlignment(.center)
                                            Image(systemName: play.selected.contains(id) ? "checkmark.circle.fill" : "plus.circle.fill")
                                        }.frame(maxWidth: .infinity, minHeight: 145).padding(8)
                                            .background(play.selected.contains(id) ? Color.green.opacity(0.16) : Color.indigo.opacity(0.09), in: RoundedRectangle(cornerRadius: 20))
                                    }.buttonStyle(.plain).disabled(play.selected.contains(id))
                                        .accessibilityIdentifier("solution.tool.\(id)")
                                    Button { narrator.speak(tool.title) } label: {
                                        Label("Hear", systemImage: "speaker.wave.2.fill").frame(minHeight: 44)
                                    }.accessibilityLabel("Hear \(tool.title)")
                                }
                            }
                        }
                    }.padding(20)
                }
                .navigationTitle("Choose helpful tools").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Close") { toolboxOpen = false } } }
                .onAppear { narrator.speak(play.current.question) }
            }.presentationDetents([.large])
                .environment(\.gameViewportSize, nil)
                .environment(\.gameContentScale, 1)
        }
        .task(id: "\(play.current.id):\(toolboxOpen):\(play.solved):\(scenePhase)") {
            showNudge = false
            guard !toolboxOpen, !play.solved, !play.complete, scenePhase == .active else { return }
            do { try await Task.sleep(for: .seconds(3)) } catch { return }
            guard !Task.isCancelled else { return }
            showNudge = true
            nudge += 1
        }
        .onAppear {
            guard !started else { return }
            play = SolutionPlay(previousFirst: lastFirst); lastFirst = play.current.id; started = true
        }.onDisappear { narrator.stop() }
    }

    private var requiredTools: some View {
        VStack(spacing: 6) {
            Text("Find these helpful tools").font(.headline)
            HStack(alignment: .top, spacing: 12) {
                ForEach(play.current.required, id: \.self) { id in
                    let tool = SolutionTool.named(id)
                    VStack(spacing: 4) {
                        SolutionToolArt(tool: tool).scaleEffect(0.75).frame(width: 68, height: 45)
                        Text(tool.title).font(.system(.caption, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)
                        if play.selected.contains(id) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                    }.frame(maxWidth: .infinity).padding(8)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(tool.title)
                        .accessibilityValue(play.selected.contains(id) ? "Found" : "Find in the toolbox")
                        .accessibilityIdentifier("solution.find.\(id)")
                }
            }
        }.accessibilityElement(children: .contain).accessibilityIdentifier("solution.required-tools")
    }
}

struct SolutionProblemScene: View {
    let problem: SolutionProblem
    let solved: Bool
    private var outdoors: Bool { problem.id != "rain" && ["rain", "snow", "garden"].contains(problem.setting) }
    var body: some View {
        VStack(spacing: 8) {
            Text(problem.title).font(.title2.bold())
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(problem.setting == "night" ? Color.indigo.opacity(0.25) : Color.cyan.opacity(0.14))
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: problem.setting == "night" ? "moon.stars.fill" : problem.setting == "rain" ? "cloud.rain.fill" : problem.setting == "snow" ? "cloud.snow.fill" : "sun.max.fill")
                            .font(.system(size: 38)).foregroundStyle(problem.setting == "night" ? .indigo : .orange)
                        Spacer()
                        if !outdoors {
                            Image(systemName: "window.vertical.closed").font(.system(size: 48)).foregroundStyle(.teal)
                        } else {
                            Image(systemName: "tree.fill").font(.system(size: 50)).foregroundStyle(.green)
                        }
                    }.padding(20)
                    Spacer()
                    Rectangle().fill(outdoors ? Color.green.opacity(0.3) : Color.brown.opacity(0.18)).frame(height: 65)
                }.clipShape(RoundedRectangle(cornerRadius: 24))
                HStack(alignment: .bottom, spacing: 24) {
                    Image(systemName: "teddybear.fill").font(.system(size: 82)).foregroundStyle(.brown)
                    VStack(spacing: 8) {
                        SolutionSituationArt(problem: problem, solved: solved)
                        if !solved {
                            Image(systemName: "questionmark.bubble.fill").font(.title).foregroundStyle(.orange)
                        } else {
                            HStack {
                                ForEach(problem.required, id: \.self) { id in
                                    Image(systemName: SolutionTool.named(id).symbol).font(.title2).foregroundStyle(.teal)
                                }
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                            }
                        }
                    }
                }.offset(y: 27)
            }.frame(height: 245)
        }.accessibilityElement(children: .ignore)
            .accessibilityLabel(solved ? problem.resolution : problem.question)
            .accessibilityIdentifier("solution.scene.\(problem.id)")
    }
}
