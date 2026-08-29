//
//  WidgetProvider.swift
//  SubTrackerWidget
//

import WidgetKit

struct SubTrackerWidgetEntry: TimelineEntry {
    let date: Date
    let payload: WidgetDataPayload?
}

struct SubTrackerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SubTrackerWidgetEntry {
        SubTrackerWidgetEntry(date: Date(), payload: WidgetDataStore.samplePayload)
    }

    func getSnapshot(in context: Context, completion: @escaping (SubTrackerWidgetEntry) -> Void) {
        let loaded = WidgetDataStore.load()
        let payload = context.isPreview ? (loaded ?? WidgetDataStore.samplePayload) : loaded
        completion(SubTrackerWidgetEntry(date: Date(), payload: payload))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SubTrackerWidgetEntry>) -> Void) {
        let payload = WidgetDataStore.load()
        let now = Date()
        let calendar = Calendar.current

        var entryDates: Set<Date> = [now]

        // Refresh at midnight for the next week so day-count labels stay accurate.
        let startOfToday = calendar.startOfDay(for: now)
        for dayOffset in 1...7 {
            if let midnight = calendar.date(byAdding: .day, value: dayOffset, to: startOfToday) {
                entryDates.insert(midnight)
            }
        }

        // Refresh when upcoming payment dates arrive.
        payload?.upcoming.forEach { item in
            let paymentDay = calendar.startOfDay(for: item.nextPaymentDate)
            if paymentDay > now {
                entryDates.insert(paymentDay)
            }
        }

        let sortedDates = entryDates.sorted()
        let entries = sortedDates.map { SubTrackerWidgetEntry(date: $0, payload: payload) }

        let nextHour = calendar.date(byAdding: .hour, value: 1, to: now) ?? now.addingTimeInterval(3600)
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? nextHour
        let reloadDate = min(nextHour, nextMidnight)

        completion(Timeline(entries: entries.isEmpty ? [SubTrackerWidgetEntry(date: now, payload: payload)] : entries, policy: .after(reloadDate)))
    }
}
