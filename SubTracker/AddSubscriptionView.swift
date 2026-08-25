//
//  AddSubscriptionView.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import SwiftUI
import SwiftData

struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var category: Category = .other
    @State private var price: String = ""
    @State private var currency: String = "USD"
    @State private var billingCycle: BillingCycle = .monthly
    @State private var nextPaymentDate: Date = Date()
    @State private var paymentMethod: String = ""
    @State private var reminderDaysBefore: Int = 3
    @State private var notes: String = ""
    @State private var iconName: String = "dollarsign.circle.fill"
    @State private var color: String = "#007AFF"
    
    @State private var showingPresets = false
    
    var subscriptionToEdit: Subscription?
    
    var isEditing: Bool {
        subscriptionToEdit != nil
    }
    
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
                    
                    Button {
                        showingPresets.toggle()
                    } label: {
                        Label("Choose from presets", systemImage: "sparkles")
                    }
                } header: {
                    Text("Subscription")
                }
                
                Section {
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.systemImageName)
                                .tag(cat)
                        }
                    }
                    
                    HStack {
                        Text(currencySymbol)
                            .foregroundStyle(.secondary)
                        
                        TextField("0.00", text: $price)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Billing Cycle", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Pricing")
                }
                
                Section {
                    DatePicker("Next Payment", selection: $nextPaymentDate, displayedComponents: .date)
                    
                    TextField("Payment Method", text: $paymentMethod)
                    
                    Stepper("Remind \(reminderDaysBefore) day\(reminderDaysBefore == 1 ? "" : "s") before", value: $reminderDaysBefore, in: 0...30)
                } header: {
                    Text("Payment Details")
                }
                
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }
                
                if let priceValue = Decimal(string: price), priceValue > 0 {
                    Section {
                        estimatedCostsView(price: priceValue)
                    } header: {
                        Text("Estimated Costs")
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Subscription" : "Add Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveSubscription()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingPresets) {
                PresetsListView { preset in
                    applyPreset(preset)
                    showingPresets = false
                }
            }
            .onAppear {
                if let subscription = subscriptionToEdit {
                    loadSubscription(subscription)
                }
            }
        }
    }
    
    private func estimatedCostsView(price: Decimal) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Monthly")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(monthlyEquivalent(price: price), format: .currency(code: currency))
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Yearly")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(yearlyEquivalent(price: price), format: .currency(code: currency))
                    .fontWeight(.medium)
            }
        }
    }
    
    private func monthlyEquivalent(price: Decimal) -> Decimal {
        switch billingCycle {
        case .weekly:
            return price * 52 / 12
        case .monthly:
            return price
        case .quarterly:
            return price / 3
        case .yearly:
            return price / 12
        }
    }
    
    private func yearlyEquivalent(price: Decimal) -> Decimal {
        switch billingCycle {
        case .weekly:
            return price * 52
        case .monthly:
            return price * 12
        case .quarterly:
            return price * 4
        case .yearly:
            return price
        }
    }
    
    private var currencySymbol: String {
        let locale = Locale(identifier: "en_US")
        return locale.currencySymbol ?? "$"
    }
    
    private var isValid: Bool {
        !name.isEmpty && Decimal(string: price) != nil && Decimal(string: price)! > 0
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
    }
    
    private func saveSubscription() {
        guard let priceValue = Decimal(string: price) else { return }
        
        if let subscription = subscriptionToEdit {
            // Edit existing
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
        } else {
            // Create new
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
                isActive: true,
                iconName: iconName,
                color: color
            )
            
            modelContext.insert(newSubscription)
        }
        
        dismiss()
    }
}

// MARK: - Presets List View

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
                            Text(preset.name)
                                .font(.headline)
                            
                            Text(preset.category.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if let suggestedPrice = preset.suggestedPrice {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(suggestedPrice, format: .currency(code: "USD"))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(preset.billingCycle.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
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
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    AddSubscriptionView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
