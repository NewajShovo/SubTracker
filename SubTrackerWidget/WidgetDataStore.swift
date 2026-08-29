//
//  WidgetDataStore.swift
//  SubTrackerWidget
//

import Foundation

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
    static let appGroupID = "group.leo.SubTracker1"
    static let storageKey = "widgetSubscriptionData"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static func load() -> WidgetDataPayload? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(WidgetDataPayload.self, from: data)
    }

    static var samplePayload: WidgetDataPayload {
        WidgetDataPayload(
            monthlyTotalDisplay: "$47.96",
            yearlyTotalDisplay: "$575.52",
            activeCount: 5,
            upcoming: [
                WidgetSubscriptionSnapshot(
                    id: UUID().uuidString,
                    name: "Netflix",
                    price: "$17.99",
                    currency: "USD",
                    nextPaymentDate: Date(),
                    daysUntil: 3,
                    iconName: "play.rectangle.fill",
                    colorHex: "#E50914"
                ),
                WidgetSubscriptionSnapshot(
                    id: UUID().uuidString,
                    name: "Spotify",
                    price: "$9.99",
                    currency: "USD",
                    nextPaymentDate: Date(),
                    daysUntil: 5,
                    iconName: "music.note",
                    colorHex: "#1DB954"
                ),
                WidgetSubscriptionSnapshot(
                    id: UUID().uuidString,
                    name: "iCloud+",
                    price: "$2.99",
                    currency: "USD",
                    nextPaymentDate: Date(),
                    daysUntil: 12,
                    iconName: "icloud.fill",
                    colorHex: "#5856D6"
                )
            ],
            updatedAt: Date()
        )
    }
}
