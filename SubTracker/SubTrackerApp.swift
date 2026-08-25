//
//  SubTrackerApp.swift
//  SubTracker
//

import SwiftData
import SwiftUI

@main
struct SubTrackerApp: App {
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var featureGate: FeatureGate
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    let sharedModelContainer: ModelContainer

    init() {
        let store = StoreManager.shared
        _featureGate = StateObject(wrappedValue: FeatureGate(storeManager: store))

        do {
            sharedModelContainer = try SyncManager.makeContainer(enableCloud: SyncManager.isEnabled)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
            }
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(storeManager)
        .environmentObject(featureGate)
    }
}
