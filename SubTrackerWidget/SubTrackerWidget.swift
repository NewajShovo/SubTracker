//
//  SubTrackerWidget.swift
//  SubTrackerWidget
//

import SwiftUI
import WidgetKit

struct SubTrackerWidgetEntry: TimelineEntry {
    let date: Date
    let payload: WidgetDataPayload?
}

struct SubTrackerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SubTrackerWidgetEntry {
        SubTrackerWidgetEntry(date: Date(), payload: samplePayload)
    }

    func getSnapshot(in context: Context, completion: @escaping (SubTrackerWidgetEntry) -> Void) {
        completion(SubTrackerWidgetEntry(date: Date(), payload: WidgetDataStore.load() ?? samplePayload))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SubTrackerWidgetEntry>) -> Void) {
        let payload = WidgetDataStore.load()
        let now = Date()
        let entry = SubTrackerWidgetEntry(date: now, payload: payload)
        let hourLater = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now.addingTimeInterval(3600)
        let nextMorning = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 10),
            matchingPolicy: .nextTime
        ) ?? hourLater
        completion(Timeline(entries: [entry], policy: .after(min(hourLater, nextMorning))))
    }

    private var samplePayload: WidgetDataPayload {
        WidgetDataPayload(
            monthlyTotalDisplay: "$47.96",
            upcoming: [
                WidgetSubscriptionSnapshot(name: "Netflix", price: "$17.99", currency: "USD", nextPaymentDate: Date(), daysUntil: 3)
            ],
            updatedAt: Date()
        )
    }
}

struct SubTrackerSmallWidgetView: View {
    let entry: SubTrackerWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Next Payment").font(.caption).foregroundStyle(.secondary)
            if let next = entry.payload?.upcoming.first {
                Text(next.name).font(.headline)
                Text(next.price).font(.title3.bold())
                Text(next.daysUntil <= 0 ? "Due today" : "in \(next.daysUntil) days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No upcoming payments").font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}

struct SubTrackerMediumWidgetView: View {
    let entry: SubTrackerWidgetEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Monthly").font(.caption).foregroundStyle(.secondary)
                Text(entry.payload?.monthlyTotalDisplay ?? "—").font(.title2.bold())
            }
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array((entry.payload?.upcoming ?? []).prefix(3).enumerated()), id: \.offset) { _, item in
                    HStack {
                        Text(item.name).lineLimit(1)
                        Spacer()
                        Text(item.price).font(.caption.weight(.semibold))
                    }
                }
            }
        }
        .padding()
    }
}

struct SubTrackerLargeWidgetView: View {
    let entry: SubTrackerWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SubTracker").font(.headline)
                Spacer()
                Text(entry.payload?.monthlyTotalDisplay ?? "—").font(.title3.bold())
            }
            Text("Upcoming").font(.caption).foregroundStyle(.secondary)
            ForEach(Array((entry.payload?.upcoming ?? []).prefix(5).enumerated()), id: \.offset) { _, item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Text(item.price)
                    Text(item.daysUntil <= 0 ? "Today" : "\(item.daysUntil)d")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            Spacer(minLength: 0)
        }
        .padding()
    }
}

struct SubTrackerSmallWidget: Widget {
    let kind = "SubTrackerSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubTrackerWidgetProvider()) { entry in
            SubTrackerSmallWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next Payment")
        .description("See your next upcoming subscription payment.")
        .supportedFamilies([.systemSmall])
    }
}

struct SubTrackerMediumWidget: Widget {
    let kind = "SubTrackerMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubTrackerWidgetProvider()) { entry in
            SubTrackerMediumWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Upcoming Payments")
        .description("Monthly total and upcoming renewals.")
        .supportedFamilies([.systemMedium])
    }
}

struct SubTrackerLargeWidget: Widget {
    let kind = "SubTrackerLargeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubTrackerWidgetProvider()) { entry in
            SubTrackerLargeWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Subscription Overview")
        .description("Monthly spending and upcoming payments.")
        .supportedFamilies([.systemLarge])
    }
}

@main
struct SubTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        SubTrackerSmallWidget()
        SubTrackerMediumWidget()
        SubTrackerLargeWidget()
    }
}
