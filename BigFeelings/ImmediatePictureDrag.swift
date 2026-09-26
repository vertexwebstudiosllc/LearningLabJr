import SwiftUI

/// Captures a picture immediately, before the surrounding scroll view can pan.
struct ImmediatePictureDrag: ViewModifier {
    @Binding var dragging: Bool
    let target: CGRect
    let tap: () -> Void
    let drop: () -> Void
    @GestureState private var offset = CGSize.zero
    @GestureState private var active = false

    func body(content: Content) -> some View {
        content.offset(offset).zIndex(active ? 10 : 0)
            .highPriorityGesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($active) { _, value, _ in value = true }
                .updating($offset) { value, offset, _ in offset = value.translation }
                .onEnded { value in
                    if hypot(value.translation.width, value.translation.height) < 8 { tap() }
                    else if !target.isEmpty && target.insetBy(dx: -22, dy: -22).contains(value.location) { drop() }
                })
            .onChange(of: active) { _, value in dragging = value }
            .onDisappear { dragging = false }
    }
}
