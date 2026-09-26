import SwiftUI

/// A toolbox silhouette that inherits the menu's accent and does not require a system glyph.
struct SolutionToolboxIcon: View {
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            ZStack {
                RoundedRectangle(cornerRadius: w * 0.06).stroke(lineWidth: w * 0.075)
                    .frame(width: w * 0.35, height: h * 0.22).position(x: w * 0.5, y: h * 0.22)
                RoundedRectangle(cornerRadius: w * 0.1).frame(width: w * 0.94, height: h * 0.63)
                    .position(x: w * 0.5, y: h * 0.62)
                Rectangle().fill(.white.opacity(0.8)).frame(width: w * 0.94, height: h * 0.035)
                    .position(x: w * 0.5, y: h * 0.52)
                ForEach([0.3, 0.7], id: \.self) { x in
                    RoundedRectangle(cornerRadius: w * 0.02).fill(.white).frame(width: w * 0.09, height: h * 0.18)
                        .position(x: w * x, y: h * 0.53)
                }
            }
        }.accessibilityHidden(true)
    }
}
