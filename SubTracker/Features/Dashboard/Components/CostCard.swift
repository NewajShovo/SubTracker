//
//  CostCard.swift
//  SubTracker
//

import SwiftUI

struct CostCard: View {
    let amount: Decimal
    let currencyCode: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(CurrencyFormatter.format(amount, currencyCode: currencyCode))
                .font(.title2.bold())
                .foregroundStyle(color)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(14)
    }
}
