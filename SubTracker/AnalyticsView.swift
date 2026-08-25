//
//  AnalyticsView.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Query(filter: #Predicate<Subscription> { $0.isActive == true })
    private var subscriptions: [Subscription]
    
    private var totalMonthly: Decimal {
        subscriptions.reduce(0) { $0 + $1.monthlyEquivalent }
    }
    
    private var totalYearly: Decimal {
        subscriptions.reduce(0) { $0 + $1.yearlyEquivalent }
    }
    
    private var categoryBreakdown: [(Category, Decimal)] {
        let grouped = Dictionary(grouping: subscriptions) { $0.category }
        return grouped.map { (category, subs) in
            let total = subs.reduce(0) { $0 + $1.monthlyEquivalent }
            return (category, total)
        }
        .sorted { $0.1 > $1.1 }
    }
    
    private var topThreeSubscriptions: [Subscription] {
        Array(subscriptions.sorted { $0.yearlyEquivalent > $1.yearlyEquivalent }.prefix(3))
    }
    
    private var topThreeTotal: Decimal {
        topThreeSubscriptions.reduce(0) { $0 + $1.yearlyEquivalent }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SPENDING")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 16) {
                            StatRow(
                                label: "Monthly",
                                value: totalMonthly,
                                color: .blue
                            )
                            
                            Divider()
                            
                            StatRow(
                                label: "Yearly",
                                value: totalYearly,
                                color: .purple
                            )
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Category Breakdown Chart
                    if !categoryBreakdown.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("BY CATEGORY")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                Chart(categoryBreakdown, id: \.0) { category, amount in
                                    SectorMark(
                                        angle: .value("Amount", amount),
                                        innerRadius: .ratio(0.5),
                                        angularInset: 1.5
                                    )
                                    .foregroundStyle(Color(hex: category.defaultColor))
                                    .cornerRadius(4)
                                }
                                .frame(height: 200)
                                .padding()
                                
                                VStack(spacing: 12) {
                                    ForEach(categoryBreakdown, id: \.0) { category, amount in
                                        HStack {
                                            Circle()
                                                .fill(Color(hex: category.defaultColor))
                                                .frame(width: 12, height: 12)
                                            
                                            Label(category.rawValue, systemImage: category.systemImageName)
                                                .font(.subheadline)
                                            
                                            Spacer()
                                            
                                            Text(amount as NSDecimalNumber, formatter: currencyFormatter)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                    }
                                }
                                .padding()
                            }
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Subscription Count
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SUMMARY")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 16) {
                            HStack {
                                Text("Active subscriptions")
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Text("\(subscriptions.count)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            if subscriptions.count > 0 {
                                Divider()
                                
                                HStack {
                                    Text("Average per subscription")
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(totalMonthly / Decimal(subscriptions.count) as NSDecimalNumber, formatter: currencyFormatter)
                                        .font(.headline)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Top Subscriptions
                    if !topThreeSubscriptions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("TOP SUBSCRIPTIONS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            
                            VStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your 3 most expensive subscriptions")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(topThreeTotal as NSDecimalNumber, formatter: currencyFormatter)
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    Text("per year")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                
                                Divider()
                                
                                ForEach(Array(topThreeSubscriptions.enumerated()), id: \.element.id) { index, subscription in
                                    HStack(spacing: 12) {
                                        Text("#\(index + 1)")
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 32)
                                        
                                        Image(systemName: subscription.iconName)
                                            .foregroundStyle(Color(hex: subscription.color))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(subscription.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            
                                            Text("\(subscription.price as NSDecimalNumber, formatter: currencyFormatter) / \(subscription.billingCycle.rawValue.lowercased())")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(subscription.yearlyEquivalent as NSDecimalNumber, formatter: currencyFormatter)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    .padding()
                                    
                                    if index < topThreeSubscriptions.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 32)
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
        }
    }
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }
}

struct StatRow: View {
    let label: String
    let value: Decimal
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value as NSDecimalNumber, formatter: currencyFormatter)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
    }
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
