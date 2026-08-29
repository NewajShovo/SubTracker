//
//  AddSubscriptionView.swift
//  SubTracker
//

import SwiftData
import SwiftUI

struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var featureGate: FeatureGate
    @Query private var allSubscriptions: [Subscription]

    @State private var name = ""
    @State private var category: Category = .other
    @State private var price = ""
    @State private var currency = "USD"
    @State private var billingCycle: BillingCycle = .monthly
    @State private var nextPaymentDate = Date()
    @State private var paymentMethod = ""
    @State private var reminderDaysBefore = 3
    @State private var notes = ""
    @State private var iconName = "dollarsign.circle.fill"
    @State private var color = "#007AFF"
    @State private var isTrial = false
    @State private var trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    @State private var showingPresets = false
    @State private var showingLimit = false
    @State private var showingPaywall = false
    @State private var requestNotificationPermission = false

    var subscriptionToEdit: Subscription?
    var prefill: ExtractedSubscription?

    private var isEditing: Bool { subscriptionToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: iconName)
                            .font(.title)
                            .foregroundStyle(Color(hex: color))
                            .frame(width: 44, height: 44)
                        TextField("Name", text: $name)
                            .font(.headline)
                    }
                    Button { showingPresets = true } label: {
                        Label("Choose from presets", systemImage: "sparkles")
                    }
                } header: { Text("Subscription") }

                Section {
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.systemImageName).tag(cat)
                        }
                    }
                    HStack {
                        Text(CurrencyFormatter.symbol(for: currency))
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $price)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    if featureGate.hasMultipleCurrencies() || isEditing {
                        Picker("Currency", selection: $currency) {
                            ForEach(AppCurrency.allCases) { c in
                                Text(c.rawValue).tag(c.rawValue)
                            }
                        }
                    }
                    Picker("Billing Cycle", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: { Text("Pricing") }

                Section {
                    DatePicker("Next Payment", selection: $nextPaymentDate, displayedComponents: .date)
                    TextField("Payment Method", text: $paymentMethod)
                    Stepper("Remind \(reminderDaysBefore) day\(reminderDaysBefore == 1 ? "" : "s") before", value: $reminderDaysBefore, in: 0...30)
                } header: { Text("Payment Details") }

                Section {
                    Toggle("Free trial", isOn: $isTrial)
                    if isTrial {
                        DatePicker("Trial ends", selection: $trialEndDate, displayedComponents: .date)
                    }
                } header: { Text("Trial") }

                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: { Text("Notes") }

                if let priceValue = Decimal(string: price.replacingOccurrences(of: ",", with: ".")), priceValue > 0 {
                    Section {
                        estimatedCostsView(price: priceValue)
                    } header: { Text("Estimated Costs") }
                }
            }
            .navigationTitle(isEditing ? "Edit Subscription" : "Add Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") { saveSubscription() }
                        .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingPresets) {
                PresetsListView { preset in
                    applyPreset(preset)
                    showingPresets = false
                }
            }
            .sheet(isPresented: $showingLimit) {
                SubscriptionLimitView(currentCount: allSubscriptions.count) { showingPaywall = true }
            }
            .sheet(isPresented: $showingPaywall) { PaywallView() }
            .onAppear {
                if let subscription = subscriptionToEdit {
                    loadSubscription(subscription)
                } else if let prefill {
                    loadPrefill(prefill)
                }
            }
        }
    }

    private func estimatedCostsView(price: Decimal) -> some View {
        let sub = Subscription(name: name, price: price, currency: currency, billingCycle: billingCycle, nextPaymentDate: nextPaymentDate)
        return VStack(spacing: 12) {
            HStack {
                Text("Monthly").foregroundStyle(.secondary)
                Spacer()
                Text(CurrencyFormatter.format(sub.monthlyEquivalent, currencyCode: currency)).fontWeight(.medium)
            }
            HStack {
                Text("Yearly").foregroundStyle(.secondary)
                Spacer()
                Text(CurrencyFormatter.format(sub.yearlyEquivalent, currencyCode: currency)).fontWeight(.medium)
            }
        }
    }

    private var isValid: Bool {
        guard !name.isEmpty, let value = Decimal(string: price.replacingOccurrences(of: ",", with: ".")), value > 0 else { return false }
        return true
    }

    private func applyPreset(_ preset: SubscriptionPreset) {
        name = preset.name
        category = preset.category
        if let suggestedPrice = preset.suggestedPrice {
            price = "\(suggestedPrice)"
        }
        billingCycle = preset.billingCycle
        iconName = preset.iconName
        color = preset.color
    }

    private func loadSubscription(_ subscription: Subscription) {
        name = subscription.name
        category = subscription.category
        price = "\(subscription.price)"
        currency = subscription.currency
        billingCycle = subscription.billingCycle
        nextPaymentDate = subscription.nextPaymentDate
        paymentMethod = subscription.paymentMethod
        reminderDaysBefore = subscription.reminderDaysBefore
        notes = subscription.notes
        iconName = subscription.iconName
        color = subscription.color
        isTrial = subscription.isTrial
        trialEndDate = subscription.trialEndDate ?? Date()
    }

    private func loadPrefill(_ prefill: ExtractedSubscription) {
        name = prefill.name
        if let p = prefill.price { price = "\(p)" }
        currency = prefill.currency
        billingCycle = prefill.billingCycle ?? .monthly
        if let date = prefill.nextPaymentDate { nextPaymentDate = date }
        if let cat = prefill.category { category = cat }
        if let method = prefill.paymentMethod { paymentMethod = method }
        if let preset = SubscriptionPreset.preset(for: prefill.name) {
            iconName = preset.iconName
            color = preset.color
        }
    }

    private func saveSubscription() {
        guard let priceValue = Decimal(string: price.replacingOccurrences(of: ",", with: ".")) else { return }

        if !isEditing && !featureGate.canAddSubscription(totalCount: allSubscriptions.count) {
            showingLimit = true
            return
        }

        Task {
            if reminderDaysBefore > 0 {
                _ = await NotificationScheduler.requestPermissionIfNeeded()
            }

            if let subscription = subscriptionToEdit {
                subscription.name = name
                subscription.category = category
                subscription.price = priceValue
                subscription.currency = currency
                subscription.billingCycle = billingCycle
                subscription.nextPaymentDate = nextPaymentDate
                subscription.paymentMethod = paymentMethod
                subscription.reminderDaysBefore = reminderDaysBefore
                subscription.notes = notes
                subscription.iconName = iconName
                subscription.color = color
                subscription.isTrial = isTrial
                subscription.trialEndDate = isTrial ? trialEndDate : nil
                await SubscriptionService.save(subscription, in: modelContext, isNew: false, allSubscriptions: allSubscriptions)
            } else {
                let newSubscription = Subscription(
                    name: name,
                    category: category,
                    price: priceValue,
                    currency: currency,
                    billingCycle: billingCycle,
                    nextPaymentDate: nextPaymentDate,
                    paymentMethod: paymentMethod,
                    reminderDaysBefore: reminderDaysBefore,
                    notes: notes,
                    iconName: iconName,
                    color: color,
                    isTrial: isTrial,
                    trialEndDate: isTrial ? trialEndDate : nil,
                    source: .manual
                )
                await SubscriptionService.save(newSubscription, in: modelContext, isNew: true, allSubscriptions: allSubscriptions + [newSubscription])
            }
            dismiss()
        }
    }
}

struct PresetsListView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (SubscriptionPreset) -> Void

    var body: some View {
        NavigationStack {
            List(SubscriptionPreset.presets) { preset in
                Button {
                    onSelect(preset)
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: preset.iconName)
                            .font(.title2)
                            .foregroundStyle(Color(hex: preset.color))
                            .frame(width: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(preset.name).font(.headline)
                            Text(preset.category.rawValue).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let suggestedPrice = preset.suggestedPrice {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(CurrencyFormatter.format(suggestedPrice, currencyCode: "USD"))
                                    .font(.subheadline.weight(.medium))
                                Text(preset.billingCycle.rawValue).font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Choose Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddSubscriptionView()
        .modelContainer(for: Subscription.self, inMemory: true)
        .environmentObject(FeatureGate(storeManager: StoreManager.shared))
}
