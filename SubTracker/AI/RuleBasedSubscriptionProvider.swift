//
//  RuleBasedSubscriptionProvider.swift
//  SubTracker
//

import Foundation

struct RuleBasedSubscriptionProvider: SubscriptionIntelligenceProvider {
    func extractSubscription(from text: String) async throws -> ExtractedSubscription {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = normalized.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        let priceInfo = extractPrice(from: normalized)
        let date = extractDate(from: normalized)
        let billingCycle = extractBillingCycle(from: normalized)
        let name = extractName(from: lines, priceInfo: priceInfo)
        let category = SubscriptionPreset.preset(for: name)?.category
        let currency = priceInfo?.currency ?? "USD"

        var confidence = 0.3
        if priceInfo != nil { confidence += 0.25 }
        if date != nil { confidence += 0.2 }
        if billingCycle != nil { confidence += 0.15 }
        if SubscriptionPreset.preset(for: name) != nil { confidence += 0.15 }
        if !name.isEmpty && name.count > 2 { confidence += 0.1 }

        return ExtractedSubscription(
            name: name.isEmpty ? "Subscription" : name,
            price: priceInfo?.amount,
            currency: currency,
            billingCycle: billingCycle,
            nextPaymentDate: date,
            category: category,
            paymentMethod: extractPaymentMethod(from: normalized),
            confidence: min(confidence, 0.95),
            source: .ruleBased,
            rawText: normalized
        )
    }

    private struct PriceInfo {
        let amount: Decimal
        let currency: String
    }

    private func extractPrice(from text: String) -> PriceInfo? {
        let patterns: [(String, String)] = [
            (#"\$\s*(\d+(?:[.,]\d{1,2})?)"#, "USD"),
            (#"USD\s*(\d+(?:[.,]\d{1,2})?)"#, "USD"),
            (#"€\s*(\d+(?:[.,]\d{1,2})?)"#, "EUR"),
            (#"EUR\s*(\d+(?:[.,]\d{1,2})?)"#, "EUR"),
            (#"£\s*(\d+(?:[.,]\d{1,2})?)"#, "GBP"),
            (#"GBP\s*(\d+(?:[.,]\d{1,2})?)"#, "GBP"),
            (#"(\d+(?:[.,]\d{1,2})?)\s*(?:USD|usd)"#, "USD"),
            (#"(\d+(?:[.,]\d{1,2})?)\s*(?:BDT|Tk|৳)"#, "BDT"),
            (#"(\d+(?:[.,]\d{1,2})?)\s*(?:INR|₹)"#, "INR"),
        ]

        for (pattern, currency) in patterns {
            if let match = text.range(of: pattern, options: .regularExpression) {
                let matched = String(text[match])
                let digits = matched.replacingOccurrences(of: "[^0-9.,]", with: "", options: .regularExpression)
                    .replacingOccurrences(of: ",", with: ".")
                if let decimal = Decimal(string: digits), decimal > 0 {
                    return PriceInfo(amount: decimal, currency: currency)
                }
            }
        }
        return nil
    }

    private func extractDate(from text: String) -> Date? {
        let detectors: [String] = [
            #"(?i)(january|february|march|april|may|june|july|august|september|october|november|december)\s+\d{1,2},?\s+\d{4}"#,
            #"\d{1,2}[/-]\d{1,2}[/-]\d{2,4}"#,
            #"\d{4}-\d{2}-\d{2}"#
        ]

        for pattern in detectors {
            if let range = text.range(of: pattern, options: .regularExpression) {
                let substring = String(text[range])
                for formatter in Self.dateFormatters {
                    if let date = formatter.date(from: substring) {
                        return date
                    }
                }
            }
        }

        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) {
            let nsRange = NSRange(text.startIndex..., in: text)
            if let match = detector.firstMatch(in: text, range: nsRange), let date = match.date {
                return date
            }
        }
        return nil
    }

    private static let dateFormatters: [DateFormatter] = {
        let formats = ["MMMM d, yyyy", "MMMM d yyyy", "MM/dd/yyyy", "dd/MM/yyyy", "yyyy-MM-dd"]
        return formats.map { format in
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = format
            return f
        }
    }()

    private func extractBillingCycle(from text: String) -> BillingCycle? {
        let lower = text.lowercased()
        if lower.contains("per week") || lower.contains("weekly") || lower.contains("/ week") { return .weekly }
        if lower.contains("per year") || lower.contains("yearly") || lower.contains("annual") || lower.contains("/ year") { return .yearly }
        if lower.contains("quarter") { return .quarterly }
        if lower.contains("per month") || lower.contains("monthly") || lower.contains("/ month") || lower.contains("/mo") { return .monthly }
        return nil
    }

    private func extractName(from lines: [String], priceInfo: PriceInfo?) -> String {
        for line in lines {
            let lower = line.lowercased()
            if lower.contains("next payment") || lower.contains("renew") || lower.contains("total") { continue }
            if line.range(of: #"^\$?\d"#, options: .regularExpression) != nil { continue }

            for preset in SubscriptionPreset.presets {
                if lower.contains(preset.name.lowercased()) {
                    return preset.name
                }
            }

            if line.count >= 2 && line.count <= 40 {
                return line.replacingOccurrences(of: "Premium", with: "").trimmingCharacters(in: .whitespaces)
            }
        }
        return lines.first ?? "Subscription"
    }

    private func extractPaymentMethod(from text: String) -> String? {
        let methods = ["visa", "mastercard", "amex", "paypal", "apple pay", "google pay"]
        let lower = text.lowercased()
        for method in methods where lower.contains(method) {
            return method.capitalized
        }
        return nil
    }
}
