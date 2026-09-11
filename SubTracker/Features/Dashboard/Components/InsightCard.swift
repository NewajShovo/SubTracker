//
//  InsightCard.swift
//  SubTracker
//

import SwiftUI

struct InsightCard: View {
    let insight: SubscriptionInsight

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: insight.icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 6) {
                Text(insight.title).font(.headline)
                Text(insight.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(14)
    }
}
