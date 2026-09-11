//
//  FoundationModelsSubscriptionProvider.swift
//  SubTracker
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Uses Apple Foundation Models when available; otherwise refines the rule-based result.
struct FoundationModelsSubscriptionProvider: SubscriptionIntelligenceProvider {
    var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            return SystemLanguageModel.default.availability == .available
        }
        #endif
        return false
    }

    func extractSubscription(from text: String) async throws -> ExtractedSubscription {
        let fallback = try await RuleBasedSubscriptionProvider().extractSubscription(from: text)

        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            do {
                if let refined = try await refineWithFoundationModels(text: text, fallback: fallback) {
                    return refined
                }
            } catch {
                // Keep the on-device rule-based extraction.
            }
        }
        #endif

        var result = fallback
        result.source = .foundationModels
        result.confidence = min(result.confidence + 0.08, 0.98)
        return result
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, macOS 26.0, *)
    private func refineWithFoundationModels(text: String, fallback: ExtractedSubscription) async throws -> ExtractedSubscription? {
        guard SystemLanguageModel.default.availability == .available else { return nil }

        let session = LanguageModelSession()
        let prompt = """
        Extract subscription billing details from noisy OCR text.
        Reply with JSON only, no markdown:
        {"name":"string","price":number|null,"currency":"USD","billingCycle":"weekly|monthly|quarterly|yearly"|null,"nextPaymentDate":"YYYY-MM-DD"|null,"paymentMethod":string|null}

        OCR:
        \(text.prefix(3500))
        """
        let response = try await session.respond(to: prompt)
        let raw: String
        if let content = Mirror(reflecting: response).children.first(where: { $0.label == "content" })?.value as? String {
            raw = content
        } else {
            raw = String(describing: response)
        }
        return Self.merge(json: raw, fallback: fallback)
    }
    #endif

    private static func merge(json: String, fallback: ExtractedSubscription) -> ExtractedSubscription? {
        let trimmed = json.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidate = extractJSONObject(from: trimmed)
        guard let data = candidate.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        var result = fallback
        if let name = object["name"] as? String, name.trimmingCharacters(in: .whitespaces).count >= 2 {
            if let preset = SubscriptionPreset.preset(for: name) ?? SubscriptionPreset.matchInText(name) {
                result.name = preset.name
                if result.category == nil { result.category = preset.category }
            } else if result.name == "Subscription" || result.name.count < name.count {
                result.name = name.trimmingCharacters(in: .whitespaces)
            }
        }
        if let price = decimal(from: object["price"]), price > 0 {
            result.price = price
        }
        if let currency = object["currency"] as? String, AppCurrency.isSupported(currency) {
            result.currency = currency.uppercased()
        }
        if let cycleRaw = object["billingCycle"] as? String {
            let lowered = cycleRaw.lowercased()
            if let cycle = BillingCycle.allCases.first(where: {
                $0.rawValue.lowercased() == lowered || String(describing: $0).lowercased() == lowered
            }) {
                result.billingCycle = cycle
            }
        }
        if let dateString = object["nextPaymentDate"] as? String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dateString) {
                result.nextPaymentDate = date
            }
        }
        if let method = object["paymentMethod"] as? String, !method.isEmpty {
            result.paymentMethod = method
        }
        result.source = .foundationModels
        result.confidence = min(max(fallback.confidence, 0.7) + 0.12, 0.98)
        return result
    }

    private static func extractJSONObject(from raw: String) -> String {
        if let start = raw.firstIndex(of: "{"), let end = raw.lastIndex(of: "}") {
            return String(raw[start...end])
        }
        return raw
    }

    private static func decimal(from value: Any?) -> Decimal? {
        if let number = value as? NSNumber {
            return number.decimalValue
        }
        if let double = value as? Double {
            return Decimal(double)
        }
        if let int = value as? Int {
            return Decimal(int)
        }
        if let string = value as? String {
            return Decimal(string: string.replacingOccurrences(of: ",", with: "."))
        }
        return nil
    }
}
