//
//  ScanReviewView.swift
//  SubTracker
//

import SwiftUI
import SwiftData

struct ScanReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var featureGate: FeatureGate
    @Query private var allSubscriptions: [Subscription]

    @State var extracted: ExtractedSubscription
    let onComplete: () -> Void

    @State private var showingPaywall = false
    @State private var showingLimit = false

    var body: some View {
        Form {
            Section {
                Text("Here's what we found")
                    .font(.headline)
                Text("Review and edit before adding.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Subscription") {
                TextField("Name", text: $extracted.name)
                Picker("Billing", selection: Binding(
                    get: { extracted.billingCycle ?? .monthly },
                    set: { extracted.billingCycle = $0 }
                )) {
                    ForEach(BillingCycle.allCases, id: \.self) { cycle in
                        Text(cycle.rawValue).tag(cycle)
                    }
                }
            }

            Section("Pricing") {
                TextField("Price", value: Binding(
                    get: { extracted.price ?? 0 },
                    set: { extracted.price = $0 }
                ), format: .number)
                .keyboardType(.decimalPad)

                Picker("Currency", selection: $extracted.currency) {
                    ForEach(AppCurrency.allCases) { currency in
                        Text("\(currency.rawValue) — \(currency.displayName)").tag(currency.rawValue)
                    }
                }
            }

            Section("Payment") {
                DatePicker("Next payment", selection: Binding(
                    get: { extracted.nextPaymentDate ?? Date() },
                    set: { extracted.nextPaymentDate = $0 }
                ), displayedComponents: .date)
            }

            Section {
                HStack {
                    Text("Confidence")
                    Spacer()
                    Text("\(Int(extracted.confidence * 100))%")
                        .foregroundStyle(extracted.confidence >= 0.75 ? .green : .orange)
                }
            }

            Section {
                Button {
                    addSubscription()
                } label: {
                    Label("Add Subscription", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .disabled(!extracted.isValid)
            }
        }
        .sheet(isPresented: $showingPaywall) { PaywallView() }
        .sheet(isPresented: $showingLimit) {
            SubscriptionLimitView(currentCount: allSubscriptions.count) {
                showingPaywall = true
            }
        }
    }

    private func addSubscription() {
        guard featureGate.canAddSubscription(totalCount: allSubscriptions.count) else {
            showingLimit = true
            return
        }
        guard let validated = ExtractedSubscriptionValidator.validate(extracted),
              let subscription = validated.toSubscription() else { return }

        Task {
            await SubscriptionService.save(
                subscription,
                in: modelContext,
                isNew: true,
                allSubscriptions: allSubscriptions
            )
            onComplete()
        }
    }
}
