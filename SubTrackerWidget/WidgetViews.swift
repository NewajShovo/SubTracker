//
//  WidgetViews.swift
//  SubTrackerWidget
//

import SwiftUI
import WidgetKit

// MARK: - Small Widget

struct SubTrackerSmallWidgetView: View {
    let entry: SubTrackerWidgetEntry
    private var payload: WidgetDataPayload? { entry.payload }
    private var next: WidgetSubscriptionSnapshot? { payload?.upcoming.first }

    var body: some View {
        Group {
            if let next, let payload {
                smallContent(next: next, payload: payload)
            } else {
                WidgetEmptyState(
                    title: "No Upcoming Payments",
                    subtitle: "Add subscriptions in SubTracker to see renewals here.",
                    icon: "calendar.badge.clock"
                )
            }
        }
        .widgetURL(next.map { WidgetLink.subscription(id: $0.id) } ?? WidgetLink.dashboard)
    }

    private func smallContent(next: WidgetSubscriptionSnapshot, payload: WidgetDataPayload) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                WidgetBrandMark(compact: true)
                Spacer()
                Text("NEXT")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                WidgetSubscriptionIcon(
                    iconName: next.iconName,
                    colorHex: next.colorHex,
                    size: 40
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(next.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(next.price)
                        .font(.title3.bold())
                        .foregroundStyle(WidgetDesign.accentBlue)
                }
            }

            Spacer(minLength: 8)

            WidgetUrgencyBadge(daysUntil: next.daysUntil)

            if payload.activeCount > 1 {
                Text("\(payload.activeCount) active subscriptions")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
    }
}

// MARK: - Medium Widget

struct SubTrackerMediumWidgetView: View {
    let entry: SubTrackerWidgetEntry
    private var payload: WidgetDataPayload? { entry.payload }

    var body: some View {
        Group {
            if let payload, !payload.upcoming.isEmpty {
                mediumContent(payload: payload)
            } else {
                WidgetEmptyState(
                    title: "Start Tracking",
                    subtitle: "Your upcoming renewals and monthly total will appear here.",
                    icon: "rectangle.stack.fill"
                )
                .padding(.horizontal, 8)
            }
        }
        .widgetURL(WidgetLink.dashboard)
    }

    private func mediumContent(payload: WidgetDataPayload) -> some View {
        HStack(spacing: 12) {
            WidgetSpendCard(
                label: "Monthly",
                value: payload.monthlyTotalDisplay,
                subtitle: "\(payload.activeCount) active",
                compact: true
            )
            .frame(width: 118)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("UPCOMING")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                ForEach(Array(payload.upcoming.prefix(3).enumerated()), id: \.element.id) { index, item in
                    Link(destination: WidgetLink.subscription(id: item.id)) {
                        WidgetUpcomingRow(
                            item: item,
                            showDivider: index < min(2, payload.upcoming.count - 1),
                            compact: true
                        )
                    }
                }

                Spacer(minLength: 0)
            }
        }
        .padding(14)
    }
}

// MARK: - Large Widget

struct SubTrackerLargeWidgetView: View {
    let entry: SubTrackerWidgetEntry
    private var payload: WidgetDataPayload? { entry.payload }

    var body: some View {
        Group {
            if let payload, !payload.upcoming.isEmpty {
                largeContent(payload: payload)
            } else {
                WidgetEmptyState(
                    title: "No Subscriptions Yet",
                    subtitle: "Open SubTracker to add your first subscription and track spending.",
                    icon: "plus.rectangle.on.rectangle"
                )
                .padding()
            }
        }
        .widgetURL(WidgetLink.dashboard)
    }

    private func largeContent(payload: WidgetDataPayload) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                WidgetBrandMark()
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Updated")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Text(payload.updatedAt, style: .time)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 10) {
                WidgetSpendCard(
                    label: "Monthly",
                    value: payload.monthlyTotalDisplay,
                    subtitle: nil,
                    compact: true
                )
                WidgetSpendCard(
                    label: "Yearly",
                    value: payload.yearlyTotalDisplay,
                    subtitle: "estimated",
                    compact: true,
                    gradient: WidgetDesign.yearlyGradient
                )
            }

            HStack {
                Text("UPCOMING RENEWALS")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(payload.activeCount) active")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            VStack(spacing: 0) {
                ForEach(Array(payload.upcoming.prefix(5).enumerated()), id: \.element.id) { index, item in
                    Link(destination: WidgetLink.subscription(id: item.id)) {
                        WidgetUpcomingRow(
                            item: item,
                            showDivider: index < min(4, payload.upcoming.count - 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            Spacer(minLength: 0)
        }
        .padding(16)
    }
}

// MARK: - Lock Screen Widgets

struct SubTrackerLockCircularView: View {
    let entry: SubTrackerWidgetEntry
    private var next: WidgetSubscriptionSnapshot? { entry.payload?.upcoming.first }

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            if let next {
                VStack(spacing: 1) {
                    Text(next.daysUntil <= 0 ? "!" : "\(max(next.daysUntil, 0))")
                        .font(.title2.bold())
                    Text("days")
                        .font(.system(size: 8, weight: .medium))
                }
            } else {
                Image(systemName: "calendar")
                    .font(.title3)
            }
        }
        .widgetURL(next.map { WidgetLink.subscription(id: $0.id) } ?? WidgetLink.dashboard)
    }
}

struct SubTrackerLockRectangularView: View {
    let entry: SubTrackerWidgetEntry
    private var next: WidgetSubscriptionSnapshot? { entry.payload?.upcoming.first }

    var body: some View {
        if let next {
            HStack(spacing: 6) {
                Image(systemName: next.iconName)
                    .font(.caption.weight(.semibold))
                VStack(alignment: .leading, spacing: 1) {
                    Text(next.name)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                    Text("\(next.price) · \(WidgetDesign.shortUrgencyLabel(for: next.daysUntil))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .widgetURL(WidgetLink.subscription(id: next.id))
        } else {
            Text("No upcoming payments")
                .font(.caption)
                .widgetURL(WidgetLink.dashboard)
        }
    }
}

struct SubTrackerLockInlineView: View {
    let entry: SubTrackerWidgetEntry
    private var next: WidgetSubscriptionSnapshot? { entry.payload?.upcoming.first }

    var body: some View {
        if let next {
            Text("\(next.name) · \(next.price) · \(WidgetDesign.shortUrgencyLabel(for: next.daysUntil))")
                .widgetURL(WidgetLink.subscription(id: next.id))
        } else {
            Text("SubTracker — No upcoming payments")
                .widgetURL(WidgetLink.dashboard)
        }
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    SubTrackerSmallWidget()
} timeline: {
    SubTrackerWidgetEntry(date: .now, payload: WidgetDataStore.samplePayload)
    SubTrackerWidgetEntry(date: .now, payload: nil)
}

#Preview("Medium", as: .systemMedium) {
    SubTrackerMediumWidget()
} timeline: {
    SubTrackerWidgetEntry(date: .now, payload: WidgetDataStore.samplePayload)
}

#Preview("Large", as: .systemLarge) {
    SubTrackerLargeWidget()
} timeline: {
    SubTrackerWidgetEntry(date: .now, payload: WidgetDataStore.samplePayload)
}
