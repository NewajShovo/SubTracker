//
//  ContentView.swift
//  SubTracker
//

import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }

            AllSubscriptionsView()
                .tabItem { Label("Subscriptions", systemImage: "rectangle.stack.fill") }

            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.bar.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var featureGate: FeatureGate
    @Query(filter: #Predicate<Subscription> { $0.isActive == true },
           sort: \Subscription.nextPaymentDate,
           order: .forward)
    private var activeSubscriptions: [Subscription]
    @Query private var allSubscriptions: [Subscription]

    @State private var showingAddSubscription = false
    @State private var showingScan = false
    @State private var showingSubscriptionLimit = false
    @State private var showingPaywall = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var insights: [SubscriptionInsight] {
        SubscriptionInsightsEngine.generateInsights(from: activeSubscriptions)
    }

    private var primaryCurrency: String {
        Dictionary(grouping: activeSubscriptions, by: \.currency)
            .max(by: { $0.value.count < $1.value.count })?.key ?? "USD"
    }

    private var totalMonthly: Decimal {
        activeSubscriptions.filter { $0.currency == primaryCurrency }
            .reduce(0) { $0 + $1.monthlyEquivalent }
    }

    private var totalYearly: Decimal {
        activeSubscriptions.filter { $0.currency == primaryCurrency }
            .reduce(0) { $0 + $1.yearlyEquivalent }
    }

    private var upcomingSubscriptions: [Subscription] {
        let thirtyDays = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        return activeSubscriptions.filter { $0.nextPaymentDate <= thirtyDays }
    }

    private var nextPayment: Subscription? {
        upcomingSubscriptions.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    if !featureGate.effectiveIsPro && allSubscriptions.count >= FeatureGate.freeSubscriptionLimit - 1 {
                        ProBanner(
                            title: allSubscriptions.count >= FeatureGate.freeSubscriptionLimit ? "Subscription Limit Reached" : "Almost at Your Limit",
                            message: featureGate.subscriptionLimitMessage(currentCount: allSubscriptions.count)
                        ) { showingPaywall = true }
                    }
                    spendingSection
                    nextPaymentSection
                    if !insights.isEmpty { insightsSection }
                    upcomingSection
                    Spacer(minLength: 80)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingAddSubscription) { AddSubscriptionView() }
            .sheet(isPresented: $showingScan) { ScanSubscriptionView() }
            .sheet(isPresented: $showingSubscriptionLimit) {
                SubscriptionLimitView(currentCount: allSubscriptions.count) { showingPaywall = true }
            }
            .sheet(isPresented: $showingPaywall) { PaywallView() }
            .onAppear { WidgetDataStore.update(from: allSubscriptions) }
            .onChange(of: allSubscriptions.count) { _, _ in
                WidgetDataStore.update(from: allSubscriptions)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.title2.bold())
            HStack {
                Text("Your subscriptions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if !featureGate.effectiveIsPro {
                    Text("\(allSubscriptions.count)/\(FeatureGate.freeSubscriptionLimit)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(allSubscriptions.count >= FeatureGate.freeSubscriptionLimit ? .orange : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private var spendingSection: some View {
        HStack(spacing: 16) {
            CostCard(
                amount: totalMonthly,
                currencyCode: primaryCurrency,
                label: "Monthly subscriptions",
                color: .blue
            )
            CostCard(
                amount: totalYearly,
                currencyCode: primaryCurrency,
                label: "Estimated yearly cost",
                color: .purple
            )
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var nextPaymentSection: some View {
        if let next = nextPayment {
            VStack(alignment: .leading, spacing: 12) {
                Text("NEXT PAYMENT")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                NavigationLink {
                    SubscriptionDetailView(subscription: next)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(next.name).font(.headline)
                            Text(nextPaymentLabel(for: next))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(CurrencyFormatter.format(next.price, currencyCode: next.currency))
                            .font(.title3.bold())
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INSIGHTS")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            ForEach(insights) { insight in
                InsightCard(insight: insight)
                    .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private var upcomingSection: some View {
        if activeSubscriptions.isEmpty {
            emptyStateView
        } else {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("UPCOMING")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    if upcomingSubscriptions.count < activeSubscriptions.count {
                        NavigationLink("See All") { AllSubscriptionsView() }
                            .font(.caption.weight(.semibold))
                    }
                }
                .padding(.horizontal)

                if upcomingSubscriptions.isEmpty {
                    Label("No payments due in the next 30 days", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    ForEach(upcomingSubscriptions.prefix(5)) { subscription in
                        NavigationLink {
                            SubscriptionDetailView(subscription: subscription)
                        } label: {
                            SubscriptionRow(subscription: subscription)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button { attemptScan() } label: {
                Label("Scan", systemImage: "doc.viewfinder")
            }
            Button { attemptAdd() } label: {
                Label("Add", systemImage: "plus")
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            Text("No subscriptions yet")
                .font(.title3.bold())
            Text("Add manually or scan a screenshot to get started.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 12) {
                Button { attemptScan() } label: {
                    Label("Scan", systemImage: "doc.viewfinder")
                }
                .buttonStyle(.borderedProminent)
                Button { attemptAdd() } label: {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 48)
        .padding(.horizontal)
    }

    private func attemptAdd() {
        if featureGate.canAddSubscription(totalCount: allSubscriptions.count) {
            showingAddSubscription = true
        } else {
            showingSubscriptionLimit = true
        }
    }

    private func attemptScan() {
        if featureGate.hasScanSubscription() {
            showingScan = true
        } else {
            showingPaywall = true
        }
    }

    private func nextPaymentLabel(for subscription: Subscription) -> String {
        let days = subscription.daysUntilNextPayment
        if days <= 0 { return "Due today" }
        if days == 1 { return "Tomorrow" }
        return "in \(days) days"
    }
}

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

#Preview {
    ContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
        .environmentObject(StoreManager.shared)
        .environmentObject(FeatureGate(storeManager: StoreManager.shared))
}
