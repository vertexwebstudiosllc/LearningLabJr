//
//  LearningLabJrApp.swift
//  LearningLabJr
//
//  Created by Matthew Teitelman on 11/30/25.
//

import SwiftUI

@main
struct LearningLabJrApp: App {
    @UIApplicationDelegateAdaptor(AppOrientationDelegate.self) private var orientationDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

final class AppOrientationDelegate: NSObject, UIApplicationDelegate {
    static var supportedOrientations: UIInterfaceOrientationMask = .all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        Self.supportedOrientations
    }
}
