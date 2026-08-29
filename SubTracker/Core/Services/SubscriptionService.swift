//
//  SubscriptionService.swift
//  SubTracker
//

import Foundation
import SwiftData

enum SubscriptionService {
    @MainActor
    static func save(
        _ subscription: Subscription,
        in context: ModelContext,
        isNew: Bool,
        allSubscriptions: [Subscription]
    ) async {
        if isNew {
            context.insert(subscription)
        }
        try? context.save()
        WidgetDataStore.update(from: allSubscriptions + (isNew ? [subscription] : []))
        await NotificationScheduler.schedule(for: subscription)
    }

    @MainActor
    static func delete(_ subscription: Subscription, in context: ModelContext, remaining: [Subscription]) async {
        await NotificationScheduler.cancel(for: subscription.id)
        context.delete(subscription)
        try? context.save()
        WidgetDataStore.update(from: remaining)
    }

    @MainActor
    static func setActive(
        _ subscription: Subscription,
        isActive: Bool,
        in context: ModelContext,
        allSubscriptions: [Subscription]
    ) async {
        subscription.isActive = isActive
        try? context.save()
        if isActive {
            await NotificationScheduler.schedule(for: subscription)
        } else {
            await NotificationScheduler.cancel(for: subscription.id)
        }
        WidgetDataStore.update(from: allSubscriptions)
    }
}
