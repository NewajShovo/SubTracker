//
//  SubscriptionDetailView.swift
//  SubTracker
//

import SwiftData
import SwiftUI

struct SubscriptionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allSubscriptions: [Subscription]

    let subscription: Subscription

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    private var daysUntilPayment: Int { subscription.daysUntilNextPayment }

    private var nextPaymentText: String {
        if daysUntilPayment < 0 { return "Overdue" }
        if daysUntilPayment == 0 { return "Today" }
        if daysUntilPayment == 1 { return "Tomorrow" }
        return "In \(daysUntilPayment) days"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                priceSection
                statusSection
                nextPaymentSection
                costBreakdownSection
                detailsSection
                actionsSection
                Spacer(minLength: 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            AddSubscriptionView(subscriptionToEdit: subscription)
        }
        .alert("Delete Subscription?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteSubscription() }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: subscription.iconName)
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: subscription.color))
                .frame(width: 100, height: 100)
                .background(Color(hex: subscription.color).opacity(0.1))
                .cornerRadius(20)
            Text(subscription.name).font(.title.bold())
            Text(subscription.category.rawValue).font(.subheadline).foregroundStyle(.secondary)
            if subscription.isTrial, let days = subscription.daysUntilTrialEnds {
                Label("Trial ends in \(max(days, 0)) day\(days == 1 ? "" : "s")", systemImage: "clock.badge.exclamationmark")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15))
                    .foregroundStyle(.orange)
                    .cornerRadius(8)
            }
        }
        .padding(.top, 32)
    }

    private var priceSection: some View {
        VStack(spacing: 12) {
            Text(CurrencyFormatter.format(subscription.price, currencyCode: subscription.currency))
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
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STATUS")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Toggle(isOn: Binding(
                get: { subscription.isActive },
                set: { newValue in toggleActive(newValue) }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscription.isActive ? "Active" : "Inactive")
                        .font(.headline)
                    Text(subscription.isActive ? "Included in spending and reminders" : "Paused — hidden from upcoming payments")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    private var nextPaymentSection: some View {
        sectionCard(title: "NEXT PAYMENT") {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscription.nextPaymentDate.formatted(date: .complete, time: .omitted))
                        .font(.headline)
                    Text(nextPaymentText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(CurrencyFormatter.format(subscription.price, currencyCode: subscription.currency))
                    .font(.title2.bold())
            }
            .padding()
        }
    }

    private var costBreakdownSection: some View {
        sectionCard(title: "COST BREAKDOWN") {
            VStack(spacing: 0) {
                CostBreakdownRow(period: "Weekly", amount: subscription.weeklyEquivalent, currency: subscription.currency)
                Divider()
                CostBreakdownRow(period: "Monthly", amount: subscription.monthlyEquivalent, currency: subscription.currency)
                Divider()
                CostBreakdownRow(period: "Yearly", amount: subscription.yearlyEquivalent, currency: subscription.currency, highlighted: true)
            }
        }
    }

    private var detailsSection: some View {
        sectionCard(title: "DETAILS") {
            VStack(spacing: 0) {
                if !subscription.paymentMethod.isEmpty {
                    DetailRow(icon: "creditcard.fill", label: "Payment Method", value: subscription.paymentMethod)
                    Divider().padding(.leading, 44)
                }
                DetailRow(icon: "bell.fill", label: "Reminder", value: "\(subscription.reminderDaysBefore) day\(subscription.reminderDaysBefore == 1 ? "" : "s") before")
                Divider().padding(.leading, 44)
                DetailRow(icon: "calendar.badge.plus", label: "Added", value: subscription.createdDate.formatted(date: .abbreviated, time: .omitted))
                if !subscription.notes.isEmpty {
                    Divider().padding(.leading, 44)
                    DetailRow(icon: "note.text", label: "Notes", value: subscription.notes)
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button { showingEditSheet = true } label: {
                Label("Edit Subscription", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            Button { markReviewed() } label: {
                Label("Mark as Reviewed", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .foregroundStyle(.primary)
                    .cornerRadius(12)
            }
            Button(role: .destructive) { showingDeleteAlert = true } label: {
                Label("Delete Subscription", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .foregroundStyle(.red)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    private func toggleActive(_ isActive: Bool) {
        Task {
            await SubscriptionService.setActive(subscription, isActive: isActive, in: modelContext, allSubscriptions: allSubscriptions)
        }
    }

    private func markReviewed() {
        subscription.lastReviewedDate = Date()
        try? modelContext.save()
    }

    private func deleteSubscription() {
        Task {
            let remaining = allSubscriptions.filter { $0.id != subscription.id }
            await SubscriptionService.delete(subscription, in: modelContext, remaining: remaining)
            dismiss()
        }
    }
}

struct CostBreakdownRow: View {
    let period: String
    let amount: Decimal
    let currency: String
    var highlighted: Bool = false

    var body: some View {
        HStack {
            Text(period).foregroundStyle(highlighted ? .primary : .secondary)
            Spacer()
            Text(CurrencyFormatter.format(amount, currencyCode: currency))
                .fontWeight(highlighted ? .semibold : .regular)
                .foregroundStyle(highlighted ? .primary : .secondary)
        }
        .padding()
        .background(highlighted ? Color.blue.opacity(0.08) : Color.clear)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon).font(.body).foregroundStyle(.secondary).frame(width: 20)
            VStack(alignment: .leading, spacing: 4) {
                Text(label).font(.subheadline).foregroundStyle(.secondary)
                Text(value).font(.body)
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
