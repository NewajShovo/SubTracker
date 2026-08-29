//
//  WidgetDataStore.swift
//  SubTracker
//

import Foundation
import WidgetKit

struct WidgetSubscriptionSnapshot: Codable {
    let name: String
    let price: String
    let currency: String
    let nextPaymentDate: Date
    let daysUntil: Int
}

struct WidgetDataPayload: Codable {
    let monthlyTotalDisplay: String
    let upcoming: [WidgetSubscriptionSnapshot]
    let updatedAt: Date
}

enum WidgetDataStore {
    // App Groups disabled for now. Restore `group.leo.SubTracker1` when re-enabling widgets sharing.
    // static let appGroupID = "group.leo.SubTracker1"
    static let storageKey = "widgetSubscriptionData"

    static var defaults: UserDefaults {
        // UserDefaults(suiteName: appGroupID) ?? .standard
        .standard
    }

    static func update(from subscriptions: [Subscription]) {
        let active = subscriptions.filter(\.isActive).sorted { $0.nextPaymentDate < $1.nextPaymentDate }
        let store = defaults

        let primaryCurrency = Dictionary(grouping: active, by: \.currency)
            .max(by: { $0.value.count < $1.value.count })?.key ?? "USD"
        let monthly = active.filter { $0.currency == primaryCurrency }
            .reduce(Decimal.zero) { $0 + $1.monthlyEquivalent }

        let upcoming = active.prefix(5).map { sub in
            WidgetSubscriptionSnapshot(
                name: sub.name,
                price: CurrencyFormatter.format(sub.price, currencyCode: sub.currency),
                currency: sub.currency,
                nextPaymentDate: sub.nextPaymentDate,
                daysUntil: sub.daysUntilNextPayment
            )
        }

        let payload = WidgetDataPayload(
            monthlyTotalDisplay: CurrencyFormatter.format(monthly, currencyCode: primaryCurrency),
            upcoming: upcoming,
            updatedAt: Date()
        )

        if let data = try? JSONEncoder().encode(payload) {
            store.set(data, forKey: storageKey)
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func load() -> WidgetDataPayload? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(WidgetDataPayload.self, from: data)
    }
}
