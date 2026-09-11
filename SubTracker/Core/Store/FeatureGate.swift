//
//  FeatureGate.swift
//  SubTracker
//

import Combine
import Foundation

/// Single feature-gating layer driven by StoreManager entitlement state.
@MainActor
final class FeatureGate: ObservableObject {
    static let freeSubscriptionLimit = 5

    @Published private(set) var isPro: Bool = false

    #if DEBUG
    @Published var debugProOverride: Bool?
    #endif

    private let storeManager: StoreManager
    private var cancellable: AnyCancellable?

    init(storeManager: StoreManager) {
        self.storeManager = storeManager
        syncFromStore()
        cancellable = storeManager.objectWillChange.sink { [weak self] _ in
            self?.syncFromStore()
        }
    }

    var effectiveIsPro: Bool {
        #if DEBUG
        if let debugProOverride { return debugProOverride }
        #endif
        return isPro
    }

    func canAddSubscription(totalCount: Int) -> Bool {
        effectiveIsPro || totalCount < Self.freeSubscriptionLimit
    }

    func hasAdvancedAnalytics() -> Bool { effectiveIsPro }
    func hasScanSubscription() -> Bool { effectiveIsPro }
    func hasSmartInsights() -> Bool { effectiveIsPro }
    func hasExportFeature() -> Bool { effectiveIsPro }
    func hasICloudSync() -> Bool { effectiveIsPro }
    func hasMultipleCurrencies() -> Bool { effectiveIsPro }
    func hasWidgets() -> Bool { effectiveIsPro }
    func hasTrialAlerts() -> Bool { effectiveIsPro }

    func subscriptionLimitMessage(currentCount: Int) -> String {
        let remaining = max(0, Self.freeSubscriptionLimit - currentCount)
        if remaining == 0 {
            return "You've reached the free limit of \(Self.freeSubscriptionLimit) subscriptions. Upgrade to Pro for unlimited tracking and AI scanning."
        }
        return "\(remaining) of \(Self.freeSubscriptionLimit) subscriptions remaining on the free plan"
    }

    #if DEBUG
    func toggleProForTesting() {
        debugProOverride = !(debugProOverride ?? isPro)
        objectWillChange.send()
    }
    #endif

    private func syncFromStore() {
        isPro = storeManager.isPro
    }
}
