//
//  NotificationScheduler.swift
//  SubTracker
//

import Foundation
import UserNotifications

enum NotificationScheduler {
    private static let center = UNUserNotificationCenter.current()

    static func renewalIdentifier(for subscriptionID: UUID) -> String {
        "renewal-\(subscriptionID.uuidString)"
    }

    static func trialIdentifier(for subscriptionID: UUID, daysBefore: Int) -> String {
        "trial-\(subscriptionID.uuidString)-\(daysBefore)"
    }

    static func requestPermissionIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        @unknown default:
            return false
        }
    }

    static func schedule(for subscription: Subscription) async {
        await cancel(for: subscription.id)

        guard subscription.isActive else { return }

        let granted = await requestPermissionIfNeeded()
        guard granted else { return }

        if subscription.reminderDaysBefore > 0 {
            await scheduleRenewalReminder(for: subscription)
        }

        if subscription.isTrial, let trialEnd = subscription.trialEndDate {
            await scheduleTrialReminders(for: subscription, trialEndDate: trialEnd)
        }
    }

    static func cancel(for subscriptionID: UUID) async {
        var ids = [renewalIdentifier(for: subscriptionID)]
        for days in [1, 3, 7] {
            ids.append(trialIdentifier(for: subscriptionID, daysBefore: days))
        }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    static func rescheduleAll(subscriptions: [Subscription]) async {
        center.removeAllPendingNotificationRequests()
        for subscription in subscriptions where subscription.isActive {
            await schedule(for: subscription)
        }
    }

    private static func scheduleRenewalReminder(for subscription: Subscription) async {
        guard let fireDate = Calendar.current.date(
            byAdding: .day,
            value: -subscription.reminderDaysBefore,
            to: subscription.nextPaymentDate
        ), fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming renewal"
        content.body = "\(subscription.name) renews in \(subscription.reminderDaysBefore) day\(subscription.reminderDaysBefore == 1 ? "" : "s") for \(CurrencyFormatter.format(subscription.price, currencyCode: subscription.currency))."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: renewalIdentifier(for: subscription.id),
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    private static func scheduleTrialReminders(for subscription: Subscription, trialEndDate: Date) async {
        for daysBefore in [1, 3, 7] {
            guard let fireDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: trialEndDate),
                  fireDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Trial ending soon"
            content.body = "Your \(subscription.name) trial ends in \(daysBefore) day\(daysBefore == 1 ? "" : "s")."
            content.sound = .default

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: trialIdentifier(for: subscription.id, daysBefore: daysBefore),
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }
}
