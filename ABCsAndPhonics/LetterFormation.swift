import SwiftUI

struct LetterTraceStroke {
    let hint: String
    let points: [CGPoint]
    func fitted(in size: CGSize) -> [CGPoint] {
        let scale = min(size.width, size.height)
        return points.map { CGPoint(x: (size.width - scale) / 2 + $0.x * scale, y: (size.height - scale) / 2 + $0.y * scale) }
    }
    static func path(_ points: [CGPoint]) -> Path {
        Path { p in guard let first = points.first else { return }; p.move(to: first); for point in points.dropFirst() { p.addLine(to: point) } }
    }
    static func distance(_ point: CGPoint, to a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = b.x-a.x, dy = b.y-a.y
        let t = max(0, min(1, ((point.x-a.x)*dx + (point.y-a.y)*dy) / max(0.0001, dx*dx+dy*dy)))
        return hypot(point.x-a.x-t*dx, point.y-a.y-t*dy)
    }
    func covered(by drawing: [CGPoint], in size: CGSize) -> Bool {
        guard drawing.count > 1 else { return false }
        let target = fitted(in: size)
        let tolerance = min(size.width, size.height) * 0.075
        let covered = target.filter { point in zip(drawing, drawing.dropFirst()).contains { Self.distance(point, to: $0.0, $0.1) <= tolerance } }.count
        let drawnLength = zip(drawing, drawing.dropFirst()).reduce(CGFloat.zero) { $0 + hypot($1.1.x-$1.0.x, $1.1.y-$1.0.y) }
        let targetLength = zip(target, target.dropFirst()).reduce(CGFloat.zero) { $0 + hypot($1.1.x-$1.0.x, $1.1.y-$1.0.y) }
        return Double(covered) / Double(target.count) >= 0.78 && drawnLength >= targetLength * 0.55
    }
}

enum LetterFormation {
    private static func L(_ x: CGFloat, _ y: CGFloat, _ u: CGFloat, _ v: CGFloat) -> [CGPoint] {
        (0...24).map { i in let t = CGFloat(i)/24; return CGPoint(x: x+(u-x)*t, y: y+(v-y)*t) }
    }
    private static func C(_ x: CGFloat, _ y: CGFloat, _ a: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat, _ u: CGFloat, _ v: CGFloat) -> [CGPoint] {
        (0...36).map { i in
            let t = CGFloat(i)/36, s = 1-t
            return CGPoint(x: s*s*s*x+3*s*s*t*a+3*s*t*t*c+t*t*t*u, y: s*s*s*y+3*s*s*t*b+3*s*t*t*d+t*t*t*v)
        }
    }
    static let strokes: [String: [LetterTraceStroke]] = [
        "A": [.init(hint: "Start at the top. Slide down left.", points: L(0.5,0.1,0.15,0.9)), .init(hint: "Start at the top. Slide down right.", points: L(0.5,0.1,0.85,0.9)), .init(hint: "Go across the middle.", points: L(0.31,0.54,0.69,0.54))],
        "B": [.init(hint: "Start at the top. Pull down.", points: L(0.25,0.1,0.25,0.9)), .init(hint: "Start at the top. Curve around to the middle.", points: C(0.25,0.1,0.91,0.1,0.91,0.5,0.25,0.5)), .init(hint: "Start at the middle. Curve around to the bottom.", points: C(0.25,0.5,0.96,0.5,0.96,0.9,0.25,0.9))],
        "C": [.init(hint: "Start near the top right. Curve left, down, and around.", points: C(0.82,0.23,0.48,-0.03,0.16,0.1,0.16,0.5)+C(0.16,0.5,0.16,0.9,0.48,1.03,0.82,0.77))],
        "D": [.init(hint: "Start at the top. Pull down.", points: L(0.23,0.1,0.23,0.9)), .init(hint: "Start at the top. Curve around to the bottom.", points: C(0.23,0.1,1.0,0.1,1.0,0.9,0.23,0.9))],
        "E": [.init(hint: "Start at the top. Pull down.", points: L(0.23,0.1,0.23,0.9)), .init(hint: "Go across the top.", points: L(0.23,0.1,0.8,0.1)), .init(hint: "Go across the middle.", points: L(0.23,0.5,0.7,0.5)), .init(hint: "Go across the bottom.", points: L(0.23,0.9,0.8,0.9))],
        "F": [.init(hint: "Start at the top. Pull down.", points: L(0.23,0.1,0.23,0.9)), .init(hint: "Go across the top.", points: L(0.23,0.1,0.8,0.1)), .init(hint: "Go across the middle.", points: L(0.23,0.5,0.7,0.5))],
        "G": [.init(hint: "Start near the top right. Curve left, down, and around.", points: C(0.82,0.23,0.48,-0.03,0.16,0.1,0.16,0.5)+C(0.16,0.5,0.16,0.94,0.84,1.04,0.84,0.57)), .init(hint: "Go left across the short middle line.", points: L(0.84,0.57,0.55,0.57))],
        "H": [.init(hint: "Pull down on the left.", points: L(0.2,0.1,0.2,0.9)), .init(hint: "Pull down on the right.", points: L(0.8,0.1,0.8,0.9)), .init(hint: "Join the lines across the middle.", points: L(0.2,0.5,0.8,0.5))],
        "I": [.init(hint: "Pull down through the middle.", points: L(0.5,0.1,0.5,0.9)), .init(hint: "Go across the top.", points: L(0.23,0.1,0.77,0.1)), .init(hint: "Go across the bottom.", points: L(0.23,0.9,0.77,0.9))],
        "J": [.init(hint: "Start at the top right. Pull down and curl left.", points: L(0.75,0.1,0.75,0.68)+C(0.75,0.68,0.75,0.99,0.22,0.99,0.22,0.72)), .init(hint: "Go across the top.", points: L(0.3,0.1,0.85,0.1))],
        "K": [.init(hint: "Start at the top. Pull down.", points: L(0.23,0.1,0.23,0.9)), .init(hint: "Slide from the top right to the middle.", points: L(0.8,0.1,0.23,0.5)), .init(hint: "Slide from the middle to the bottom right.", points: L(0.23,0.5,0.8,0.9))],
        "L": [.init(hint: "Start at the top. Pull down.", points: L(0.23,0.1,0.23,0.9)), .init(hint: "Go across the bottom.", points: L(0.23,0.9,0.8,0.9))],
        "M": [.init(hint: "Pull down on the left.", points: L(0.15,0.1,0.15,0.9)), .init(hint: "From the top left, slide down to the middle.", points: L(0.15,0.1,0.5,0.6)), .init(hint: "Slide up to the top right.", points: L(0.5,0.6,0.85,0.1)), .init(hint: "Pull down on the right.", points: L(0.85,0.1,0.85,0.9))],
        "N": [.init(hint: "Pull down on the left.", points: L(0.2,0.1,0.2,0.9)), .init(hint: "From the top left, slide down right.", points: L(0.2,0.1,0.8,0.9)), .init(hint: "Pull down on the right.", points: L(0.8,0.1,0.8,0.9))],
        "O": [.init(hint: "Start at the top. Curve left, down, and all the way around.", points: C(0.5,0.1,0.03,0.1,0.03,0.9,0.5,0.9)+C(0.5,0.9,0.97,0.9,0.97,0.1,0.5,0.1))],
        "P": [.init(hint: "Start at the top. Pull down.", points: L(0.23,0.1,0.23,0.9)), .init(hint: "From the top, curve around to the middle.", points: C(0.23,0.1,0.97,0.1,0.97,0.52,0.23,0.52))],
        "Q": [.init(hint: "Start at the top. Curve left, down, and all the way around.", points: C(0.5,0.1,0.03,0.1,0.03,0.87,0.5,0.87)+C(0.5,0.87,0.97,0.87,0.97,0.1,0.5,0.1)), .init(hint: "Add a short tail going down right.", points: L(0.59,0.7,0.87,0.94))],
        "R": [.init(hint: "Start at the top. Pull down.", points: L(0.23,0.1,0.23,0.9)), .init(hint: "From the top, curve around to the middle.", points: C(0.23,0.1,0.97,0.1,0.97,0.5,0.23,0.5)), .init(hint: "From the middle, slide down right.", points: L(0.23,0.5,0.82,0.9))],
        "S": [.init(hint: "Start at the top right. Curve left, then right, then left.", points: C(0.81,0.21,0.18,-0.16,0.02,0.48,0.49,0.5)+C(0.49,0.5,0.99,0.52,0.82,1.17,0.18,0.79))],
        "T": [.init(hint: "Go across the top.", points: L(0.13,0.1,0.87,0.1)), .init(hint: "From the top middle, pull down.", points: L(0.5,0.1,0.5,0.9))],
        "U": [.init(hint: "Pull down, curve around the bottom, and go up.", points: L(0.2,0.1,0.2,0.62)+C(0.2,0.62,0.2,1.0,0.8,1.0,0.8,0.62)+L(0.8,0.62,0.8,0.1))],
        "V": [.init(hint: "Slide down to the bottom middle.", points: L(0.13,0.1,0.5,0.9)), .init(hint: "Slide up to the top right.", points: L(0.5,0.9,0.87,0.1))],
        "W": [.init(hint: "Slide down to the first point.", points: L(0.1,0.1,0.28,0.9)), .init(hint: "Slide up to the middle.", points: L(0.28,0.9,0.5,0.32)), .init(hint: "Slide down to the next point.", points: L(0.5,0.32,0.72,0.9)), .init(hint: "Slide up to the top right.", points: L(0.72,0.9,0.9,0.1))],
        "X": [.init(hint: "Slide from top left to bottom right.", points: L(0.2,0.1,0.8,0.9)), .init(hint: "Slide from top right to bottom left.", points: L(0.8,0.1,0.2,0.9))],
        "Y": [.init(hint: "Slide from top left to the middle.", points: L(0.18,0.1,0.5,0.5)), .init(hint: "Slide from top right to the middle.", points: L(0.82,0.1,0.5,0.5)), .init(hint: "Pull down from the middle.", points: L(0.5,0.5,0.5,0.9))],
        "Z": [.init(hint: "Go across the top.", points: L(0.18,0.1,0.82,0.1)), .init(hint: "Slide down to the bottom left.", points: L(0.82,0.1,0.18,0.9)), .init(hint: "Go across the bottom.", points: L(0.18,0.9,0.82,0.9))]
    ]
}
