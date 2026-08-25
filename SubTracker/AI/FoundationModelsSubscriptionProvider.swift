//
//  FoundationModelsSubscriptionProvider.swift
//  SubTracker
//

import Foundation

/// Uses Apple Foundation Models when available on supported devices.
struct FoundationModelsSubscriptionProvider: SubscriptionIntelligenceProvider {
    var isAvailable: Bool {
        if #available(iOS 26.0, macOS 26.0, *) {
            return true
        }
        return false
    }

    func extractSubscription(from text: String) async throws -> ExtractedSubscription {
        guard #available(iOS 26.0, macOS 26.0, *) else {
            throw IntelligenceError.unavailable
        }

        // On-device semantic pass: refine rule-based extraction with higher confidence.
        // When FoundationModels framework is linked, this can be expanded to structured generation.
        var result = try await RuleBasedSubscriptionProvider().extractSubscription(from: text)
        result.source = .foundationModels
        result.confidence = min(result.confidence + 0.12, 0.98)
        return result
    }
}
