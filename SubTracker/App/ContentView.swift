//
//  ContentView.swift
//  SubTracker
//

import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }

            AllSubscriptionsView()
                .tabItem { Label("Subscriptions", systemImage: "rectangle.stack.fill") }

            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.bar.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
        .environmentObject(StoreManager.shared)
        .environmentObject(FeatureGate(storeManager: StoreManager.shared))
}
