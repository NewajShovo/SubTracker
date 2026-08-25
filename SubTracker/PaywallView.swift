//
//  PaywallView.swift
//  SubTracker
//

import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeManager: StoreManager

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    outcomesSection
                    pricingSection
                    purchaseSection
                    footerSection
                }
                .padding(.bottom, 32)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }
            .alert("Purchase Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear { selectDefaultProduct() }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 52))
                .foregroundStyle(.yellow)
                .padding(.top, 24)
            Text("Stop paying for subscriptions you forgot about.")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text("SubTracker Pro helps you track, scan, and stay ahead of renewals.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var outcomesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            outcomeRow("infinity", "Unlimited subscriptions")
            outcomeRow("doc.viewfinder", "Scan a bill or screenshot")
            outcomeRow("bell.badge.fill", "Smart renewal alerts")
            outcomeRow("clock.badge.exclamationmark", "Trial expiration alerts")
            outcomeRow("lightbulb.fill", "Spending insights")
            outcomeRow("chart.line.uptrend.xyaxis", "Advanced analytics")
            outcomeRow("square.stack.3d.up.fill", "Home Screen widgets")
            outcomeRow("icloud.fill", "iCloud Sync")
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func outcomeRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text).font(.subheadline)
            Spacer()
            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(.green)
        }
    }

    private var pricingSection: some View {
        VStack(spacing: 12) {
            if storeManager.products.isEmpty {
                ProgressView().padding()
            } else {
                ForEach(storeManager.products, id: \.id) { product in
                    PricingCard(
                        product: product,
                        isSelected: selectedProduct?.id == product.id,
                        isPurchased: storeManager.isPurchased(product)
                    ) { selectedProduct = product }
                }
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var purchaseSection: some View {
        if let selectedProduct {
            Button {
                Task { await purchaseProduct(selectedProduct) }
            } label: {
                HStack {
                    if isPurchasing { ProgressView().tint(.white) }
                    else { Text(storeManager.isPurchased(selectedProduct) ? "Subscribed" : "Continue").fontWeight(.semibold) }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(14)
            }
            .disabled(isPurchasing || storeManager.isPurchased(selectedProduct))
            .padding(.horizontal)
        }
    }

    private var footerSection: some View {
        VStack(spacing: 10) {
            Text("Cancel anytime. Restore purchases if you've subscribed before.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                Task {
                    let restored = await storeManager.restorePurchases()
                    if restored { dismiss() }
                    else { errorMessage = storeManager.lastErrorMessage ?? "No purchases found."; showingError = true }
                }
            } label: {
                Text("Restore Purchases").font(.subheadline)
            }
        }
        .padding(.horizontal)
    }

    private func selectDefaultProduct() {
        if let yearly = storeManager.product(for: .yearlyPro) {
            selectedProduct = yearly
        } else {
            selectedProduct = storeManager.products.first
        }
    }

    private func purchaseProduct(_ product: Product) async {
        isPurchasing = true
        do {
            if try await storeManager.purchase(product) != nil {
                dismiss()
            }
        } catch {
            errorMessage = "Purchase couldn't be completed."
            showingError = true
        }
        isPurchasing = false
    }
}

struct PricingCard: View {
    let product: Product
    let isSelected: Bool
    let isPurchased: Bool
    let onSelect: () -> Void

    private var isYearly: Bool { product.id.contains("yearly") }

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(product.displayName).font(.headline)
                        if isYearly {
                            Text("1 week free")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.green.opacity(0.15))
                                .foregroundStyle(.green)
                                .cornerRadius(6)
                        }
                    }
                    Text(product.displayPrice).font(.title2.bold())
                    if let period = product.subscription?.subscriptionPeriod {
                        Text("per \(period.unit.localizedDescription)").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: isPurchased ? "checkmark.circle.fill" : (isSelected ? "largecircle.fill.circle" : "circle"))
                    .foregroundStyle(isPurchased ? .green : (isSelected ? .blue : .secondary))
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .disabled(isPurchased)
    }
}

extension Product.SubscriptionPeriod.Unit {
    var localizedDescription: String {
        switch self {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return "period"
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(StoreManager.shared)
}
