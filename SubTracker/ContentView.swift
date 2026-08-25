//
//  ContentView.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            AllSubscriptionsView()
                .tabItem {
                    Label("Subscriptions", systemImage: "rectangle.stack.fill")
                }
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// MARK: - Dashboard View

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Subscription> { $0.isActive == true },
           sort: \Subscription.nextPaymentDate,
           order: .forward)
    private var subscriptions: [Subscription]
    
    @State private var showingAddSubscription = false
    @State private var showingSubscriptionLimit = false
    @State private var showingPaywall = false
    @StateObject private var featureManager = FeatureManager.shared
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
    
    private var totalMonthly: Decimal {
        subscriptions.reduce(0) { $0 + $1.monthlyEquivalent }
    }
    
    private var totalYearly: Decimal {
        subscriptions.reduce(0) { $0 + $1.yearlyEquivalent }
    }
    
    private var upcomingSubscriptions: [Subscription] {
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        return subscriptions.filter { $0.nextPaymentDate <= thirtyDaysFromNow }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Greeting Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(greeting), Shovo")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("Your subscriptions")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            // Subscription count for free users
                            if !featureManager.isPro {
                                Text("\(subscriptions.count)/\(FeatureManager.freeSubscriptionLimit)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(subscriptions.count >= FeatureManager.freeSubscriptionLimit ? .orange : .secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(uiColor: .secondarySystemBackground))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Free tier warning banner
                    if !featureManager.isPro && subscriptions.count >= FeatureManager.freeSubscriptionLimit - 1 {
                        ProBanner(
                            title: subscriptions.count >= FeatureManager.freeSubscriptionLimit ? "Subscription Limit Reached" : "Almost at Your Limit",
                            message: featureManager.subscriptionLimitMessage(currentCount: subscriptions.count)
                        ) {
                            showingPaywall = true
                        }
                        .padding(.horizontal)
                    }
                    
                    // Cost Overview Cards
                    HStack(spacing: 16) {
                        CostCard(
                            amount: totalMonthly,
                            period: "this month",
                            color: .blue
                        )
                        
                        CostCard(
                            amount: totalYearly,
                            period: "estimated yearly",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    if subscriptions.isEmpty {
                        emptyStateView
                    } else {
                        // Upcoming Subscriptions
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("UPCOMING")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                if upcomingSubscriptions.count < subscriptions.count {
                                    NavigationLink {
                                        AllSubscriptionsView()
                                    } label: {
                                        Text("See All")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            if upcomingSubscriptions.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.green)
                                    
                                    Text("No payments due in the next 30 days")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(upcomingSubscriptions.prefix(5)) { subscription in
                                        NavigationLink {
                                            SubscriptionDetailView(subscription: subscription)
                                        } label: {
                                            SubscriptionRow(subscription: subscription)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        addSubscriptionTapped()
                    } label: {
                        Label("Add Subscription", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSubscription) {
                AddSubscriptionView()
            }
            .sheet(isPresented: $showingSubscriptionLimit) {
                SubscriptionLimitView(currentCount: subscriptions.count) {
                    showingPaywall = true
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
    
    // MARK: - Methods
    
    private func addSubscriptionTapped() {
        if featureManager.canAddSubscription(currentCount: subscriptions.count) {
            showingAddSubscription = true
        } else {
            showingSubscriptionLimit = true
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            
            Text("No Subscriptions")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap + to add your first subscription")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                addSubscriptionTapped()
            } label: {
                Label("Add Subscription", systemImage: "plus")
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 60)
    }
}

// MARK: - Cost Card

struct CostCard: View {
    let amount: Decimal
    let period: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(amount as NSDecimalNumber, formatter: currencyFormatter)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(period)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }
}

// MARK: - Subscription Row

struct SubscriptionRow: View {
    let subscription: Subscription
    
    private var urgencyColor: Color {
        let days = subscription.daysUntilNextPayment
        if days < 0 {
            return .gray
        } else if days == 0 {
            return .red
        } else if days <= 3 {
            return .orange
        } else if days <= 7 {
            return .yellow
        } else {
            return .green
        }
    }

    
    private var dateText: String {
        let days = subscription.daysUntilNextPayment
        if days < 0 {
            return "Overdue"
        } else if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else if days <= 7 {
            return "In \(days) days"
        } else {
            return subscription.nextPaymentDate.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: subscription.iconName)
                .font(.title2)
                .foregroundStyle(Color(hex: subscription.color))
                .frame(width: 44, height: 44)
                .background(Color(hex: subscription.color).opacity(0.1))
                .cornerRadius(10)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(urgencyColor)
                        .frame(width: 8, height: 8)
                    
                    Text(dateText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Price
            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.price as NSDecimalNumber, formatter: currencyFormatter)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(subscription.billingCycle.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = subscription.currency
        return formatter
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
