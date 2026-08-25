//
//  SubTrackerApp.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import SwiftUI
import SwiftData

@main
struct SubTrackerApp: App {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var isWelcomeComplete = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Subscription.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // Check if user has seen welcome screen
        _isWelcomeComplete = State(initialValue: UserDefaults.standard.bool(forKey: "hasSeenWelcome"))
    }

    var body: some Scene {
        WindowGroup {
            if isWelcomeComplete {
                ContentView()
                    .modelContainer(sharedModelContainer)
            } else {
                WelcomeView(isWelcomeComplete: $isWelcomeComplete)
            }
        }
    }
}
