//
//  AllSubscriptionsView.swift
//  SubTracker
//

import SwiftData
import SwiftUI

enum SubscriptionSortOption: String, CaseIterable, Identifiable {
    case nextPayment = "Next Payment"
    case price = "Price"
    case name = "Name"
    case recentlyAdded = "Recently Added"

    var id: String { rawValue }
}

struct AllSubscriptionsView: View {
    @EnvironmentObject private var featureGate: FeatureGate
    @Query private var allSubscriptions: [Subscription]

    @State private var showingAddSubscription = false
    @State private var showingLimit = false
    @State private var showingPaywall = false
    @State private var filterActive = true
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var sortOption: SubscriptionSortOption = .nextPayment

    private var filteredSubscriptions: [Subscription] {
        var results = allSubscriptions.filter { filterActive ? $0.isActive : !$0.isActive }

        if let selectedCategory {
            results = results.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            results = results.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                $0.paymentMethod.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortOption {
        case .nextPayment:
            results.sort { $0.nextPaymentDate < $1.nextPaymentDate }
        case .price:
            results.sort { $0.monthlyEquivalent > $1.monthlyEquivalent }
        case .name:
            results.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .recentlyAdded:
            results.sort { $0.createdDate > $1.createdDate }
        }
        return results
    }

    private var subscriptionsByCategory: [Category: [Subscription]] {
        Dictionary(grouping: filteredSubscriptions, by: \.category)
    }

    var body: some View {
        NavigationStack {
            List {
                if !searchText.isEmpty || selectedCategory != nil {
                    Section {
                        if let selectedCategory {
                            LabeledContent("Category", value: selectedCategory.rawValue)
                        }
                        LabeledContent("Results", value: "\(filteredSubscriptions.count)")
                    }
                }

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
            .navigationTitle("Subscriptions")
            .searchable(text: $searchText, prompt: "Search subscriptions")
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingAddSubscription) { AddSubscriptionView() }
            .sheet(isPresented: $showingLimit) {
                SubscriptionLimitView(currentCount: allSubscriptions.count) { showingPaywall = true }
            }
            .fullScreenCover(isPresented: $showingPaywall) { PaywallView() }
            .overlay {
                if filteredSubscriptions.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No \(filterActive ? "Active" : "Inactive") Subscriptions" : "No Results",
                        systemImage: "rectangle.stack",
                        description: Text(searchText.isEmpty ? "Add a subscription to get started" : "Try a different search or filter")
                    )
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button { attemptAdd() } label: {
                Label("Add Subscription", systemImage: "plus")
            }
        }
        ToolbarItem(placement: .secondaryAction) {
            Menu {
                Picker("Sort", selection: $sortOption) {
                    ForEach(SubscriptionSortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                Picker("Status", selection: $filterActive) {
                    Text("Active").tag(true)
                    Text("Inactive").tag(false)
                }
                Menu("Category") {
                    Button("All Categories") { selectedCategory = nil }
                    ForEach(Category.allCases, id: \.self) { category in
                        Button(category.rawValue) { selectedCategory = category }
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
    }

    private func attemptAdd() {
        if featureGate.canAddSubscription(totalCount: allSubscriptions.count) {
            showingAddSubscription = true
        } else {
            showingLimit = true
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
                HStack(spacing: 6) {
                    Text(subscription.name).font(.headline)
                    if subscription.isTrial {
                        Text("Trial")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .cornerRadius(4)
                    }
                }
                Text(subscription.nextPaymentDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(CurrencyFormatter.format(subscription.price, currencyCode: subscription.currency))
                    .font(.subheadline.weight(.medium))
                Text(subscription.billingCycle.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AllSubscriptionsView()
        .modelContainer(for: Subscription.self, inMemory: true)
        .environmentObject(FeatureGate(storeManager: StoreManager.shared))
}
