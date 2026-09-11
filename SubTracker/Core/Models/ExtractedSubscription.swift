//
//  ExtractedSubscription.swift
//  SubTracker
//

import Foundation

enum ExtractionSource: String, Codable, Sendable {
    case ruleBased
    case foundationModels
    case manual
}

struct ExtractedSubscription: Sendable {
    var name: String
    var price: Decimal?
    var currency: String
    var billingCycle: BillingCycle?
    var nextPaymentDate: Date?
    var category: Category?
    var paymentMethod: String?
    var confidence: Double
    var source: ExtractionSource
    var rawText: String

    var isValid: Bool {
        guard let price, price > 0 else { return false }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard AppCurrency.isSupported(currency) else { return false }
        if let nextPaymentDate, nextPaymentDate < Calendar.current.date(byAdding: .year, value: -1, to: Date())! {
            return false
        }
        return true
    }

    func applyingPresetIfNeeded() -> ExtractedSubscription {
        var copy = self
        if let preset = SubscriptionPreset.preset(for: name) {
            if copy.category == nil { copy.category = preset.category }
            copy.name = preset.name
        }
        return copy
    }

    func toSubscription() -> Subscription? {
        guard isValid, let price, let billingCycle else { return nil }
        let preset = SubscriptionPreset.preset(for: name)
        return Subscription(
            name: name,
            category: category ?? preset?.category ?? .other,
            price: price,
            currency: currency,
            billingCycle: billingCycle,
            nextPaymentDate: nextPaymentDate ?? Date(),
            paymentMethod: paymentMethod ?? "",
            iconName: preset?.iconName ?? "dollarsign.circle.fill",
            color: preset?.color ?? Category.other.defaultColor,
            source: .scan
        )
    }
}

enum ExtractedSubscriptionValidator {
    static func validate(_ extracted: ExtractedSubscription) -> ExtractedSubscription? {
        var result = extracted.applyingPresetIfNeeded()
        guard result.isValid else { return nil }
        if result.billingCycle == nil { result.billingCycle = .monthly }
        if result.nextPaymentDate == nil {
            result.nextPaymentDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        }
        return result
    }
}
