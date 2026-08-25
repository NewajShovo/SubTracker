//
//  AllSubscriptionsView.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import SwiftUI
import SwiftData

struct AllSubscriptionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subscription.nextPaymentDate, order: .forward)
    private var allSubscriptions: [Subscription]
    
    @State private var showingAddSubscription = false
    @State private var filterActive = true
    
    private var filteredSubscriptions: [Subscription] {
        allSubscriptions.filter { subscription in
            filterActive ? subscription.isActive : !subscription.isActive
        }
    }
    
    private var subscriptionsByCategory: [Category: [Subscription]] {
        Dictionary(grouping: filteredSubscriptions) { $0.category }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Category.allCases, id: \.self) { category in
                    if let subscriptions = subscriptionsByCategory[category], !subscriptions.isEmpty {
                        Section {
                            ForEach(subscriptions) { subscription in
                                NavigationLink {
                                    SubscriptionDetailView(subscription: subscription)
                                } label: {
                                    SubscriptionListRow(subscription: subscription)
                                }
                            }
                        } header: {
                            Label(category.rawValue, systemImage: category.systemImageName)
                        }
                    }
                }
            }
            .navigationTitle("All Subscriptions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSubscription = true
                    } label: {
                        Label("Add Subscription", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Picker("Filter", selection: $filterActive) {
                        Text("Active").tag(true)
                        Text("Inactive").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .sheet(isPresented: $showingAddSubscription) {
                AddSubscriptionView()
            }
            .overlay {
                if filteredSubscriptions.isEmpty {
                    ContentUnavailableView(
                        "No \(filterActive ? "Active" : "Inactive") Subscriptions",
                        systemImage: "rectangle.stack",
                        description: Text(filterActive ? "Add a subscription to get started" : "You don't have any inactive subscriptions")
                    )
                }
            }
        }
    }
}

struct SubscriptionListRow: View {
    let subscription: Subscription
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: subscription.iconName)
                .font(.title3)
                .foregroundStyle(Color(hex: subscription.color))
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.headline)
                
                Text(subscription.nextPaymentDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.price as NSDecimalNumber, formatter: currencyFormatter)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subscription.billingCycle.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = subscription.currency
        return formatter
    }
}

#Preview {
    AllSubscriptionsView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
