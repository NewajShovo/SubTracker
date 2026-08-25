//
//  FeatureManager.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class FeatureManager: ObservableObject {
    static let shared = FeatureManager()
    
    @Published var isPro: Bool = false
    
    // Free tier limits
    static let freeSubscriptionLimit = 5
    
    private init() {
        #if DEBUG
        // 🧪 DEBUG MODE: Toggle this to test Pro vs Free features
        // Set to true to test Pro features
        // Set to false to test free tier limits
        self.isPro = false
        print("🧪 DEBUG MODE: isPro = \(isPro)")
        #else
        // Production: Check real purchase status from StoreKit
        Task {
            let store = StoreManager()
            self.isPro = store.isPro
        }
        #endif
    }
    
    // MARK: - Debug Helper
    #if DEBUG
    /// Toggle Pro status for testing (DEBUG builds only)
    func toggleProForTesting() {
        isPro.toggle()
        print("🧪 DEBUG: Toggled Pro to \(isPro)")
    }
    #endif
    
    // MARK: - Feature Checks
    
    func canAddSubscription(currentCount: Int) -> Bool {
        if isPro {
            return true
        }
        return currentCount < Self.freeSubscriptionLimit
    }
    
    func hasAdvancedAnalytics() -> Bool {
        return isPro
    }
    
    func hasMultipleWidgets() -> Bool {
        return isPro
    }
    
    func hasExportFeature() -> Bool {
        return isPro
    }
    
    func hasICloudSync() -> Bool {
        return isPro
    }
    
    func hasMultipleCurrencies() -> Bool {
        return isPro
    }
    
    // MARK: - Upgrade Required Message
    
    func subscriptionLimitMessage(currentCount: Int) -> String {
        let remaining = max(0, Self.freeSubscriptionLimit - currentCount)
        if remaining == 0 {
            return "You've reached the free limit of \(Self.freeSubscriptionLimit) subscriptions. Upgrade to Pro for unlimited subscriptions."
        } else {
            return "\(remaining) of \(Self.freeSubscriptionLimit) subscriptions remaining in free plan"
        }
    }
}
