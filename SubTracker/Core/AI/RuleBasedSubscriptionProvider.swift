//
//  RuleBasedSubscriptionProvider.swift
//  SubTracker
//

import Foundation

struct RuleBasedSubscriptionProvider: SubscriptionIntelligenceProvider {
    func extractSubscription(from text: String) async throws -> ExtractedSubscription {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = normalized
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let priceInfo = extractPrice(from: normalized)
        let date = extractDate(from: normalized)
        let billingCycle = extractBillingCycle(from: normalized)
        let name = extractName(from: lines, fullText: normalized)
        let preset = SubscriptionPreset.preset(for: name) ?? SubscriptionPreset.matchInText(normalized)
        let currency = priceInfo?.currency ?? "USD"

        var confidence = 0.2
        if priceInfo != nil { confidence += 0.28 }
        if date != nil { confidence += 0.18 }
        if billingCycle != nil { confidence += 0.14 }
        if preset != nil { confidence += 0.22 }
        if name.count > 2 { confidence += 0.08 }
        if priceInfo != nil, (billingCycle != nil || date != nil) { confidence += 0.06 }

        return ExtractedSubscription(
            name: preset?.name ?? (name.isEmpty ? "Subscription" : name),
            price: priceInfo?.amount,
            currency: currency,
            billingCycle: billingCycle ?? preset?.billingCycle,
            nextPaymentDate: date,
            category: preset?.category,
            paymentMethod: extractPaymentMethod(from: normalized),
            confidence: min(confidence, 0.96),
            source: .ruleBased,
            rawText: normalized
        )
    }

    private struct PriceInfo {
        let amount: Decimal
        let currency: String
        let score: Int
    }

    private func extractPrice(from text: String) -> PriceInfo? {
        var candidates: [PriceInfo] = []
        for line in text.components(separatedBy: .newlines) {
            let lower = line.lowercased()
            var bonus = 0
            if lower.range(of: #"next payment|you'll be charged|you will be charged|amount due|total due"#, options: .regularExpression) != nil {
                bonus += 40
            } else if lower.contains("total") {
                bonus += 30
            } else if lower.range(of: #"\b(billed|price|plan|amount|charge|payment)\b"#, options: .regularExpression) != nil {
                bonus += 20
            }
            if lower.contains("tax") && !lower.contains("total") {
                bonus -= 30
            }

            for parsed in amounts(in: line) {
                var score = 10 + bonus + 8
                if parsed.amount >= 0.99 && parsed.amount <= 200 { score += 6 }
                candidates.append(PriceInfo(amount: parsed.amount, currency: parsed.currency, score: score))
            }
        }
        return candidates
            .filter { $0.amount > 0 && $0.amount < 100_000 }
            .max(by: { $0.score < $1.score })
    }

    /// Finds `$17.99`, `EUR 9,99`, and `1,199.00` on a single line.
    private func amounts(in line: String) -> [(amount: Decimal, currency: String)] {
        let pattern = #"(\$|€|£|₹|৳|USD|EUR|GBP|CAD|AUD|BDT|INR|JPY|Tk)?\s*(\d{1,3}(?:,\d{3})+(?:\.\d{1,2})?|\d{1,3}(?:\.\d{3})+(?:,\d{1,2})?|\d+[.,]\d{1,2}|\d+)\s*(USD|EUR|GBP|CAD|AUD|BDT|INR|JPY|Tk|৳|₹)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsRange = NSRange(line.startIndex..., in: line)
        return regex.matches(in: line, range: nsRange).compactMap { match in
            guard match.numberOfRanges >= 4,
                  let amountRange = Range(match.range(at: 2), in: line),
                  let amount = Self.parseAmount(String(line[amountRange])) else { return nil }

            let prefix = Range(match.range(at: 1), in: line).map { String(line[$0]) }
            let suffix = Range(match.range(at: 3), in: line).map { String(line[$0]) }
            guard prefix != nil || suffix != nil else { return nil }

            let currency = Self.currency(fromSymbol: prefix, code: suffix)
            return (amount, currency)
        }
    }

    private static func parseAmount(_ raw: String) -> Decimal? {
        let cleaned = raw.trimmingCharacters(in: .whitespaces)
        let hasDot = cleaned.contains(".")
        let hasComma = cleaned.contains(",")
        let normalized: String

        if hasDot && hasComma {
            if let lastDot = cleaned.lastIndex(of: "."), let lastComma = cleaned.lastIndex(of: ",") {
                if lastDot > lastComma {
                    normalized = cleaned.replacingOccurrences(of: ",", with: "")
                } else {
                    normalized = cleaned.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")
                }
            } else {
                normalized = cleaned
            }
        } else if hasComma {
            let parts = cleaned.split(separator: ",")
            if parts.count == 2, parts[1].count <= 2 {
                normalized = cleaned.replacingOccurrences(of: ",", with: ".")
            } else {
                normalized = cleaned.replacingOccurrences(of: ",", with: "")
            }
        } else {
            normalized = cleaned
        }

        return Decimal(string: normalized)
    }

    private static func currency(fromSymbol symbol: String?, code: String?) -> String {
        let marker = (code?.isEmpty == false ? code : symbol)?.uppercased()
        switch marker {
        case "€": return "EUR"
        case "£": return "GBP"
        case "₹": return "INR"
        case "৳", "TK": return "BDT"
        case "$": return "USD"
        case "USD", "EUR", "GBP", "CAD", "AUD", "BDT", "INR", "JPY":
            return marker ?? "USD"
        default:
            return "USD"
        }
    }

    private func extractDate(from text: String) -> Date? {
        let labeledPattern = #"(?i)(?:next payment|renews?(?:\s+on)?|next billing|billing date|payment date|due(?:\s+on)?|expires?(?:\s+on)?|trial ends?)[^\n]{0,48}(?<date>"# + Self.dateToken + ")"
        if let date = firstDate(in: text, pattern: labeledPattern) {
            return date
        }

        let dates = allDates(in: text)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        if let upcoming = dates.first(where: { $0 >= yesterday }) {
            return upcoming
        }
        return dates.last
    }

    private static let dateToken = #"(?:(?:january|february|march|april|may|june|july|august|september|october|november|december)\s+\d{1,2},?\s+\d{2,4}|\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{4}-\d{2}-\d{2})"#

    private func firstDate(in text: String, pattern: String) -> Date? {
        allDates(in: text, pattern: pattern).first
    }

    private func allDates(in text: String, pattern: String? = nil) -> [Date] {
        guard let regex = try? NSRegularExpression(pattern: pattern ?? Self.dateToken) else { return [] }
        let nsRange = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: nsRange).compactMap { match in
            let dateRange = match.range(withName: "date")
            let chosen = dateRange.location != NSNotFound ? dateRange : match.range
            guard let swiftRange = Range(chosen, in: text) else { return nil }
            let substring = String(text[swiftRange])
            for formatter in Self.dateFormatters {
                if let date = formatter.date(from: substring) {
                    return date
                }
            }
            return nil
        }
    }

    private static let dateFormatters: [DateFormatter] = {
        let formats = [
            "MMMM d, yyyy", "MMMM d yyyy", "MMM d, yyyy", "MMM d yyyy",
            "MMMM d, yy", "MM/dd/yyyy", "dd/MM/yyyy", "M/d/yyyy", "d/M/yyyy",
            "yyyy-MM-dd", "MM/dd/yy", "dd/MM/yy"
        ]
        return formats.map { format in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = format
            return formatter
        }
    }()

    private func extractBillingCycle(from text: String) -> BillingCycle? {
        let lower = text.lowercased()
        if lower.range(of: #"\b(per week|weekly|/ ?wk|/ ?week|every week)\b"#, options: .regularExpression) != nil {
            return .weekly
        }
        if lower.range(of: #"\b(per year|yearly|annually|annual|/ ?yr|/ ?year|billed yearly|billed annually)\b"#, options: .regularExpression) != nil {
            return .yearly
        }
        if lower.range(of: #"\b(quarter(?:ly)?|every 3 months|/ ?qtr)\b"#, options: .regularExpression) != nil {
            return .quarterly
        }
        if lower.range(of: #"\b(per month|monthly|/ ?mo(?:nth)?\.?|every month|billed monthly|renews monthly)\b"#, options: .regularExpression) != nil {
            return .monthly
        }
        return nil
    }

    private static let chromeKeywords: Set<String> = [
        "manage", "settings", "account", "billing", "payment", "cancel", "update",
        "continue", "confirm", "privacy", "terms", "help", "edit", "save", "next",
        "back", "done", "close", "share", "download", "receipt", "invoice",
        "subscription", "subscriptions", "your plan", "current plan", "choose a plan",
        "apple id", "payment method", "renewal", "total", "subtotal", "tax"
    ]

    private func extractName(from lines: [String], fullText: String) -> String {
        if let preset = SubscriptionPreset.matchInText(fullText) {
            return preset.name
        }

        for line in lines {
            let lower = line.lowercased()
            if Self.chromeKeywords.contains(where: { lower.contains($0) }) { continue }
            if line.range(of: #"^\$?\d"#, options: .regularExpression) != nil { continue }
            if line.count >= 2 && line.count <= 42 {
                return line
                    .replacingOccurrences(of: #"(?i)\s*(premium|standard|plus|plan)\s*$"#, with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
            }
        }

        return lines.first ?? ""
    }

    private func extractPaymentMethod(from text: String) -> String? {
        let methods: [(String, String)] = [
            ("apple pay", "Apple Pay"),
            ("google pay", "Google Pay"),
            ("mastercard", "Mastercard"),
            ("american express", "Amex"),
            ("amex", "Amex"),
            ("paypal", "PayPal"),
            ("visa", "Visa"),
            ("discover", "Discover"),
            ("bkash", "bKash"),
            ("nagad", "Nagad")
        ]
        let lower = text.lowercased()
        for (needle, label) in methods where lower.contains(needle) {
            return label
        }
        return nil
    }
}
