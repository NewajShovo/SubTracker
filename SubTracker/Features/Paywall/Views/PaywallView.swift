//
//  PaywallView.swift
//  SubTracker
//

import StoreKit
import SwiftUI

enum PaywallMode {
    /// Shown from settings/feature gates. Dismissible.
    case upgrade
    /// Shown immediately after onboarding. Explicit free continuation only.
    case postOnboarding
}

struct PaywallView: View {
    var mode: PaywallMode = .upgrade
    var onFinished: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var storeManager: StoreManager

    @State private var billingCycle: PaywallPlanCycle = .yearly
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var appeared = false

    private let features: [PaywallFeature] = [
        PaywallFeature(icon: "infinity", title: "Unlimited subscriptions"),
        PaywallFeature(icon: "doc.viewfinder", title: "Scan a bill or screenshot"),
        PaywallFeature(icon: "bell.badge.fill", title: "Smart renewal alerts"),
        PaywallFeature(icon: "lightbulb.fill", title: "Spending insights"),
        PaywallFeature(icon: "chart.line.uptrend.xyaxis", title: "Advanced analytics"),
        PaywallFeature(icon: "square.stack.3d.up.fill", title: "Home Screen widgets")
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let isCompact = geometry.size.height < 740

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: isCompact ? 16 : 22) {
                            headerSection(isCompact: isCompact)
                            featuresSection(isCompact: isCompact)
                            pricingSection(isCompact: isCompact)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }

                    bottomBar(isCompact: isCompact)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                        .padding(.top, 8)
                        .background(.ultraThinMaterial)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .background {
                AmbientMeshBackground()
                    .ignoresSafeArea()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if mode == .upgrade {
                    ToolbarItem(placement: .cancellationAction) {
                        Button { finish() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 32, height: 32)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .accessibilityLabel("Close")
                    }
                }
            }
            .interactiveDismissDisabled(mode == .postOnboarding)
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                selectDefaultProduct()
                withAnimation(.easeOut(duration: 0.5)) {
                    appeared = true
                }
            }
            .onChange(of: billingCycle) { _, cycle in
                syncSelectedProduct(for: cycle)
            }
            .onChange(of: storeManager.products.count) { _, _ in
                syncSelectedProduct(for: billingCycle)
            }
            .onChange(of: storeManager.isPro) { _, isPro in
                if isPro { finish() }
            }
        }
    }

    // MARK: - Header

    private func headerSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 10 : 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B").opacity(0.25), Color(hex: "F97316").opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isCompact ? 56 : 72, height: isCompact ? 56 : 72)

                Image(systemName: "crown.fill")
                    .font(.system(size: isCompact ? 22 : 30, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FBBF24"), Color(hex: "F59E0B")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: 8) {
                Text("Unlock the Full Experience")
                    .font(.system(size: isCompact ? 24 : 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)

                Text("Enjoy unlimited tracking, scanning, and insights.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
    }

    // MARK: - Features

    private func featuresSection(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 10 : 14) {
            Text("Everything in Pro")
                .font(isCompact ? .subheadline.weight(.semibold) : .headline)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                spacing: 8
            ) {
                ForEach(features) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(BrandTheme.accent)
                        Text(feature.title)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color(hex: "F1F5F9"))
                    }
                }
            }
        }
        .padding(isCompact ? 12 : 16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .dark ? Color(hex: "1C1C1E") : .white)
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.35 : 0.06), radius: 16, y: 6)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 18)
    }

    // MARK: - Pricing

    private func pricingSection(isCompact: Bool) -> some View {
        VStack(spacing: 12) {
            Text("Choose your plan")
                .font(isCompact ? .subheadline.weight(.semibold) : .headline)

            BillingCycleToggle(
                selection: $billingCycle,
                savingsLabel: yearlySavingsLabel,
                isCompact: isCompact
            )

            if storeManager.isLoadingProducts && storeManager.products.isEmpty {
                ProgressView()
                    .padding(.vertical, 24)
            } else if storeManager.products.isEmpty {
                VStack(spacing: 10) {
                    Text("Couldn't load subscription options.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        Task { await storeManager.loadProducts() }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BrandTheme.accent)
                }
                .padding(.vertical, 16)
            } else {
                pricingCards(isCompact: isCompact)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 22)
    }

    @ViewBuilder
    private func pricingCards(isCompact: Bool) -> some View {
        let monthly = storeManager.product(for: .monthlyPro)
        let yearly = storeManager.product(for: .yearlyPro)

        HStack(alignment: .top, spacing: 12) {
            if let monthly {
                SubscriptionPlanView(
                    product: monthly,
                    isSelected: billingCycle == .monthly,
                    isPurchased: storeManager.isPurchased(monthly),
                    isRecommended: false,
                    isCompact: isCompact
                ) {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        billingCycle = .monthly
                    }
                }
            }

            if let yearly {
                SubscriptionPlanView(
                    product: yearly,
                    isSelected: billingCycle == .yearly,
                    isPurchased: storeManager.isPurchased(yearly),
                    isRecommended: true,
                    isCompact: isCompact
                ) {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        billingCycle = .yearly
                    }
                }
            }
        }
    }

    // MARK: - Bottom Bar

    private func bottomBar(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 8 : 12) {
            if let selectedProduct {
                PaywallButton(
                    title: storeManager.isPurchased(selectedProduct) ? "Subscribed" : "Unlock Premium",
                    isLoading: isPurchasing,
                    isDisabled: storeManager.isPurchased(selectedProduct) || isRestoring
                ) {
                    Task { await purchaseProduct(selectedProduct) }
                }
            }

            if mode == .postOnboarding {
                Button("Continue with Free") {
                    finish()
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .disabled(isPurchasing || isRestoring)
            }

            Button {
                Task { await restore() }
            } label: {
                HStack(spacing: 6) {
                    if isRestoring {
                        ProgressView().controlSize(.small)
                    }
                    Text("Restore Purchases")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(BrandTheme.accent)
            }
            .disabled(isPurchasing || isRestoring)

            HStack(spacing: 16) {
                Link("Terms", destination: BrandTheme.termsURL)
                Link("Privacy", destination: BrandTheme.privacyURL)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

    private func finish() {
        if mode == .postOnboarding {
            onFinished?()
        } else {
            onFinished?()
            dismiss()
        }
    }

    private func purchaseProduct(_ product: Product) async {
        guard !isPurchasing else { return }
        isPurchasing = true
        let outcome = await storeManager.purchase(product)
        isPurchasing = false

        switch outcome {
        case .success:
            finish()
        case .cancelled:
            break
        case .pending:
            presentAlert(title: "Purchase Pending", message: storeManager.lastErrorMessage ?? "Your purchase is pending approval.")
        case .failed:
            presentAlert(title: "Couldn't Complete Purchase", message: storeManager.lastErrorMessage ?? "Something went wrong. Please try again.")
        }
    }

    private func restore() async {
        guard !isRestoring else { return }
        isRestoring = true
        let restored = await storeManager.restorePurchases()
        isRestoring = false
        if restored {
            finish()
        } else {
            presentAlert(
                title: "Restore Purchases",
                message: storeManager.lastErrorMessage ?? "No active subscription was found."
            )
        }
    }

    private func presentAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }

    private var yearlySavingsLabel: String? {
        guard let percent = yearlySavingsPercent, percent > 0 else { return nil }
        return "Save \(percent)%"
    }

    private var yearlySavingsPercent: Int? {
        guard let monthly = storeManager.product(for: .monthlyPro),
              let yearly = storeManager.product(for: .yearlyPro),
              monthly.price > 0 else { return nil }

        let annualMonthly = monthly.price * 12
        guard annualMonthly > yearly.price else { return nil }

        let savings = (1 - (yearly.price / annualMonthly)) * 100
        return Int(NSDecimalNumber(decimal: savings).doubleValue.rounded())
    }

    private func selectDefaultProduct() {
        billingCycle = .yearly
        syncSelectedProduct(for: .yearly)
    }

    private func syncSelectedProduct(for cycle: PaywallPlanCycle) {
        switch cycle {
        case .monthly:
            selectedProduct = storeManager.product(for: .monthlyPro) ?? storeManager.products.first
        case .yearly:
            selectedProduct = storeManager.product(for: .yearlyPro) ?? storeManager.products.first
        }
    }
}

// MARK: - Feature Model

private struct PaywallFeature: Identifiable {
    var id: String { title }
    let icon: String
    let title: String
}

// MARK: - Billing Toggle

private struct BillingCycleToggle: View {
    @Binding var selection: PaywallPlanCycle
    let savingsLabel: String?
    let isCompact: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var toggleNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PaywallPlanCycle.allCases, id: \.self) { cycle in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        selection = cycle
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(cycle.title)
                            .font(isCompact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))

                        if cycle == .yearly, let savingsLabel {
                            Text(savingsLabel)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(selection == .yearly ? .white : BrandTheme.accent)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background {
                                    Capsule()
                                        .fill(selection == .yearly ? Color.white.opacity(0.22) : BrandTheme.accent.opacity(0.12))
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isCompact ? 9 : 11)
                    .foregroundStyle(selection == cycle ? .white : .secondary)
                    .background {
                        if selection == cycle {
                            Capsule()
                                .fill(BrandTheme.primaryGradient)
                                .matchedGeometryEffect(id: "billingToggle", in: toggleNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(colorScheme == .dark ? Color(hex: "1C1C1E") : Color(hex: "EEF2FF").opacity(0.9))
        )
        .overlay {
            Capsule()
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }
}

// MARK: - Legacy Pricing Card

struct PricingCard: View {
    let product: Product
    let isSelected: Bool
    let isPurchased: Bool
    let onSelect: () -> Void

    var body: some View {
        SubscriptionPlanView(
            product: product,
            isSelected: isSelected,
            isPurchased: isPurchased,
            isRecommended: PaywallPlanCycle(product: product) == .yearly,
            isCompact: false,
            onSelect: onSelect
        )
    }
}

#Preview {
    PaywallView()
        .environmentObject(StoreManager.shared)
}
