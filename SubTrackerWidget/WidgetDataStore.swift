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
    // App Groups disabled for now. Restore `group.leo.SubTracker1` when re-enabling sharing.
    // static let appGroupID = "group.leo.SubTracker1"
    static let storageKey = "widgetSubscriptionData"

    static func load() -> WidgetDataPayload? {
        // guard let defaults = UserDefaults(suiteName: appGroupID),
        //       let data = defaults.data(forKey: storageKey) else { return nil }
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(WidgetDataPayload.self, from: data)
    }
}
