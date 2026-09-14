//
//  RootFlowView.swift
//  SubTracker
//

import SwiftUI

/// Launch router: onboarding → post-onboarding paywall → main app.
struct RootFlowView: View {
    @EnvironmentObject private var storeManager: StoreManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasCompletedLaunchPaywall") private var hasCompletedLaunchPaywall = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(onComplete: completeOnboarding)
            } else if shouldShowLaunchPaywall {
                PaywallView(mode: .postOnboarding, onFinished: completeLaunchPaywall)
            } else {
                ContentView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: launchPhase)
        .onAppear(perform: migrateExistingUsers)
    }

    private var shouldShowLaunchPaywall: Bool {
        !storeManager.isPro && !hasCompletedLaunchPaywall
    }

    private var launchPhase: String {
        if !hasCompletedOnboarding { return "onboarding" }
        if shouldShowLaunchPaywall { return "paywall" }
        return "main"
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    private func completeLaunchPaywall() {
        hasCompletedLaunchPaywall = true
    }

    /// Users who already finished onboarding before this flow existed should not
    /// be forced through the launch paywall on the next update.
    private func migrateExistingUsers() {
        let defaults = UserDefaults.standard
        let migrationKey = "didMigrateLaunchPaywallFlag"
        guard defaults.object(forKey: migrationKey) == nil else { return }

        if defaults.bool(forKey: "hasCompletedOnboarding") {
            hasCompletedLaunchPaywall = true
        }
        defaults.set(true, forKey: migrationKey)
    }
}
