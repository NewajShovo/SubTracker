//
//  SubTrackerWidget.swift
//  SubTrackerWidget
//

import SwiftUI
import WidgetKit

// MARK: - Home Screen Widgets

struct SubTrackerSmallWidget: Widget {
    let kind = "SubTrackerSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubTrackerWidgetProvider()) { entry in
            SubTrackerSmallWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetBackgroundView(style: .vibrant)
                }
        }
        .configurationDisplayName("Next Payment")
        .description("See your next upcoming renewal at a glance.")
        .supportedFamilies([.systemSmall])
    }
}

struct SubTrackerMediumWidget: Widget {
    let kind = "SubTrackerMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubTrackerWidgetProvider()) { entry in
            SubTrackerMediumWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetBackgroundView(style: .vibrant)
                }
        }
        .configurationDisplayName("Spending & Upcoming")
        .description("Monthly total with your next three renewals.")
        .supportedFamilies([.systemMedium])
    }
}

struct SubTrackerLargeWidget: Widget {
    let kind = "SubTrackerLargeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubTrackerWidgetProvider()) { entry in
            SubTrackerLargeWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetBackgroundView(style: .vibrant)
                }
        }
        .configurationDisplayName("Subscription Overview")
        .description("Monthly and yearly spending with upcoming renewals.")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Lock Screen Widget

struct SubTrackerLockScreenWidget: Widget {
    let kind = "SubTrackerLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubTrackerWidgetProvider()) { entry in
            SubTrackerLockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("Renewal Countdown")
        .description("Glanceable next payment on your Lock Screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct SubTrackerLockScreenWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SubTrackerWidgetEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            SubTrackerLockCircularView(entry: entry)
        case .accessoryRectangular:
            SubTrackerLockRectangularView(entry: entry)
        case .accessoryInline:
            SubTrackerLockInlineView(entry: entry)
        default:
            SubTrackerLockCircularView(entry: entry)
        }
    }
}

// MARK: - Bundle

@main
struct SubTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        SubTrackerSmallWidget()
        SubTrackerMediumWidget()
        SubTrackerLargeWidget()
        SubTrackerLockScreenWidget()
    }
}
