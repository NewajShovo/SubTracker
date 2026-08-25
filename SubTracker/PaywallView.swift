//
//  PaywallView.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeManager = StoreManager()
    
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .padding(.top, 32)
                            
                            Text("Unlock Pro")
                                .font(.system(size: 34, weight: .bold))
                            
                            Text("Get unlimited subscriptions and advanced features")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Features List
                        VStack(spacing: 16) {
                            FeatureRow(
                                icon: "infinity",
                                title: "Unlimited Subscriptions",
                                description: "Track as many subscriptions as you need"
                            )
                            
                            FeatureRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Advanced Analytics",
                                description: "Deep insights into your spending patterns"
                            )
                            
                            FeatureRow(
                                icon: "icloud.fill",
                                title: "iCloud Sync",
                                description: "Access your data across all your devices"
                            )
                            
                            FeatureRow(
                                icon: "square.stack.3d.up.fill",
                                title: "Multiple Widgets",
                                description: "Choose from various widget sizes and styles"
                            )
                            
                            FeatureRow(
                                icon: "bell.badge.fill",
                                title: "Smart Reminders",
                                description: "Never miss a payment with intelligent alerts"
                            )
                            
                            FeatureRow(
                                icon: "square.and.arrow.up.fill",
                                title: "Export Data",
                                description: "Export to CSV, PDF, or share reports"
                            )
                            
                            FeatureRow(
                                icon: "dollarsign.circle.fill",
                                title: "Multiple Currencies",
                                description: "Support for 150+ currencies worldwide"
                            )
                            
                            FeatureRow(
                                icon: "checkmark.seal.fill",
                                title: "Priority Support",
                                description: "Get help faster with priority email support"
                            )
                        }
                        .padding(.horizontal)
                        
                        // Pricing Cards
                        VStack(spacing: 16) {
                            if storeManager.products.isEmpty {
                                ProgressView()
                                    .padding()
                            } else {
                                ForEach(storeManager.products, id: \.id) { product in
                                    PricingCard(
                                        product: product,
                                        isSelected: selectedProduct?.id == product.id,
                                        isPurchased: storeManager.isPurchased(product)
                                    ) {
                                        selectedProduct = product
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Purchase Button
                        if let selectedProduct {
                            Button {
                                Task {
                                    await purchaseProduct(selectedProduct)
                                }
                            } label: {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Subscribe Now")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundStyle(.white)
                                .cornerRadius(16)
                            }
                            .disabled(isPurchasing || storeManager.isPurchased(selectedProduct))
                            .padding(.horizontal)
                        }
                        
                        // Restore Purchases
                        Button {
                            Task {
                                await storeManager.restorePurchases()
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Legal
                        VStack(spacing: 8) {
                            Text("Subscription auto-renews unless cancelled")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 16) {
                                Button("Terms of Service") {
                                    // Open terms
                                }
                                
                                Button("Privacy Policy") {
                                    // Open privacy
                                }
                            }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            // Select yearly by default (better value)
            if let yearlyProduct = storeManager.product(for: .yearlyPro) {
                selectedProduct = yearlyProduct
            } else if let firstProduct = storeManager.products.first {
                selectedProduct = firstProduct
            }
        }
    }
    
    // MARK: - Purchase Logic
    
    private func purchaseProduct(_ product: Product) async {
        isPurchasing = true
        
        do {
            if let transaction = try await storeManager.purchase(product) {
                // Success!
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isPurchasing = false
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Pricing Card

struct PricingCard: View {
    let product: Product
    let isSelected: Bool
    let isPurchased: Bool
    let onSelect: () -> Void
    
    private var isYearly: Bool {
        product.id.contains("yearly")
    }
    
    private var savingsText: String? {
        guard isYearly else { return nil }
        // Assuming monthly is ~$2/month
        return "Save 37%"
    }
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            VStack(spacing: 0) {
                // Badge for best value
                if isYearly {
                    Text("BEST VALUE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                        .offset(y: -8)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.displayName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text(product.displayPrice)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        if let period = product.subscription?.subscriptionPeriod {
                            Text("per \(period.unit.localizedDescription)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let savings = savingsText {
                            Text(savings)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Spacer()
                    
                    if isPurchased {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(isSelected ? .blue : .secondary)
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(isPurchased)
    }
}

// MARK: - Subscription Period Extension

extension Product.SubscriptionPeriod.Unit {
    var localizedDescription: String {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        @unknown default:
            return "period"
        }
    }
}

#Preview {
    PaywallView()
}
