//
//  SubscriptionRow.swift
//  SubTracker
//

import SwiftUI

struct SubscriptionRow: View {
    let subscription: Subscription

    private var urgencyColor: Color {
        let days = subscription.daysUntilNextPayment
        if days < 0 { return .gray }
        if days == 0 { return .red }
        if days <= 3 { return .orange }
        if days <= 7 { return .yellow }
        return .green
    }

    private var dateText: String {
        let days = subscription.daysUntilNextPayment
        if days < 0 { return "Overdue" }
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        if days <= 7 { return "In \(days) days" }
        return subscription.nextPaymentDate.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: subscription.iconName)
                .font(.title2)
                .foregroundStyle(Color(hex: subscription.color))
                .frame(width: 44, height: 44)
                .background(Color(hex: subscription.color).opacity(0.12))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name).font(.headline)
                HStack(spacing: 8) {
                    Circle().fill(urgencyColor).frame(width: 8, height: 8)
                    Text(dateText).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(CurrencyFormatter.format(subscription.price, currencyCode: subscription.currency))
                    .font(.headline)
                Text(subscription.billingCycle.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(14)
    }
}
