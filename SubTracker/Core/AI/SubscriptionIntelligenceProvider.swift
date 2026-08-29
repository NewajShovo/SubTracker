//
//  SubscriptionIntelligenceProvider.swift
//  SubTracker
//

import Foundation

protocol SubscriptionIntelligenceProvider: Sendable {
    func extractSubscription(from text: String) async throws -> ExtractedSubscription
}

struct SubscriptionIntelligenceService {
    private let ruleBased = RuleBasedSubscriptionProvider()
    private let foundationModels = FoundationModelsSubscriptionProvider()

    func extract(from text: String) async throws -> ExtractedSubscription {
        let ruleResult = try await ruleBased.extractSubscription(from: text)

        if ruleResult.confidence >= 0.75, ruleResult.isValid {
            return ruleResult
        }

        if foundationModels.isAvailable {
            do {
                let fmResult = try await foundationModels.extractSubscription(from: text)
                if fmResult.confidence >= ruleResult.confidence {
                    return fmResult
                }
            } catch {
                // Fall through to rule-based result
            }
        }

        if ruleResult.confidence >= 0.4 {
            return ruleResult
        }

        throw IntelligenceError.lowConfidence
    }
}

enum IntelligenceError: LocalizedError {
    case ocrFailed
    case lowConfidence
    case unavailable

    var errorDescription: String? {
        switch self {
        case .ocrFailed:
            return "Couldn't read the screenshot. Try a clearer image."
        case .lowConfidence:
            return "We couldn't automatically identify the subscription. You can enter it manually."
        case .unavailable:
            return "Automatic extraction isn't available on this device."
        }
    }
}
