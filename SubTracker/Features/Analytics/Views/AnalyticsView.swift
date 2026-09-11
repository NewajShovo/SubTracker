//
//  AnalyticsView.swift
//  SubTracker
//

import Charts
import SwiftData
import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject private var featureGate: FeatureGate
    @Query(filter: #Predicate<Subscription> { $0.isActive == true })
    private var subscriptions: [Subscription]

    @State private var showingPaywall = false

    private var primaryCurrency: String? {
        Dictionary(grouping: subscriptions, by: \.currency)
            .max(by: { $0.value.count < $1.value.count })?.key
    }

    private var sameCurrencySubs: [Subscription] {
        guard let primaryCurrency else { return subscriptions }
        return subscriptions.filter { $0.currency == primaryCurrency }
    }

    private var totalMonthly: Decimal {
        sameCurrencySubs.reduce(0) { $0 + $1.monthlyEquivalent }
    }

    private var totalYearly: Decimal {
        sameCurrencySubs.reduce(0) { $0 + $1.yearlyEquivalent }
    }

    private var categoryBreakdown: [(Category, Decimal)] {
        let grouped = Dictionary(grouping: sameCurrencySubs, by: \.category)
        return grouped.map { category, subs in
            (category, subs.reduce(0) { $0 + $1.monthlyEquivalent })
        }.sorted { $0.1 > $1.1 }
    }

    private var topThreeSubscriptions: [Subscription] {
        Array(sameCurrencySubs.sorted { $0.yearlyEquivalent > $1.yearlyEquivalent }.prefix(3))
    }

    private var topThreeTotal: Decimal {
        topThreeSubscriptions.reduce(0) { $0 + $1.yearlyEquivalent }
    }

    private var hasMultipleCurrencies: Bool {
        Set(subscriptions.map(\.currency)).count > 1
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if subscriptions.isEmpty {
                        ContentUnavailableView("No Data", systemImage: "chart.bar", description: Text("Add subscriptions to see analytics"))
                    } else {
                        basicSection
                        if hasMultipleCurrencies {
                            multiCurrencyNotice
                        }
                        if featureGate.hasAdvancedAnalytics() {
                            advancedSection
                        } else {
                            advancedLockedSection
                        }
                    }
                    Spacer(minLength: 32)
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            .fullScreenCover(isPresented: $showingPaywall) { PaywallView() }
        }
    }

    private var basicSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SPENDING")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            VStack(spacing: 16) {
                if let currency = primaryCurrency {
                    StatRow(label: "Monthly", value: totalMonthly, currencyCode: currency, color: .blue)
                    Divider()
                    StatRow(label: "Yearly", value: totalYearly, currencyCode: currency, color: .purple)
                }
                HStack {
                    Text("Active subscriptions").foregroundStyle(.secondary)
                    Spacer()
                    Text("\(subscriptions.count)").font(.title2.bold())
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(14)
            .padding(.horizontal)
        }
    }

    private var multiCurrencyNotice: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Multiple currencies detected", systemImage: "coloncurrencysign.circle")
                .font(.headline)
            Text("Totals are shown per primary currency (\(primaryCurrency ?? "")). Other currencies are listed separately below.")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(CurrencyFormatter.totalsByCurrency(subscriptions: subscriptions, keyPath: \.monthlyEquivalent), id: \.currency) { item in
                HStack {
                    Text(item.currency)
                    Spacer()
                    Text(CurrencyFormatter.format(item.total, currencyCode: item.currency))
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.08))
        .cornerRadius(14)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var advancedSection: some View {
        if !categoryBreakdown.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("BY CATEGORY")
                    .font(.caption.weight(.semibold))
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
                                Circle().fill(Color(hex: category.defaultColor)).frame(width: 12, height: 12)
                                Label(category.rawValue, systemImage: category.systemImageName)
                                    .font(.subheadline)
                                Spacer()
                                if let currency = primaryCurrency {
                                    Text(CurrencyFormatter.format(amount, currencyCode: currency))
                                        .font(.subheadline.weight(.medium))
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(14)
                .padding(.horizontal)
            }
        }

        if !topThreeSubscriptions.isEmpty, let currency = primaryCurrency {
            VStack(alignment: .leading, spacing: 16) {
                Text("TOP SUBSCRIPTIONS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your 3 most expensive subscriptions")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.format(topThreeTotal, currencyCode: currency))
                            .font(.title.bold())
                        Text("per year").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding()
                    Divider()
                    ForEach(Array(topThreeSubscriptions.enumerated()), id: \.element.id) { index, subscription in
                        HStack(spacing: 12) {
                            Text("#\(index + 1)").font(.headline).foregroundStyle(.secondary).frame(width: 32)
                            Image(systemName: subscription.iconName).foregroundStyle(Color(hex: subscription.color))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(subscription.name).font(.subheadline.weight(.medium))
                                Text("\(CurrencyFormatter.format(subscription.price, currencyCode: subscription.currency)) / \(subscription.billingCycle.rawValue.lowercased())")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(CurrencyFormatter.format(subscription.yearlyEquivalent, currencyCode: subscription.currency))
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding()
                        if index < topThreeSubscriptions.count - 1 { Divider() }
                    }
                }
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(14)
                .padding(.horizontal)
            }
        }

        if sameCurrencySubs.count > 0 {
            VStack(alignment: .leading, spacing: 16) {
                Text("SUMMARY")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                HStack {
                    Text("Average per subscription").foregroundStyle(.secondary)
                    Spacer()
                    if let currency = primaryCurrency {
                        Text(CurrencyFormatter.format(totalMonthly / Decimal(sameCurrencySubs.count), currencyCode: currency))
                            .font(.headline.weight(.medium))
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(14)
                .padding(.horizontal)
            }
        }
    }

    private var advancedLockedSection: some View {
        VStack(spacing: 16) {
            ProBanner(
                title: "Advanced Analytics",
                message: "Unlock category charts, top spenders, and deeper insights with Pro."
            ) { showingPaywall = true }
        }
        .padding(.horizontal)
    }
}

struct StatRow: View {
    let label: String
    let value: Decimal
    let currencyCode: String
    let color: Color

    var body: some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(CurrencyFormatter.format(value, currencyCode: currencyCode))
                .font(.title2.bold())
                .foregroundStyle(color)
        }
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: Subscription.self, inMemory: true)
        .environmentObject(FeatureGate(storeManager: StoreManager.shared))
}
