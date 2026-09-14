//
//  WidgetDataStore.swift
//  SubTracker
//

import Foundation
import WidgetKit

struct WidgetSubscriptionSnapshot: Codable, Identifiable {
    let id: String
    let name: String
    let price: String
    let currency: String
    let nextPaymentDate: Date
    let daysUntil: Int
    let iconName: String
    let colorHex: String
}

struct WidgetDataPayload: Codable {
    let monthlyTotalDisplay: String
    let yearlyTotalDisplay: String
    let activeCount: Int
    let upcoming: [WidgetSubscriptionSnapshot]
    let updatedAt: Date
}

enum WidgetDataStore {
    static let appGroupID = "group.com.applab.subtracker"
    static let storageKey = "widgetSubscriptionData"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static func update(from subscriptions: [Subscription]) {
        let active = subscriptions.filter(\.isActive).sorted { $0.nextPaymentDate < $1.nextPaymentDate }

        let primaryCurrency = Dictionary(grouping: active, by: \.currency)
            .max(by: { $0.value.count < $1.value.count })?.key ?? "USD"
        let sameCurrency = active.filter { $0.currency == primaryCurrency }
        let monthly = sameCurrency.reduce(Decimal.zero) { $0 + $1.monthlyEquivalent }
        let yearly = sameCurrency.reduce(Decimal.zero) { $0 + $1.yearlyEquivalent }

        let upcoming = active.prefix(5).map { sub in
            WidgetSubscriptionSnapshot(
                id: sub.id.uuidString,
                name: sub.name,
                price: CurrencyFormatter.format(sub.price, currencyCode: sub.currency),
                currency: sub.currency,
                nextPaymentDate: sub.nextPaymentDate,
                daysUntil: sub.daysUntilNextPayment,
                iconName: sub.iconName,
                colorHex: sub.color
            )
        }

        let payload = WidgetDataPayload(
            monthlyTotalDisplay: CurrencyFormatter.format(monthly, currencyCode: primaryCurrency),
            yearlyTotalDisplay: CurrencyFormatter.format(yearly, currencyCode: primaryCurrency),
            activeCount: active.count,
            upcoming: upcoming,
            updatedAt: Date()
        )

        if let data = try? JSONEncoder().encode(payload) {
            defaults.set(data, forKey: storageKey)
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func load() -> WidgetDataPayload? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(WidgetDataPayload.self, from: data)
    }
}
