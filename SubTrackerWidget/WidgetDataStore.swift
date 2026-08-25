//
//  WidgetDataStore.swift
//  SubTrackerWidget
//

import Foundation

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
    static let appGroupID = "group.leo.SubTracker1"
    static let storageKey = "widgetSubscriptionData"

    static func load() -> WidgetDataPayload? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(WidgetDataPayload.self, from: data)
    }
}
