import SwiftUI

private enum SCPaint: Int, CaseIterable, Identifiable {
    case red, yellow, blue, orange, green, purple
    var id: Int { rawValue }
    var name: String { ["Red", "Yellow", "Blue", "Orange", "Green", "Purple"][rawValue] }
    var color: Color { [.red, .yellow, .blue, .orange, .green, .purple][rawValue] }
    var symbol: String { ["heart.fill", "sun.max.fill", "drop.fill", "carrot.fill", "leaf.fill", "moon.fill"][rawValue] }
}

private enum SCShape: Int, CaseIterable, Identifiable {
    case circle, square, triangle
    var id: Int { rawValue }
    var name: String { ["Circle", "Square", "Triangle"][rawValue] }
    var symbol: String { ["circle.fill", "square.fill", "triangle.fill"][rawValue] }
    var outline: String { ["circle", "square", "triangle"][rawValue] }
    var color: Color { [.pink, .blue, .green][rawValue] }
}

private struct SCNote: View {
    let text: String
    var body: some View {
        Text(text).font(.system(.body, design: .rounded, weight: .medium))
            .foregroundStyle(.primary).multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 52).padding(14)
            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 20))
            .accessibilityAddTraits(.updatesFrequently)
    }
}

private struct SCPaintPicker: View {
    @Binding var selection: SCPaint
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
            ForEach(SCPaint.allCases) { paint in
                Button { selection = paint; narrator.speak("\(paint.name) paint selected.") } label: {
                    VStack(spacing: 6) {
                        Image(systemName: paint.symbol).font(.system(size: 27, weight: .bold))
                        Text(paint.name).font(.system(.caption, design: .rounded, weight: .bold))
                    }.foregroundStyle(paint == .yellow ? Color.black : .white)
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .background(paint.color, in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(selection == paint ? Color.primary : .clear, lineWidth: 4))
                }.buttonStyle(.plain).accessibilityLabel("\(paint.name) paint")
                    .accessibilityAddTraits(selection == paint ? .isSelected : [])
            }
        }
    }
}

struct ShapePostGame: View {
    let onReplay: () -> Void
    @State private var posted = 0
    @State private var note = "Trace the edges and name the shape together."
    @StateObject private var narrator = GameNarrator()
    private let sequence: [SCShape] = [.circle, .triangle, .square, .triangle, .circle, .square]
    private var target: SCShape { sequence[min(posted, sequence.count - 1)] }
    var body: some View {
        ToddlerGameScaffold(title: "Shape Post", prompt: posted == sequence.count ? "All six shape stamps are posted!" : "Post the \(target.name.lowercased()) in its matching opening.", accent: .blue, completion: posted == sequence.count, onReplay: onReplay) {
            Image(systemName: posted == sequence.count ? "envelope.fill" : target.symbol)
                .font(.system(size: 105, weight: .bold)).foregroundStyle(target.color)
                .frame(height: 145).accessibilityLabel("\(target.name) stamp")
            Text("\(posted) of 6 stamps posted").font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 92))], spacing: 14) {
                ForEach(SCShape.allCases) { shape in
                    Button {
                        guard posted < sequence.count else { return }
                        if shape == target { posted += 1; note = "The \(shape.name.lowercased()) fits!" }
                        else { note = "Let's look at the edges. Find the \(target.name.lowercased())." }
                        narrator.speak(note)
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: shape.outline).font(.system(size: 56, weight: .bold))
                            Text(shape.name).font(.system(.subheadline, design: .rounded, weight: .bold))
                        }.foregroundStyle(.primary).frame(maxWidth: .infinity, minHeight: 130)
                            .background(.white, in: RoundedRectangle(cornerRadius: 24))
                    }.buttonStyle(.plain)
                        .accessibilityLabel("\(shape.name) opening")
                        .accessibilityHint("Post the matching shape stamp here")
                        .accessibilityIdentifier("shapes.post.opening.\(shape.name.lowercased())")
                }
            }
            SCNote(text: note)
        }
    }
}

struct ColorLaundryGame: View {
    let onReplay: () -> Void
    @State private var index = 0
    @State private var counts = [0, 0, 0]
    @State private var note = "Look for something this color nearby."
    @StateObject private var narrator = GameNarrator()
    private let shirts: [SCPaint] = [.blue, .red, .yellow, .red, .blue, .yellow]
    private let baskets: [SCPaint] = [.red, .yellow, .blue]
    private var current: SCPaint { shirts[min(index, 5)] }
    var body: some View {
        ToddlerGameScaffold(title: "Color Laundry", prompt: index == 6 ? "All six shirts are sorted into their color baskets!" : "Put the \(current.name.lowercased()) shirt in the \(current.name.lowercased()) basket.", accent: .blue, completion: index == 6, onReplay: onReplay) {
            Image(systemName: index == 6 ? "checkmark.seal.fill" : "tshirt.fill")
                .font(.system(size: 120)).foregroundStyle(current.color)
                .shadow(color: .black.opacity(0.15), radius: 2).frame(height: 150)
                .accessibilityLabel("\(current.name) shirt")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 92))], spacing: 12) {
                ForEach(Array(baskets.enumerated()), id: \.element.id) { position, paint in
                    Button {
                        guard index < 6 else { return }
                        if paint == current { counts[position] += 1; index += 1; note = "In the \(paint.name.lowercased()) basket!" }
                        else { note = "This shirt is \(current.name.lowercased()). Let's find its basket." }
                        narrator.speak(note)
                    } label: {
                        VStack {
                            Image(systemName: "basket.fill").font(.system(size: 48)).foregroundStyle(paint.color)
                            Text(paint.name).font(.headline)
                            Text("\(counts[position]) shirts").font(.caption)
                        }.foregroundStyle(.primary).frame(maxWidth: .infinity, minHeight: 132)
                            .background(.white, in: RoundedRectangle(cornerRadius: 22))
                    }.buttonStyle(.plain)
                }
            }
            SCNote(text: note)
        }
    }
}

struct ColorLabGame: View {
    let onReplay: () -> Void
    @State private var selected: [SCPaint] = []
    @State private var discoveries: Set<SCPaint> = []
    @State private var result: SCPaint?
    @State private var note = "Predict what the paints might make."
    @StateObject private var narrator = GameNarrator()
    private var suggestion: String {
        if !discoveries.contains(.orange) { return "Try red and yellow." }
        if !discoveries.contains(.green) { return "Try yellow and blue." }
        return "Try blue and red."
    }
    var body: some View {
        ToddlerGameScaffold(title: "Little Color Lab", prompt: discoveries.count == 3 ? "You discovered orange, green, and purple by mixing paints!" : "Choose two different paints, then stir. \(suggestion)", accent: .purple, completion: discoveries.count == 3, onReplay: onReplay) {
            ZStack {
                Circle().fill((result?.color ?? .white).gradient).frame(width: 160, height: 160)
                Image(systemName: "paintbrush.pointed.fill").font(.system(size: 70)).foregroundStyle(.primary.opacity(0.7))
            }.accessibilityLabel(result.map { "Mixed \($0.name) paint" } ?? "Mixing bowl")
            HStack(spacing: 10) {
                ForEach([SCPaint.red, .yellow, .blue]) { paint in
                    Button {
                        result = nil
                        if let i = selected.firstIndex(of: paint) { selected.remove(at: i) }
                        else {
                            if selected.count == 2 { selected.removeFirst() }
                            selected.append(paint)
                        }
                        note = selected.isEmpty ? "Choose two paints to mix." : selected.map(\.name).joined(separator: " and ") + " selected."
                        narrator.speak(note)
                    } label: {
                        VStack {
                            Image(systemName: selected.contains(paint) ? "checkmark.circle.fill" : "drop.fill").font(.system(size: 30))
                            Text(paint.name).font(.headline)
                        }.foregroundStyle(paint == .yellow ? Color.black : .white)
                            .frame(maxWidth: .infinity, minHeight: 90)
                            .background(paint.color, in: RoundedRectangle(cornerRadius: 20))
                    }.buttonStyle(.plain).accessibilityAddTraits(selected.contains(paint) ? .isSelected : [])
                }
            }
            ToddlerActionButton(title: "Stir the paints", systemImage: "arrow.triangle.2.circlepath", color: .purple) {
                guard selected.count == 2 else { narrator.speak("Choose two different paint colors first."); return }
                let mixed: SCPaint = selected.contains(.red) && selected.contains(.yellow) ? .orange : selected.contains(.yellow) && selected.contains(.blue) ? .green : .purple
                result = mixed
                discoveries.insert(mixed)
                note = "\(selected[0].name) and \(selected[1].name.lowercased()) make \(mixed.name.lowercased())!"
                selected = []
                narrator.speak(note)
            }
            HStack {
                ForEach([SCPaint.orange, .green, .purple]) { paint in
                    VStack {
                        Image(systemName: discoveries.contains(paint) ? "checkmark.seal.fill" : "circle.dashed")
                            .font(.system(size: 32)).foregroundStyle(paint.color)
                        Text(paint.name).font(.caption)
                    }.frame(maxWidth: .infinity)
                }
            }
            SCNote(text: note)
        }
    }
}

struct PatternTrainGame: View {
    let onReplay: () -> Void
    @State private var round = 0
    @State private var note = "Say the shapes in a gentle rhythm."
    @StateObject private var narrator = GameNarrator()
    private let patterns: [[SCShape]] = [[.circle, .square, .circle, .square], [.triangle, .circle, .triangle, .circle], [.square, .square, .triangle, .square, .square]]
    private let answers: [SCShape] = [.circle, .triangle, .triangle]
    private var pattern: [SCShape] { patterns[min(round, 2)] }
    var body: some View {
        ToddlerGameScaffold(title: "Pattern Train", prompt: round == 3 ? "Three repeating trains are ready. Choo choo!" : "Look at the repeating train. Which shape comes next?", accent: .orange, completion: round == 3, onReplay: onReplay) {
            Image(systemName: "tram.fill").font(.system(size: 75)).foregroundStyle(.orange).accessibilityHidden(true)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 68))], spacing: 8) {
                ForEach(Array(pattern.enumerated()), id: \.offset) { _, shape in
                    Image(systemName: shape.symbol).font(.system(size: 35)).foregroundStyle(shape.color)
                        .frame(maxWidth: .infinity, minHeight: 70).background(.white, in: RoundedRectangle(cornerRadius: 16))
                        .accessibilityLabel(shape.name)
                }
                Image(systemName: round == 3 ? "checkmark" : "questionmark").font(.largeTitle)
                    .frame(maxWidth: .infinity, minHeight: 70).background(.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
            }
            ForEach(SCShape.allCases) { shape in
                ToddlerActionButton(title: shape.name, systemImage: shape.symbol, color: shape.color) {
                    guard round < 3 else { return }
                    if shape == answers[round] { round += 1; note = "\(shape.name) continues the pattern. Choo choo!" }
                    else { note = "Let's say it together: " + pattern.map(\.name).joined(separator: ", ") + ". What comes next?" }
                    narrator.speak(note)
                }
            }
            SCNote(text: note)
        }
    }
}

private struct SCTownPiece: Identifiable {
    let id: Int
    let shape: SCShape
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    let instruction: String
}

struct ShapeTownGame: View {
    let onReplay: () -> Void
    @State private var scene = 0
    @State private var placed = 0
    @StateObject private var narrator = GameNarrator()
    private let names = ["house", "rocket", "tree"]
    private var pieces: [SCTownPiece] {
        switch min(scene, 2) {
        case 0: return [
            .init(id: 0, shape: .square, color: .orange, x: 0.5, y: 0.6, width: 125, height: 125, instruction: "Add a square wall."),
            .init(id: 1, shape: .triangle, color: .pink, x: 0.5, y: 0.27, width: 150, height: 90, instruction: "Put the triangle roof above the wall."),
            .init(id: 2, shape: .circle, color: .blue, x: 0.5, y: 0.6, width: 48, height: 48, instruction: "Add a round window.")]
        case 1: return [
            .init(id: 0, shape: .square, color: .blue, x: 0.5, y: 0.56, width: 80, height: 120, instruction: "Add the rocket body."),
            .init(id: 1, shape: .triangle, color: .orange, x: 0.5, y: 0.24, width: 82, height: 70, instruction: "Put a triangle on top."),
            .init(id: 2, shape: .circle, color: .yellow, x: 0.5, y: 0.49, width: 44, height: 44, instruction: "Add a round window for the astronaut.")]
        default: return [
            .init(id: 0, shape: .square, color: .brown, x: 0.5, y: 0.72, width: 50, height: 100, instruction: "Plant the tree trunk."),
            .init(id: 1, shape: .triangle, color: .green, x: 0.5, y: 0.38, width: 170, height: 150, instruction: "Add triangle branches above the trunk."),
            .init(id: 2, shape: .circle, color: .red, x: 0.5, y: 0.42, width: 40, height: 40, instruction: "Put a round apple on the tree.")]
        }
    }
    var body: some View {
        ToddlerGameScaffold(title: "Build a Shape Town", prompt: scene == 3 ? "Your town is ready!" : placed == 3 ? "Look at your \(names[scene])!" : pieces[placed].instruction, accent: .green, completion: scene == 3, onReplay: onReplay) {
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 24).fill(.cyan.opacity(0.12))
                    ForEach(pieces) { piece in
                        Image(systemName: piece.shape.symbol).resizable().frame(width: piece.width, height: piece.height)
                            .foregroundStyle(placed > piece.id ? piece.color : piece.color.opacity(0.12))
                            .position(x: geometry.size.width * piece.x, y: 240 * piece.y)
                    }
                }
            }.frame(height: 240).accessibilityLabel("\(names[min(scene, 2)]), \(placed) of 3 pieces placed")
            if placed < 3 && scene < 3 {
                ToddlerActionButton(title: pieces[placed].instruction, systemImage: pieces[placed].shape.symbol, color: .green) {
                    guard scene < 3, placed < 3 else { return }
                    let instruction = pieces[placed].instruction
                    placed += 1
                    narrator.speak(instruction)
                }
            } else if scene < 3 {
                ToddlerActionButton(title: scene == 2 ? "Finish our town" : "Build the next picture", systemImage: "arrow.right", color: .green) {
                    guard scene < 3, placed == 3 else { return }
                    scene += 1
                    if scene < 3 { placed = 0 }
                }
            }
            SCNote(text: "Talk about above, below, and beside as your town grows.")
        }
    }
}

struct NestingShapesGame: View {
    let onReplay: () -> Void
    @State private var round = 0
    @State private var layers = 0
    @State private var note = "Show big and small with your hands."
    @StateObject private var narrator = GameNarrator()
    private let sizes: [CGFloat] = [156, 106, 58]
    private let names = ["Large", "Medium", "Small"]
    private var shape: SCShape { SCShape.allCases[min(round, 2)] }
    var body: some View {
        ToddlerGameScaffold(title: "Nesting Shapes", prompt: round == 3 ? "Three shape nests, from large to small!" : "Build a shape nest. Start with the largest, then medium, then small.", accent: .indigo, completion: round == 3, onReplay: onReplay) {
            ZStack {
                Image(systemName: shape.outline).font(.system(size: 170)).foregroundStyle(.gray.opacity(0.2))
                ForEach(0..<layers, id: \.self) { index in
                    Image(systemName: shape.symbol).resizable().scaledToFit().frame(width: sizes[index], height: sizes[index])
                        .foregroundStyle([Color.indigo, .cyan, .yellow][index])
                }
            }.frame(height: 195).accessibilityLabel("\(layers) nested \(shape.name.lowercased()) shapes")
            HStack(spacing: 10) {
                ForEach([2, 0, 1], id: \.self) { index in
                    Button {
                        guard layers < 3, round < 3 else { return }
                        if index == layers { layers += 1; note = "\(names[index]) fits in the nest." }
                        else { note = "Let's choose the \(names[layers].lowercased()) one next." }
                        narrator.speak(note)
                    } label: {
                        VStack {
                            Image(systemName: shape.symbol).resizable().scaledToFit().frame(width: sizes[index] * 0.4, height: 65)
                            Text(names[index]).font(.system(.caption, design: .rounded, weight: .bold))
                        }.foregroundStyle(.indigo).frame(maxWidth: .infinity, minHeight: 105)
                            .background(.white, in: RoundedRectangle(cornerRadius: 18)).opacity(index < layers ? 0.3 : 1)
                    }.buttonStyle(.plain).disabled(index < layers)
                }
            }
            if layers == 3 && round < 3 {
                ToddlerActionButton(title: round == 2 ? "All cozy!" : "Try another shape", systemImage: "arrow.right", color: .indigo) {
                    guard round < 3, layers == 3 else { return }
                    round += 1
                    if round < 3 { layers = 0 }
                }
            }
            SCNote(text: note)
        }
    }
}

struct ShapeTrailsGame: View {
    let onReplay: () -> Void
    @State private var round = 0
    @State private var visited = 0
    @StateObject private var narrator = GameNarrator()
    private var points: [CGPoint] {
        switch min(round, 2) {
        case 0: return (0...8).map { index in
            let angle = Double(index) * .pi / 4 - .pi / 2
            return CGPoint(x: 0.5 + cos(angle) * 0.32, y: 0.5 + sin(angle) * 0.32)
        }
        case 1: return [CGPoint(x: 0.2, y: 0.2), CGPoint(x: 0.8, y: 0.2), CGPoint(x: 0.8, y: 0.8), CGPoint(x: 0.2, y: 0.8), CGPoint(x: 0.2, y: 0.2)]
        default: return [CGPoint(x: 0.5, y: 0.14), CGPoint(x: 0.82, y: 0.8), CGPoint(x: 0.18, y: 0.8), CGPoint(x: 0.5, y: 0.14)]
        }
    }
    private var shape: SCShape { SCShape.allCases[min(round, 2)] }
    var body: some View {
        ToddlerGameScaffold(title: "Shape Trails", prompt: round == 3 ? "You followed a circle, a square, and a triangle all the way around!" : "Follow the glowing dot around the \(shape.name.lowercased()). Slide a finger or tap each dot.", accent: .teal, completion: round == 3, onReplay: onReplay) {
            GeometryReader { geometry in
                let span = min(geometry.size.width, geometry.size.height)
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let locations = points.map { CGPoint(x: center.x + ($0.x - 0.5) * span, y: center.y + ($0.y - 0.5) * span) }
                let nextIndex = visited
                ZStack {
                    RoundedRectangle(cornerRadius: 24).fill(.white)
                    tracePath(locations, center: center, radius: span * 0.32, progress: locations.count)
                        .stroke(.teal.opacity(0.15), style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    tracePath(locations, center: center, radius: span * 0.32, progress: visited)
                        .stroke(.teal, style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    if visited < locations.count && round < 3 {
                        Button { advance(expected: nextIndex) } label: {
                            Image(systemName: "hand.point.up.left.fill").font(.system(size: 27)).foregroundStyle(.white)
                                .frame(width: 68, height: 68).background(.teal, in: Circle())
                        }.buttonStyle(.plain).position(locations[visited])
                            .accessibilityLabel("Next point on the \(shape.name.lowercased()) trail")
                    }
                }.contentShape(Rectangle())
                    .highPriorityGesture(DragGesture(minimumDistance: 0).onChanged { value in
                        guard visited < locations.count else { return }
                        let point = locations[visited]
                        if hypot(value.location.x - point.x, value.location.y - point.y) < 39 { advance(expected: visited) }
                    })
            }.frame(height: 280)
            if visited == points.count && round < 3 {
                ToddlerActionButton(title: round == 2 ? "Finish our trails" : "Trace the next shape", systemImage: "arrow.right") {
                    guard round < 3, visited == points.count else { return }
                    round += 1
                    visited = round == 3 ? points.count : 0
                }
            }
            SCNote(text: "Say curved, straight, and corner as you explore. There is no need to stay exactly on the line.")
        }
    }
    private func tracePath(_ locations: [CGPoint], center: CGPoint, radius: CGFloat, progress: Int) -> Path {
        Path { path in
            guard let first = locations.first, progress > 1 else { return }
            path.move(to: first)
            if min(round, 2) == 0 {
                path.addArc(center: center, radius: radius, startAngle: .degrees(-90), endAngle: .degrees(-90 + Double(progress - 1) * 45), clockwise: false)
            } else {
                for point in locations.dropFirst().prefix(progress - 1) { path.addLine(to: point) }
            }
        }
    }
    private func advance(expected: Int) {
        guard expected == visited, visited < points.count, round < 3 else { return }
        visited += 1
        if visited == points.count { narrator.speak("You went all around the \(shape.name.lowercased())!") }
    }
}

struct MosaicGardenGame: View {
    let onReplay: () -> Void
    @State private var paint = SCPaint.red
    @State private var petals: [SCPaint?] = Array(repeating: nil, count: 6)
    @State private var finished = false
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Mosaic Garden", prompt: finished ? "Your colorful flower is ready to share!" : "Choose a paint, then tap the flower petals. Every garden can be different.", accent: .pink, completion: finished, onReplay: onReplay) {
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<6, id: \.self) { index in
                        let angle = Double(index) * .pi / 3 - .pi / 2
                        Button {
                            petals[index] = paint
                            narrator.speak("\(paint.name) petal.")
                        } label: {
                            Circle().fill(petals[index]?.color ?? .white)
                                .overlay(Circle().stroke(.pink.opacity(0.25), lineWidth: 3))
                                .overlay { if petals[index] == nil { Image(systemName: "paintbrush.pointed.fill").foregroundStyle(.pink.opacity(0.4)) } }
                                .frame(width: 74, height: 74)
                        }.buttonStyle(.plain)
                            .position(x: geometry.size.width / 2 + cos(angle) * 80, y: 132 + sin(angle) * 80)
                            .accessibilityLabel("Petal \(index + 1), \(petals[index]?.name ?? "unpainted")")
                    }
                    Image(systemName: "face.smiling.fill").font(.system(size: 63)).foregroundStyle(.yellow)
                        .position(x: geometry.size.width / 2, y: 132).accessibilityHidden(true)
                }
            }.frame(height: 260)
            SCPaintPicker(selection: $paint)
            if petals.allSatisfy({ $0 != nil }) && !finished {
                ToddlerActionButton(title: "My garden is ready", systemImage: "checkmark", color: .pink) { finished = true }
            }
            SCNote(text: "Describe a color your child chose. Invite them to tell you about their flower.")
        }
    }
}

struct MirrorWingsGame: View {
    let onReplay: () -> Void
    @State private var paint = SCPaint.blue
    @State private var spots: [SCPaint?] = Array(repeating: nil, count: 3)
    @State private var finished = false
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Mirror Wings", prompt: finished ? "Your butterfly has matching colors on both wings!" : "Paint a wing spot. Watch its matching spot appear on the other side!", accent: .purple, completion: finished, onReplay: onReplay) {
            GeometryReader { geometry in
                ZStack {
                    HStack(spacing: 5) {
                        Ellipse().fill(.purple.opacity(0.14))
                        Ellipse().fill(.purple.opacity(0.14))
                    }.padding(.horizontal, 12)
                    Capsule().fill(.indigo).frame(width: 20, height: 225)
                    ForEach(0..<3, id: \.self) { index in
                        ForEach(0..<2, id: \.self) { side in
                            Button {
                                spots[index] = paint
                                narrator.speak("\(paint.name) on both sides. They match!")
                            } label: {
                                Circle().fill(spots[index]?.color ?? .white)
                                    .overlay(Circle().stroke(.purple.opacity(0.3), lineWidth: 3))
                                    .overlay { if spots[index] == nil { Image(systemName: "plus").font(.title2).foregroundStyle(.purple) } }
                                    .frame(width: 66, height: 66)
                            }.buttonStyle(.plain)
                                .position(x: geometry.size.width * (side == 0 ? 0.27 : 0.73), y: CGFloat(index) * 77 + 48)
                                .accessibilityLabel("\(side == 0 ? "Left" : "Right") wing, spot \(index + 1), \(spots[index]?.name ?? "unpainted")")
                        }
                    }
                }
            }.frame(height: 260)
            SCPaintPicker(selection: $paint)
            if spots.allSatisfy({ $0 != nil }) && !finished {
                ToddlerActionButton(title: "Let my butterfly fly", systemImage: "butterfly.fill", color: .purple) { finished = true }
            }
            SCNote(text: "Point to the matching spots. Your child's hands also make a matching pair.")
        }
    }
}

private struct SCSafariObject: Identifiable {
    let id: Int
    let name: String
    let symbol: String
    let shape: SCShape
    let color: Color
}

struct ShapeSafariGame: View {
    let onReplay: () -> Void
    @State private var round = 0
    @State private var found: Set<Int> = []
    @State private var note = "Find another shape like this in the room."
    @StateObject private var narrator = GameNarrator()
    private let objects: [SCSafariObject] = [
        .init(id: 0, name: "Clock face", symbol: "clock.fill", shape: .circle, color: .blue),
        .init(id: 1, name: "Gift box", symbol: "gift.fill", shape: .square, color: .pink),
        .init(id: 2, name: "Mountain peak", symbol: "mountain.2.fill", shape: .triangle, color: .green),
        .init(id: 3, name: "Ball", symbol: "basketball.fill", shape: .circle, color: .orange),
        .init(id: 4, name: "Window", symbol: "square.split.2x2.fill", shape: .square, color: .cyan),
        .init(id: 5, name: "Tent", symbol: "tent.fill", shape: .triangle, color: .purple)
    ]
    private var target: SCShape { SCShape.allCases[min(round, 2)] }
    var body: some View {
        ToddlerGameScaffold(title: "Shape Safari", prompt: round == 3 ? "You found shapes in six everyday things!" : "Find two things with a \(target.name.lowercased()) shape.", accent: .green, completion: round == 3, onReplay: onReplay) {
            Image(systemName: target.outline).font(.system(size: 75)).foregroundStyle(target.color)
                .accessibilityLabel("Look for a \(target.name.lowercased())")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 118))], spacing: 12) {
                ForEach(objects) { object in
                    Button {
                        guard round < 3 else { return }
                        if object.shape == target { found.insert(object.id); note = "The \(object.name.lowercased()) has a \(target.name.lowercased()) shape." }
                        else { note = "Look at the \(object.name.lowercased()). We are looking for a \(target.name.lowercased()) shape." }
                        narrator.speak(note)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: object.symbol).font(.system(size: 46)).foregroundStyle(object.color)
                            Text(object.name).font(.system(.caption, design: .rounded, weight: .bold))
                            if found.contains(object.id) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                        }.foregroundStyle(.primary).frame(maxWidth: .infinity, minHeight: 125)
                            .background(.white, in: RoundedRectangle(cornerRadius: 20))
                    }.buttonStyle(.plain).disabled(found.contains(object.id))
                }
            }
            if found.count == 2 && round < 3 {
                ToddlerActionButton(title: round == 2 ? "Finish our safari" : "Find another shape", systemImage: "magnifyingglass", color: .green) {
                    guard round < 3, found.count == 2 else { return }
                    round += 1
                    if round < 3 { found = [] }
                }
            }
            SCNote(text: note)
        }
    }
}

struct RainbowWindowsGame: View {
    let onReplay: () -> Void
    @State private var opened: Set<SCPaint> = []
    @State private var note = "Choose a color to explore."
    @StateObject private var narrator = GameNarrator()
    private let objects = ["a red heart", "a yellow sun", "a blue raindrop", "an orange carrot", "a green leaf", "a purple moon"]
    var body: some View {
        ToddlerGameScaffold(title: "Rainbow Windows", prompt: opened.count == 6 ? "All six rainbow windows are open!" : "Tap a colored window. What is hiding behind it?", accent: .orange, completion: opened.count == 6, onReplay: onReplay) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 14) {
                ForEach(SCPaint.allCases) { paint in
                    Button {
                        opened.insert(paint)
                        note = "You found \(objects[paint.rawValue])!"
                        narrator.speak(note)
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: opened.contains(paint) ? paint.symbol : "door.left.hand.closed").font(.system(size: 50))
                            Text(paint.name).font(.system(.headline, design: .rounded))
                        }.foregroundStyle(paint == .yellow ? Color.black : .white)
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(paint.color.gradient, in: RoundedRectangle(cornerRadius: 26))
                    }.buttonStyle(.plain)
                        .accessibilityLabel(opened.contains(paint) ? objects[paint.rawValue] : "Open the \(paint.name.lowercased()) window")
                }
            }
            SCNote(text: note)
        }
    }
}

struct LittleRoadTripGame: View {
    let onReplay: () -> Void
    @State private var step = 0
    @State private var note = "Say across, up, and down as the car moves."
    @StateObject private var narrator = GameNarrator()
    private let route = [6, 7, 4, 1, 2, 5, 8]
    private var current: Int { route[step] }
    private var finished: Bool { step == route.count - 1 }
    private var direction: String {
        guard !finished else { return "home" }
        switch route[step + 1] - current {
        case -3: return "above"
        case 3: return "below"
        default: return "to the right of"
        }
    }
    var body: some View {
        ToddlerGameScaffold(title: "Little Road Trip", prompt: finished ? "You followed the winding road all the way home!" : "Follow the road. Tap the glowing square \(direction) the car.", accent: .blue, completion: finished, onReplay: onReplay) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(0..<9, id: \.self) { cell in
                    Button {
                        guard !finished else { return }
                        if cell == route[step + 1] {
                            let difference = cell - current
                            note = difference == -3 ? "Up the road!" : difference == 3 ? "Down the road!" : "Across the road!"
                            step += 1
                            if finished { note = "We followed the road all the way home." }
                        } else { note = "The next road square is glowing \(direction) the car." }
                        narrator.speak(note)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(!finished && cell == route[step + 1] ? Color.blue.opacity(0.16) : route.contains(cell) ? Color.white : Color.green.opacity(0.15))
                                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(!finished && cell == route[step + 1] ? Color.blue : .clear, lineWidth: 4))
                            if cell == current { Image(systemName: "car.fill").font(.system(size: 41)).foregroundStyle(.blue) }
                            else if cell == 8 { Image(systemName: "house.fill").font(.system(size: 42)).foregroundStyle(.orange) }
                            else if route.contains(cell) { Image(systemName: "circle.dashed").font(.system(size: 32)).foregroundStyle(.blue.opacity(0.35)) }
                            else { Image(systemName: "tree.fill").font(.system(size: 38)).foregroundStyle(.green) }
                        }.frame(minHeight: 96)
                    }.buttonStyle(.plain).disabled(!route.contains(cell))
                        .accessibilityLabel(cell == current ? "Car" : cell == 8 ? "Home, bottom right" : "Road row \(cell / 3 + 1), column \(cell % 3 + 1)")
                        .accessibilityHint(!finished && cell == route[step + 1] ? "Next road square, \(direction) the car" : "")
                }
            }
            SCNote(text: note)
        }
    }
}
