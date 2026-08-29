//
//  ContentView.swift
//  SubTracker
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query private var allSubscriptions: [Subscription]
    @State private var selectedTab = 0
    @State private var deepLinkSubscriptionID: UUID?

    private var deepLinkSubscription: Subscription? {
        guard let deepLinkSubscriptionID else { return nil }
        return allSubscriptions.first { $0.id == deepLinkSubscriptionID }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
                .tag(0)

            AllSubscriptionsView()
                .tabItem { Label("Subscriptions", systemImage: "rectangle.stack.fill") }
                .tag(1)

            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.bar.fill") }
                .tag(2)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(3)
        }
        .onOpenURL { handleDeepLink($0) }
        .sheet(isPresented: Binding(
            get: { deepLinkSubscription != nil },
            set: { if !$0 { deepLinkSubscriptionID = nil } }
        )) {
            if let subscription = deepLinkSubscription {
                NavigationStack {
                    SubscriptionDetailView(subscription: subscription)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { deepLinkSubscriptionID = nil }
                            }
                        }
                }
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard let destination = WidgetDeepLink.destination(from: url) else { return }
        switch destination {
        case .dashboard:
            selectedTab = 0
        case .subscriptions:
            selectedTab = 1
        case .subscription(let id):
            selectedTab = 1
            deepLinkSubscriptionID = id
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
        .environmentObject(StoreManager.shared)
        .environmentObject(FeatureGate(storeManager: StoreManager.shared))
}
