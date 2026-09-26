import SwiftUI

/// Identical geometry for the stamp and its matching hole, independent of symbol fonts.
struct PostShapeSilhouette: Shape {
    let kind: PostShape
    func path(in bounds: CGRect) -> Path {
        let side = min(bounds.width, bounds.height)
        let rect = CGRect(x: bounds.midX - side / 2, y: bounds.midY - side / 2, width: side, height: side)
        switch kind {
        case .circle: return Path(ellipseIn: rect)
        case .oval: return Path(ellipseIn: rect.insetBy(dx: 0, dy: side * 0.19))
        case .square: return Path(rect)
        case .rectangle: return Path(rect.insetBy(dx: 0, dy: side * 0.19))
        case .heart:
            return Path { p in
                func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: rect.minX + x * side, y: rect.minY + y * side) }
                p.move(to: point(0.5, 0.95))
                p.addCurve(to: point(0.06, 0.3), control1: point(0.4, 0.8), control2: point(-0.05, 0.55))
                p.addCurve(to: point(0.5, 0.2), control1: point(0.1, 0.02), control2: point(0.4, 0.02))
                p.addCurve(to: point(0.94, 0.3), control1: point(0.6, 0.02), control2: point(0.9, 0.02))
                p.addCurve(to: point(0.5, 0.95), control1: point(1.05, 0.55), control2: point(0.6, 0.8))
                p.closeSubpath()
            }
        default:
            let count: Int = switch kind { case .triangle: 3; case .diamond: 4; case .pentagon: 5; case .hexagon: 6; default: 10 }
            return Path { p in
                for i in 0..<count {
                    let angle = Double(i) * 2 * .pi / Double(count) - .pi / 2
                    let radius = side * (kind == .star && i % 2 == 1 ? 0.23 : 0.5)
                    let point = CGPoint(x: rect.midX + cos(angle) * radius, y: rect.midY + sin(angle) * radius)
                    if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
                }
                p.closeSubpath()
            }
        }
    }
}
