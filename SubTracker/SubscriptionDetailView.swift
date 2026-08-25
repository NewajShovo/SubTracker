//
//  SubscriptionDetailView.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let subscription: Subscription
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    private var daysUntilPayment: Int {
        subscription.daysUntilNextPayment
    }
    
    private var nextPaymentText: String {
        if daysUntilPayment < 0 {
            return "Overdue"
        } else if daysUntilPayment == 0 {
            return "Today"
        } else if daysUntilPayment == 1 {
            return "Tomorrow"
        } else {
            return "In \(daysUntilPayment) days"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: subscription.iconName)
                        .font(.system(size: 60))
                        .foregroundStyle(Color(hex: subscription.color))
                        .frame(width: 100, height: 100)
                        .background(Color(hex: subscription.color).opacity(0.1))
                        .cornerRadius(20)
                    
                    Text(subscription.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(subscription.category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 32)
                
                // Price Card
                VStack(spacing: 12) {
                    Text(subscription.price as NSDecimalNumber, formatter: currencyFormatter)
                        .font(.system(size: 48, weight: .bold))
                    
                    Text("per \(subscription.billingCycle.rawValue.lowercased())")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Next Payment
                VStack(alignment: .leading, spacing: 16) {
                    Text("NEXT PAYMENT")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subscription.nextPaymentDate.formatted(date: .complete, time: .omitted))
                                .font(.headline)
                            
                            Text(nextPaymentText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(subscription.price as NSDecimalNumber, formatter: currencyFormatter)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Cost Breakdown
                VStack(alignment: .leading, spacing: 16) {
                    Text("COST BREAKDOWN")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 0) {
                        CostBreakdownRow(
                            period: "Weekly",
                            amount: subscription.monthlyEquivalent / 4,
                            currency: subscription.currency
                        )
                        
                        Divider()
                        
                        CostBreakdownRow(
                            period: "Monthly",
                            amount: subscription.monthlyEquivalent,
                            currency: subscription.currency
                        )
                        
                        Divider()
                        
                        CostBreakdownRow(
                            period: "Yearly",
                            amount: subscription.yearlyEquivalent,
                            currency: subscription.currency,
                            highlighted: true
                        )
                    }
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Details
                VStack(alignment: .leading, spacing: 16) {
                    Text("DETAILS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 0) {
                        if !subscription.paymentMethod.isEmpty {
                            DetailRow(
                                icon: "creditcard.fill",
                                label: "Payment Method",
                                value: subscription.paymentMethod
                            )
                            
                            Divider()
                                .padding(.leading, 44)
                        }
                        
                        DetailRow(
                            icon: "bell.fill",
                            label: "Reminder",
                            value: "\(subscription.reminderDaysBefore) day\(subscription.reminderDaysBefore == 1 ? "" : "s") before"
                        )
                        
                        Divider()
                            .padding(.leading, 44)
                        
                        DetailRow(
                            icon: "calendar.badge.plus",
                            label: "Added",
                            value: subscription.createdDate.formatted(date: .abbreviated, time: .omitted)
                        )
                        
                        if !subscription.notes.isEmpty {
                            Divider()
                                .padding(.leading, 44)
                            
                            DetailRow(
                                icon: "note.text",
                                label: "Notes",
                                value: subscription.notes
                            )
                        }
                    }
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Actions
                VStack(spacing: 12) {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit Subscription", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Subscription", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .foregroundStyle(.red)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer(minLength: 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            AddSubscriptionView(subscriptionToEdit: subscription)
        }
        .alert("Delete Subscription?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSubscription()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = subscription.currency
        return formatter
    }
    
    private func deleteSubscription() {
        modelContext.delete(subscription)
        dismiss()
    }
}

// MARK: - Cost Breakdown Row

struct CostBreakdownRow: View {
    let period: String
    let amount: Decimal
    let currency: String
    var highlighted: Bool = false
    
    var body: some View {
        HStack {
            Text(period)
                .foregroundStyle(highlighted ? .primary : .secondary)
            
            Spacer()
            
            Text(amount as NSDecimalNumber, formatter: currencyFormatter)
                .fontWeight(highlighted ? .semibold : .regular)
                .foregroundStyle(highlighted ? .primary : .secondary)
        }
        .padding()
        .background(highlighted ? Color.blue.opacity(0.1) : Color.clear)
    }
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        SubscriptionDetailView(
            subscription: Subscription(
                name: "Netflix",
                category: .video,
                price: 15.99,
                billingCycle: .monthly,
                nextPaymentDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                paymentMethod: "Visa •••• 1234",
                iconName: "tv.fill",
                color: "#E50914"
            )
        )
    }
    .modelContainer(for: Subscription.self, inMemory: true)
}
