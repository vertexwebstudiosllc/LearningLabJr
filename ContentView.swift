import SwiftUI
import UIKit
import Combine

struct ContentView: View {
    @AppStorage("parents.backgroundMusicEnabled") private var backgroundMusicEnabled = false
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var timer = SessionTimerManager.shared
    @StateObject private var orientation = AppOrientationController()

    var body: some View {
        ZStack {
            if !timer.isLocked {
                NavigationStack {
                    LearningLabHomeView()
                }
            }

            SessionTimerOverlay()
                .allowsHitTesting(timer.isLocked)
        }
        .environment(\.gameContentIsInverted, orientation.isFlipped)
        .rotationEffect(.degrees(orientation.isFlipped ? 180 : 0))
        .background(OrientationWindowReader(controller: orientation))
        .onAppear {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            orientation.update()
            BackgroundMusicManager.shared.setEnabled(backgroundMusicEnabled)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation.update()
        }
        .onChange(of: backgroundMusicEnabled) { _, isEnabled in
            BackgroundMusicManager.shared.setEnabled(isEnabled)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                timer.refresh()
                Task { await StoreManager.shared.updateCustomerProductStatus() }
            }
            updateAudio(active: phase == .active && !timer.isLocked)
        }
        .onChange(of: timer.isLocked) { _, locked in
            updateAudio(active: !locked && scenePhase == .active)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification)) { _ in
            if UIAccessibility.isVoiceOverRunning { GameNarrator.stopAll() }
        }
    }

    private func updateAudio(active: Bool) {
        BackgroundMusicManager.shared.setForeground(active)
        if !active {
            GameNarrator.stopAll()
            ItemSoundManager.shared.stop()
        }
    }
}

/// Face ID phones do not offer native upside-down interface rotation. Keep the
/// window in portrait and turn its content, retaining the same navigation tree.
@MainActor
final class AppOrientationController: ObservableObject {
    @Published private(set) var isFlipped = false
    weak var scene: UIWindowScene?

    func update() {
        let device = UIDevice.current.orientation
        guard device.isPortrait || device.isLandscape else { return }
        isFlipped = UIDevice.current.userInterfaceIdiom == .phone && device == .portraitUpsideDown
        AppOrientationDelegate.supportedOrientations = isFlipped ? .portrait : .all
        guard let scene else { return }
        scene.windows.first(where: \.isKeyWindow)?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        let mask: UIInterfaceOrientationMask
        switch device {
        case .portrait: mask = .portrait
        case .portraitUpsideDown: mask = isFlipped ? .portrait : .portraitUpsideDown
        case .landscapeLeft: mask = .landscapeRight
        case .landscapeRight: mask = .landscapeLeft
        default: return
        }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask))
    }
}

private struct OrientationWindowReader: UIViewRepresentable {
    let controller: AppOrientationController
    func makeUIView(context: Context) -> WindowView {
        let view = WindowView()
        view.controller = controller
        return view
    }
    func updateUIView(_ uiView: WindowView, context: Context) {}
    final class WindowView: UIView {
        weak var controller: AppOrientationController?
        override func didMoveToWindow() {
            super.didMoveToWindow()
            controller?.scene = window?.windowScene
            Task { @MainActor [weak controller] in controller?.update() }
        }
    }
}

#Preview {
    ContentView()
}
