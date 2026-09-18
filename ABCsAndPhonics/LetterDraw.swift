import SwiftUI
import UIKit
import CoreText

enum LetterDrawAlphabet {
    static let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map(String.init)

    static func shuffled(startingAfter previousStart: String, lastShown: String = "") -> [String] {
        let first = letters.filter { $0 != previousStart && $0 != lastShown }.randomElement()!
        return [first] + letters.filter { $0 != first }.shuffled()
    }
}

/// Keeps the original glyph outlines and stroke guidance, with one roomy letter at a time.
struct LetterDraw: View {
    @StateObject private var play = LiteracyPlay(total: 26)
    @AppStorage("letterDraw.previousStartingLetter") private var previousStartingLetter = ""
    @AppStorage("letterDraw.lastShownLetter") private var lastShownLetter = ""
    @State private var letters: [String] = []
    @State private var canvasID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            if letters.indices.contains(play.round) {
                let letter = letters[play.round]
                LiteracyStage(title: "Letter Draw", prompt: "Draw over the big letter \(letter). Or draw it in the air with your grown-up.", play: play, onReplay: restart, progressLabel: "Letter", nextLabel: "Next letter") {
                    VStack(spacing: 18) {
                        LetterTraceView(letter: letter, isComplete: Binding(
                            get: { play.solved },
                            set: { done in if done { play.win("You explored the lines in \(letter)!") } }
                        ))
                        .id("\(play.round)-\(canvasID)")
                        .frame(height: 300)
                        .padding(20)
                        .background(Color(red: 0.15, green: 0.32, blue: 0.36), in: RoundedRectangle(cornerRadius: 26))
                        .accessibilityLabel("Drawing canvas for letter \(letter)")
                        .accessibilityIdentifier("letter-draw.canvas")
                        .accessibilityHint("Trace the large dotted letter with your finger, or use the air drawing button below.")
                        ToddlerActionButton(title: "Clear my drawing", systemImage: "arrow.counterclockwise", color: .orange) { canvasID = UUID() }
                        ToddlerActionButton(title: "We drew it in the air", systemImage: "hand.draw.fill", color: .orange) {
                            play.win("You made the letter \(letter) together!")
                        }
                    }
                }
            }
        }
        .onAppear(perform: restart)
        .onChange(of: play.round) { _, round in
            if letters.indices.contains(round) { lastShownLetter = letters[round] }
        }
    }

    private func restart() {
        letters = LetterDrawAlphabet.shuffled(startingAfter: previousStartingLetter, lastShown: lastShownLetter)
        previousStartingLetter = letters[0]
        lastShownLetter = letters[0]
        canvasID = UUID()
        play.replay()
    }
}

private struct LetterTraceView: View {
    let letter: String
    @Binding var isComplete: Bool

    @State private var strokes: [[CGPoint]] = []
    @State private var activeStroke: [CGPoint] = []

    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .local)
            let glyphCGPath = LetterPathProvider.cgPath(for: letter, in: rect)
            let glyphBounds = glyphCGPath.boundingBox
            let glyphPaths = LetterPathProvider.subpaths(for: letter, in: rect)
            let glyphShape = GlyphShape(path: Path(glyphCGPath))

            ZStack {
                // Dotted letter outline
                ForEach(glyphPaths.indices, id: \.self) { idx in
                    let isHoleHeavy = ["A", "B"].contains(letter.uppercased())
                    let width: CGFloat = isHoleHeavy ? 4 : 5
                    let dash: [CGFloat] = isHoleHeavy ? [4, 8] : [5, 9]

                    glyphPaths[idx]
                        .stroke(style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round, dash: dash))
                        .foregroundColor(isComplete ? Color.green.opacity(0.6) : Color.white.opacity(0.92))
                }

                // Arrows + dots to hint stroke order
                LetterPathProvider.arrows(for: letter, glyphBounds: glyphBounds)
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color(red: 0.05, green: 0.1, blue: 0.25))

                // User strokes (clipped to glyph for cleaner look)
                Group {
                    ForEach(strokes.indices, id: \.self) { idx in
                        Path { path in
                            guard let first = strokes[idx].first else { return }
                            path.move(to: first)
                            path.addLine(to: CGPoint(x: first.x + 0.1, y: first.y))
                            for p in strokes[idx].dropFirst() { path.addLine(to: p) }
                        }
                        .stroke(isComplete ? Color.green : Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                        .opacity(0.9)
                    }

                    Path { path in
                        guard let first = activeStroke.first else { return }
                        path.move(to: first)
                        path.addLine(to: CGPoint(x: first.x + 0.1, y: first.y))
                        for p in activeStroke.dropFirst() { path.addLine(to: p) }
                    }
                    .stroke(Color.blue.opacity(0.7), style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                }
                .clipShape(glyphShape)
            }
            .contentShape(Rectangle()) // A broad canvas accepts imprecise toddler starting points.
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !isComplete else { return }
                        let point = value.location
                        if activeStroke.last.map({ $0.distance(to: point) > 2 }) ?? true { activeStroke.append(point) }
                    }
                    .onEnded { _ in
                        guard !isComplete else { return }
                        if !activeStroke.isEmpty { strokes.append(activeStroke) }
                        activeStroke = []
                        evaluateCompletion(in: rect)
                    }
            )
        }
    }

    private func evaluateCompletion(in rect: CGRect) {
        let glyphPath = LetterPathProvider.cgPath(for: letter, in: rect)
        let samples = glyphPath.sampledPoints(step: 12)
        let allPoints = strokes.flatMap { $0 }
        guard !samples.isEmpty else { return }

        let tolerance: CGFloat = 28
        let hitCount = samples.filter { sample in
            allPoints.contains(where: { $0.distance(to: sample) < tolerance })
        }.count

        let coverage = CGFloat(hitCount) / CGFloat(samples.count)
        if coverage > 0.55 {
            isComplete = true
        }
    }
}

// MARK: - Letter Path Provider

private enum LetterPathProvider {
    static func path(for letter: String, in rect: CGRect) -> Path {
        Path(cgPath(for: letter, in: rect))
    }

    static func cgPath(for letter: String, in rect: CGRect) -> CGPath {
        let uppercase = letter.uppercased()
        let font = UIFont.systemFont(ofSize: 200, weight: .black)
        let ascent = CTFontGetAscent(font)
        let descent = CTFontGetDescent(font)
        let designHeight = ascent + descent
        let referenceWidth = referenceGlyphWidth(for: font)
        let chars: [UniChar] = Array(uppercase.utf16)
        let glyphs = chars.map { glyphForChar($0, font: font) }
        let cgPath = CGMutablePath()
        var xOffset: CGFloat = 0
        for glyph in glyphs {
            if let path = CTFontCreatePathForGlyph(font, glyph, nil) {
                let bounds = path.boundingBox
                let scale = min(rect.width / referenceWidth, rect.height / designHeight) * 0.88
                // Align to a common baseline using ascent/descent
                var t = CGAffineTransform.identity
                t = t.translatedBy(x: -bounds.minX, y: -bounds.minY)
                t = t.scaledBy(x: scale, y: -scale)
                t = t.translatedBy(
                    x: rect.midX - (bounds.width * scale) / 2 + xOffset,
                    y: rect.midY + ((ascent - descent) * scale) / 2
                )
                if let moved = path.copy(using: &t) {
                    cgPath.addPath(moved)
                    xOffset += bounds.width * scale * 1.1
                }
            }
        }
        // Vertically center the combined glyph path so every letter sits on the same line
        let bbox = cgPath.boundingBox
        let dy = rect.midY - bbox.midY
        if abs(dy) > 0.01 {
            var t = CGAffineTransform(translationX: 0, y: dy)
            if let shifted = cgPath.copy(using: &t) {
                return shifted
            }
        }
        return cgPath
    }

    private static func referenceGlyphWidth(for font: UIFont) -> CGFloat {
        let referenceLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let widths = referenceLetters.utf16.compactMap { char -> CGFloat? in
            let glyph = glyphForChar(char, font: font)
            guard let path = CTFontCreatePathForGlyph(font, glyph, nil) else { return nil }
            return path.boundingBox.width
        }

        return widths.max() ?? 200
    }

    static func arrows(for letter: String, glyphBounds: CGRect) -> Path {
        struct Segment {
            let start: CGPoint
            let end: CGPoint
            let c1: CGPoint?
            let c2: CGPoint?
            init(_ s: CGPoint, _ e: CGPoint, _ c1: CGPoint? = nil, _ c2: CGPoint? = nil) {
                self.start = s
                self.end = e
                self.c1 = c1
                self.c2 = c2
            }
        }
        let t = { (x: CGFloat, y: CGFloat) -> CGPoint in
            CGPoint(
                x: glyphBounds.minX + glyphBounds.width * x,
                y: glyphBounds.minY + glyphBounds.height * y
            )
        }

        // Stroke guides tuned for each letter, focusing on curved glyphs.
        let templates: [String: [Segment]] = [
            "A": [Segment(t(0.15, 0.95), t(0.5, 0.05)), Segment(t(0.85, 0.95), t(0.5, 0.05)), Segment(t(0.25, 0.6), t(0.75, 0.6))],
            "B": [
                Segment(t(0.25, 0.1), t(0.25, 0.9)),
                Segment(t(0.25, 0.1), t(0.7, 0.25)),
                Segment(t(0.7, 0.25), t(0.25, 0.45)),
                Segment(t(0.25, 0.55), t(0.7, 0.7)),
                Segment(t(0.7, 0.7), t(0.25, 0.9))
            ],
            "C": [
                Segment(t(0.85, 0.25), t(0.15, 0.5), t(0.7, 0.05), t(0.3, 0.05)),
                Segment(t(0.15, 0.5), t(0.85, 0.75), t(0.3, 0.95), t(0.7, 0.95))
            ],
            "D": [
                Segment(t(0.25, 0.1), t(0.25, 0.9)),
                Segment(t(0.25, 0.1), t(0.25, 0.9), t(0.9, 0.1), t(0.9, 0.9))
            ],
            "E": [Segment(t(0.2, 0.05), t(0.2, 0.95)), Segment(t(0.2, 0.05), t(0.75, 0.05)), Segment(t(0.2, 0.5), t(0.7, 0.5)), Segment(t(0.2, 0.95), t(0.75, 0.95))],
            "F": [Segment(t(0.2, 0.05), t(0.2, 0.95)), Segment(t(0.2, 0.05), t(0.75, 0.05)), Segment(t(0.2, 0.5), t(0.7, 0.5))],
            "G": [
                // Clockwise loop with opening on the right, similar to reference sheet
                Segment(t(0.8, 0.2), t(0.2, 0.5), t(0.9, 0.05), t(0.1, 0.15)),
                Segment(t(0.2, 0.5), t(0.8, 0.8), t(0.1, 0.85), t(0.9, 0.95)),
                Segment(t(0.55, 0.55), t(0.8, 0.55))
            ],
            "H": [Segment(t(0.2, 0.05), t(0.2, 0.95)), Segment(t(0.8, 0.05), t(0.8, 0.95)), Segment(t(0.2, 0.5), t(0.8, 0.5))],
            "I": [Segment(t(0.5, 0.05), t(0.5, 0.95))],
            "J": [
                Segment(t(0.75, 0.1), t(0.75, 0.75)),
                Segment(t(0.75, 0.75), t(0.35, 0.9), t(0.7, 0.95), t(0.5, 1.0))
            ],
            "K": [Segment(t(0.2, 0.05), t(0.2, 0.95)), Segment(t(0.2, 0.5), t(0.8, 0.15)), Segment(t(0.2, 0.5), t(0.8, 0.85))],
            "L": [Segment(t(0.2, 0.05), t(0.2, 0.95)), Segment(t(0.2, 0.95), t(0.75, 0.95))],
            "M": [Segment(t(0.15, 0.95), t(0.15, 0.05)), Segment(t(0.15, 0.05), t(0.5, 0.8)), Segment(t(0.5, 0.8), t(0.85, 0.05)), Segment(t(0.85, 0.05), t(0.85, 0.95))],
            "N": [Segment(t(0.2, 0.95), t(0.2, 0.05)), Segment(t(0.2, 0.05), t(0.8, 0.95)), Segment(t(0.8, 0.95), t(0.8, 0.05))],
            "O": [
                Segment(t(0.5, 0.1), t(0.9, 0.5), t(0.85, 0.1), t(0.95, 0.35)),
                Segment(t(0.9, 0.5), t(0.5, 0.9), t(0.95, 0.65), t(0.8, 0.95)),
                Segment(t(0.5, 0.9), t(0.1, 0.5), t(0.2, 0.95), t(0.05, 0.65)),
                Segment(t(0.1, 0.5), t(0.5, 0.1), t(0.05, 0.35), t(0.2, 0.1))
            ],
            "P": [
                Segment(t(0.25, 0.9), t(0.25, 0.1)),
                Segment(t(0.25, 0.1), t(0.8, 0.3), t(0.7, 0.05), t(0.9, 0.25)),
                Segment(t(0.8, 0.3), t(0.25, 0.5), t(0.9, 0.35), t(0.6, 0.55))
            ],
            "Q": [
                Segment(t(0.5, 0.1), t(0.9, 0.5), t(0.85, 0.1), t(0.95, 0.35)),
                Segment(t(0.9, 0.5), t(0.5, 0.9), t(0.95, 0.65), t(0.8, 0.95)),
                Segment(t(0.5, 0.9), t(0.1, 0.5), t(0.2, 0.95), t(0.05, 0.65)),
                Segment(t(0.1, 0.5), t(0.5, 0.1), t(0.05, 0.35), t(0.2, 0.1)),
                Segment(t(0.65, 0.7), t(0.9, 0.95))
            ],
            "R": [
                Segment(t(0.25, 0.9), t(0.25, 0.1)),
                Segment(t(0.25, 0.1), t(0.8, 0.35), t(0.75, 0.1), t(0.9, 0.25)),
                Segment(t(0.8, 0.35), t(0.25, 0.5), t(0.9, 0.4), t(0.65, 0.55)),
                Segment(t(0.25, 0.5), t(0.8, 0.9))
            ],
            "S": [
                Segment(t(0.8, 0.2), t(0.25, 0.35), t(0.65, 0.05), t(0.35, 0.05)),
                Segment(t(0.25, 0.35), t(0.75, 0.6), t(0.15, 0.55), t(0.85, 0.5)),
                Segment(t(0.75, 0.6), t(0.25, 0.8), t(0.85, 0.8), t(0.35, 0.95))
            ],
            "T": [Segment(t(0.1, 0.1), t(0.9, 0.1)), Segment(t(0.5, 0.1), t(0.5, 0.9))],
            "U": [
                Segment(t(0.25, 0.1), t(0.25, 0.7)),
                Segment(t(0.25, 0.7), t(0.75, 0.7), t(0.4, 0.95), t(0.6, 0.95)),
                Segment(t(0.75, 0.7), t(0.75, 0.1))
            ],
            "V": [Segment(t(0.1, 0.1), t(0.5, 0.9)), Segment(t(0.5, 0.9), t(0.9, 0.1))],
            "W": [Segment(t(0.1, 0.1), t(0.3, 0.9)), Segment(t(0.3, 0.9), t(0.5, 0.3)), Segment(t(0.5, 0.3), t(0.7, 0.9)), Segment(t(0.7, 0.9), t(0.9, 0.1))],
            "X": [Segment(t(0.2, 0.1), t(0.8, 0.9)), Segment(t(0.8, 0.1), t(0.2, 0.9))],
            "Y": [Segment(t(0.2, 0.1), t(0.5, 0.45)), Segment(t(0.8, 0.1), t(0.5, 0.45)), Segment(t(0.5, 0.45), t(0.5, 0.9))],
            "Z": [Segment(t(0.15, 0.1), t(0.85, 0.1)), Segment(t(0.85, 0.1), t(0.15, 0.9)), Segment(t(0.15, 0.9), t(0.85, 0.9))]
        ]

        let segments = templates[letter.uppercased()] ?? [Segment(t(0.2, 0.1), t(0.8, 0.9))]

        var path = Path()
        var isFirst = true
        for seg in segments {
            if let c1 = seg.c1, let c2 = seg.c2 {
                path.addCurvedArrow(from: seg.start, ctrl1: c1, ctrl2: c2, to: seg.end)
            } else {
                path.addArrow(from: seg.start, to: seg.end)
            }
            if isFirst {
                let dotRect = CGRect(x: seg.start.x - 4, y: seg.start.y - 4, width: 8, height: 8)
                path.addEllipse(in: dotRect)
                isFirst = false
            }
        }
        return path
    }

    static func subpaths(for letter: String, in rect: CGRect) -> [Path] {
        // Keep every contour, including both enclosed spaces in B.
        cgPath(for: letter, in: rect).extractSubpaths()
    }

    private static func glyphForChar(_ char: UniChar, font: UIFont) -> CGGlyph {
        var glyph = CGGlyph()
        CTFontGetGlyphsForCharacters(font, [char], &glyph, 1)
        return glyph
    }
}

// MARK: - Helpers

private struct GlyphShape: Shape {
    let path: Path
    func path(in rect: CGRect) -> Path { path }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}

private extension CGPath {
    func sampledPoints(step: CGFloat) -> [CGPoint] {
        guard step.isFinite, step > 0 else { return [] }
        var points: [CGPoint] = []
        var lastPoint: CGPoint = .zero
        var subpathStart: CGPoint = .zero

        func appendLine(to end: CGPoint) {
            let start = lastPoint
            let segments = max(1, Int(ceil(start.distance(to: end) / step)))
            for index in 1...segments {
                let fraction = CGFloat(index) / CGFloat(segments)
                points.append(CGPoint(
                    x: start.x + (end.x - start.x) * fraction,
                    y: start.y + (end.y - start.y) * fraction
                ))
            }
            lastPoint = end
        }

        self.forEach { element in
            switch element.type {
            case .moveToPoint:
                lastPoint = element.points[0]
                subpathStart = lastPoint
                points.append(lastPoint)
            case .addLineToPoint:
                appendLine(to: element.points[0])
            case .addQuadCurveToPoint, .addCurveToPoint:
                let controlCount = element.type == .addQuadCurveToPoint ? 1 : 2
                let end = element.points[controlCount]
                // Control-polygon length also samples curves whose endpoints coincide.
                var polygonLength: CGFloat = 0
                var previous = lastPoint
                for index in 0...controlCount {
                    let point = element.points[index]
                    polygonLength += previous.distance(to: point)
                    previous = point
                }
                let segments = max(1, Int(ceil(polygonLength / step)))
                for index in 1...segments {
                    points.append(self.evaluate(element: element, t: CGFloat(index) / CGFloat(segments), start: lastPoint))
                }
                lastPoint = end
            case .closeSubpath:
                // Close elements have zero points; reading element.points is invalid.
                appendLine(to: subpathStart)
            @unknown default:
                break
            }
        }
        return points
    }

    func extractSubpaths() -> [Path] {
        var paths: [CGMutablePath] = []
        var current: CGMutablePath?

        self.applyWithBlock { elementPtr in
            let element = elementPtr.pointee
            switch element.type {
            case .moveToPoint:
                if let cur = current {
                    paths.append(cur)
                }
                current = CGMutablePath()
                current?.move(to: element.points[0])
            case .addLineToPoint:
                current?.addLine(to: element.points[0])
            case .addQuadCurveToPoint:
                current?.addQuadCurve(to: element.points[1], control: element.points[0])
            case .addCurveToPoint:
                current?.addCurve(to: element.points[2], control1: element.points[0], control2: element.points[1])
            case .closeSubpath:
                current?.closeSubpath()
                if let cur = current {
                    paths.append(cur)
                    current = nil
                }
            @unknown default:
                break
            }
        }

        if let cur = current {
            paths.append(cur)
        }

        return paths.map { Path($0) }
    }

    var boundingRect: CGRect {
        self.boundingBox
    }

    var areaValue: CGFloat {
        boundingBox.width * boundingBox.height
    }

    private func evaluate(element: CGPathElement, t: CGFloat, start: CGPoint) -> CGPoint {
        switch element.type {
        case .addQuadCurveToPoint:
            let c = element.points[0]
            let end = element.points[1]
            let oneMinusT = 1 - t
            let x = oneMinusT * oneMinusT * start.x + 2 * oneMinusT * t * c.x + t * t * end.x
            let y = oneMinusT * oneMinusT * start.y + 2 * oneMinusT * t * c.y + t * t * end.y
            return CGPoint(x: x, y: y)
        case .addCurveToPoint:
            let c1 = element.points[0]
            let c2 = element.points[1]
            let end = element.points[2]
            let oneMinusT = 1 - t
            let x = pow(oneMinusT, 3) * start.x +
                3 * pow(oneMinusT, 2) * t * c1.x +
                3 * oneMinusT * t * t * c2.x +
                pow(t, 3) * end.x
            let y = pow(oneMinusT, 3) * start.y +
                3 * pow(oneMinusT, 2) * t * c1.y +
                3 * oneMinusT * t * t * c2.y +
                pow(t, 3) * end.y
            return CGPoint(x: x, y: y)
        default:
            return start
        }
    }

    func forEach(_ body: @escaping (CGPathElement) -> Void) {
        self.applyWithBlock { element in
            body(element.pointee)
        }
    }
}

private extension CGRect {
    var areaValue: CGFloat {
        width * height
    }
}

private extension Path {
    mutating func addArrow(from start: CGPoint, to end: CGPoint) {
        self.move(to: start)
        self.addLine(to: end)
        let angle = atan2(end.y - start.y, end.x - start.x)
        let arrowLength: CGFloat = 12
        let arrowAngle: CGFloat = .pi / 6
        let p1 = CGPoint(
            x: end.x - arrowLength * cos(angle - arrowAngle),
            y: end.y - arrowLength * sin(angle - arrowAngle)
        )
        let p2 = CGPoint(
            x: end.x - arrowLength * cos(angle + arrowAngle),
            y: end.y - arrowLength * sin(angle + arrowAngle)
        )
        self.move(to: end)
        self.addLine(to: p1)
        self.move(to: end)
        self.addLine(to: p2)
    }

    mutating func addCurvedArrow(from start: CGPoint, ctrl1: CGPoint, ctrl2: CGPoint, to end: CGPoint) {
        self.move(to: start)
        self.addCurve(to: end, control1: ctrl1, control2: ctrl2)

        // Tangent at end for arrow head
        let tangent = CGPoint(x: end.x - ctrl2.x, y: end.y - ctrl2.y)
        let angle = atan2(tangent.y, tangent.x)
        let arrowLength: CGFloat = 12
        let arrowAngle: CGFloat = .pi / 6
        let p1 = CGPoint(
            x: end.x - arrowLength * cos(angle - arrowAngle),
            y: end.y - arrowLength * sin(angle - arrowAngle)
        )
        let p2 = CGPoint(
            x: end.x - arrowLength * cos(angle + arrowAngle),
            y: end.y - arrowLength * sin(angle + arrowAngle)
        )
        self.move(to: end)
        self.addLine(to: p1)
        self.move(to: end)
        self.addLine(to: p2)
    }
}

#Preview {
    LetterDraw()
}
