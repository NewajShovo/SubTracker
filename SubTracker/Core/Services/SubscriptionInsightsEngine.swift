//
//  SubscriptionInsightsEngine.swift
//  SubTracker
//

import Foundation

struct SubscriptionInsight: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let message: String
    let actionLabel: String?
}

enum SubscriptionInsightsEngine {
    static func generateInsights(from subscriptions: [Subscription]) -> [SubscriptionInsight] {
        let active = subscriptions.filter(\.isActive)
        guard !active.isEmpty else { return [] }

        var insights: [SubscriptionInsight] = []

        if let primaryCurrency = primaryCurrency(for: active) {
            let monthly = active.filter { $0.currency == primaryCurrency }
                .reduce(Decimal.zero) { $0 + $1.monthlyEquivalent }
            let yearly = active.filter { $0.currency == primaryCurrency }
                .reduce(Decimal.zero) { $0 + $1.yearlyEquivalent }

            insights.append(SubscriptionInsight(
                icon: "chart.line.uptrend.xyaxis",
                title: "Spending overview",
                message: "You spend \(CurrencyFormatter.format(monthly, currencyCode: primaryCurrency))/month on subscriptions. That's about \(CurrencyFormatter.format(yearly, currencyCode: primaryCurrency))/year.",
                actionLabel: nil
            ))
        }

        let sorted = active.sorted { $0.yearlyEquivalent > $1.yearlyEquivalent }
        if sorted.count >= 3, let primaryCurrency = primaryCurrency(for: active) {
            let sameCurrency = sorted.filter { $0.currency == primaryCurrency }
            let top3 = Array(sameCurrency.prefix(3))
            let top3Total = top3.reduce(Decimal.zero) { $0 + $1.yearlyEquivalent }
            let allTotal = sameCurrency.reduce(Decimal.zero) { $0 + $1.yearlyEquivalent }
            if allTotal > 0 {
                let pct = (top3Total as NSDecimalNumber).doubleValue / (allTotal as NSDecimalNumber).doubleValue * 100
                insights.append(SubscriptionInsight(
                    icon: "star.fill",
                    title: "Top spenders",
                    message: "Your 3 most expensive subscriptions account for about \(Int(pct))% of your yearly subscription spending.",
                    actionLabel: "Review subscriptions"
                ))
            }
        }

        let byCategory = Dictionary(grouping: active, by: \.category)
        if let (category, subs) = byCategory.max(by: { $0.value.count < $1.value.count }), subs.count >= 2,
           let currency = primaryCurrency(for: subs) {
            let total = subs.filter { $0.currency == currency }.reduce(Decimal.zero) { $0 + $1.monthlyEquivalent }
            insights.append(SubscriptionInsight(
                icon: category.systemImageName,
                title: "Category concentration",
                message: "Your \(category.rawValue.lowercased()) subscriptions cost \(CurrencyFormatter.format(total, currencyCode: currency))/month across \(subs.count) services.",
                actionLabel: "Review category"
            ))
        }

        let stale = active.filter {
            guard let last = $0.lastReviewedDate else { return true }
            let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
            return days > 90
        }
        if let candidate = stale.first {
            insights.append(SubscriptionInsight(
                icon: "lightbulb.fill",
                title: "Consider reviewing",
                message: "Consider reviewing \(candidate.name). You haven't updated it in a while.",
                actionLabel: "Review"
            ))
        }

        for trial in active.filter(\.isTrial) {
            if let days = trial.daysUntilTrialEnds, days >= 0, days <= 7 {
                insights.append(SubscriptionInsight(
                    icon: "clock.badge.exclamationmark.fill",
                    title: "Trial ending",
                    message: "Your \(trial.name) trial ends in \(days) day\(days == 1 ? "" : "s").",
                    actionLabel: nil
                ))
            }
        }

        return Array(insights.prefix(4))
    }

    private static func primaryCurrency(for subscriptions: [Subscription]) -> String? {
        Dictionary(grouping: subscriptions, by: \.currency)
            .max(by: { $0.value.count < $1.value.count })?.key
    }
}
