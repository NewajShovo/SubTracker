//
//  SyncManager.swift
//  SubTracker
//

import Foundation
import SwiftData

/// iCloud sync preference — full CloudKit SwiftData container requires Pro + user opt-in.
enum SyncManager {
    private static let enabledKey = "iCloudSyncEnabled"

    static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    static func makeContainer(enableCloud: Bool) throws -> ModelContainer {
        let schema = Schema([Subscription.self, PaymentRecord.self])
        let config: ModelConfiguration
        if enableCloud {
            config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
        } else {
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }
        return try ModelContainer(for: schema, configurations: [config])
    }
}
