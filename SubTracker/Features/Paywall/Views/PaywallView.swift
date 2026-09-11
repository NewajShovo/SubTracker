//
//  PaywallView.swift
//  SubTracker
//

import StoreKit
import SwiftUI

// MARK: - Paywall View

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var storeManager: StoreManager

    @State private var billingCycle: PaywallPlanCycle = .yearly
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var appeared = false

    private let features: [PaywallFeature] = [
        PaywallFeature(icon: "infinity", title: "Unlimited subscriptions"),
        PaywallFeature(icon: "doc.viewfinder", title: "Scan a bill or screenshot"),
        PaywallFeature(icon: "bell.badge.fill", title: "Smart renewal alerts"),
        PaywallFeature(icon: "clock.badge.exclamationmark", title: "Trial expiration alerts"),
        PaywallFeature(icon: "lightbulb.fill", title: "Spending insights"),
        PaywallFeature(icon: "chart.line.uptrend.xyaxis", title: "Advanced analytics"),
        PaywallFeature(icon: "square.stack.3d.up.fill", title: "Home Screen widgets"),
        PaywallFeature(icon: "icloud.fill", title: "iCloud Sync")
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let metrics = PaywallLayoutMetrics(
                    height: geometry.size.height,
                    width: geometry.size.width
                )

                VStack(spacing: metrics.sectionSpacing) {
                    headerSection(metrics: metrics)
                    featuresSection(metrics: metrics)
                    pricingSection(metrics: metrics)

                    Spacer(minLength: 0)

                    bottomBar(metrics: metrics)
                }
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.top, metrics.topPadding)
                .padding(.bottom, metrics.bottomPadding)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            }
            .background {
                PaywallBackground()
                    .ignoresSafeArea()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
            }
            .alert("Purchase Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                selectDefaultProduct()
                withAnimation(.easeOut(duration: 0.55)) {
                    appeared = true
                }
            }
            .onChange(of: billingCycle) { _, cycle in
                syncSelectedProduct(for: cycle)
            }
        }
    }

    // MARK: - Header

    private func headerSection(metrics: PaywallLayoutMetrics) -> some View {
        VStack(spacing: metrics.headerSpacing) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "F59E0B").opacity(0.25), Color(hex: "F97316").opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: metrics.crownSize, height: metrics.crownSize)

                Image(systemName: "crown.fill")
                    .font(.system(size: metrics.crownIconSize, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FBBF24"), Color(hex: "F59E0B")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)

            VStack(spacing: metrics.isCompact ? 6 : 10) {
                Text("SubTracker Pro")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PaywallTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(PaywallTheme.accent.opacity(colorScheme == .dark ? 0.18 : 0.1), in: Capsule())

                Text("Stop paying for subscriptions you forgot about.")
                    .font(.system(size: metrics.titleSize, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .lineLimit(metrics.isCompact ? 3 : 4)
                    .minimumScaleFactor(0.85)

                if !metrics.isVeryCompact {
                    Text("SubTracker Pro helps you track, scan, and stay ahead of renewals.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
        }
    }

    // MARK: - Features

    private func featuresSection(metrics: PaywallLayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: metrics.featureSectionSpacing) {
            Text("Everything in Pro")
                .font(metrics.isCompact ? .subheadline.weight(.semibold) : .headline)
                .foregroundStyle(.primary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: metrics.featureGridSpacing),
                    GridItem(.flexible(), spacing: metrics.featureGridSpacing)
                ],
                spacing: metrics.featureGridSpacing
            ) {
                ForEach(features) { feature in
                    PaywallFeatureCell(feature: feature, metrics: metrics)
                }
            }
        }
        .padding(metrics.featureCardPadding)
        .background(featureCardBackground)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private var featureCardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(colorScheme == .dark ? Color(hex: "1C1C1E") : .white)
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.35 : 0.06), radius: 16, y: 6)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.05), lineWidth: 1)
            }
    }

    // MARK: - Pricing

    private func pricingSection(metrics: PaywallLayoutMetrics) -> some View {
        VStack(spacing: metrics.pricingSpacing) {
            VStack(spacing: metrics.isCompact ? 8 : 12) {
                Text("Choose your plan")
                    .font(metrics.isCompact ? .subheadline.weight(.semibold) : .headline)

                BillingCycleToggle(
                    selection: $billingCycle,
                    savingsLabel: yearlySavingsLabel,
                    metrics: metrics
                )
            }

            if storeManager.products.isEmpty {
                ProgressView()
                    .controlSize(metrics.isCompact ? .regular : .large)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, metrics.isCompact ? 16 : 24)
            } else {
                pricingCards(metrics: metrics)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 24)
    }

    @ViewBuilder
    private func pricingCards(metrics: PaywallLayoutMetrics) -> some View {
        let monthly = storeManager.product(for: .monthlyPro)
        let yearly = storeManager.product(for: .yearlyPro)

        HStack(alignment: .top, spacing: metrics.cardSpacing) {
            if let monthly {
                ModernPricingCard(
                    product: monthly,
                    cycle: .monthly,
                    isSelected: billingCycle == .monthly,
                    isPurchased: storeManager.isPurchased(monthly),
                    isRecommended: false,
                    metrics: metrics
                ) {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        billingCycle = .monthly
                    }
                }
            }

            if let yearly {
                ModernPricingCard(
                    product: yearly,
                    cycle: .yearly,
                    isSelected: billingCycle == .yearly,
                    isPurchased: storeManager.isPurchased(yearly),
                    isRecommended: true,
                    metrics: metrics
                ) {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        billingCycle = .yearly
                    }
                }
            }
        }
    }

    // MARK: - Bottom Bar

    private func bottomBar(metrics: PaywallLayoutMetrics) -> some View {
        VStack(spacing: metrics.isCompact ? 8 : 12) {
            if let selectedProduct {
                Button {
                    Task { await purchaseProduct(selectedProduct) }
                } label: {
                    HStack(spacing: 8) {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(storeManager.isPurchased(selectedProduct) ? "Subscribed" : "Continue with \(billingCycle.title)")
                                .font(metrics.isCompact ? .subheadline.weight(.semibold) : .headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, metrics.ctaVerticalPadding)
                    .background {
                        if storeManager.isPurchased(selectedProduct) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.secondary.opacity(0.35))
                        } else {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(PaywallTheme.primaryGradient)
                        }
                    }
                    .foregroundStyle(.white)
                    .shadow(color: PaywallTheme.accent.opacity(storeManager.isPurchased(selectedProduct) ? 0 : 0.35), radius: 12, y: 6)
                }
                .disabled(isPurchasing || storeManager.isPurchased(selectedProduct))
                .animation(.easeInOut(duration: 0.2), value: billingCycle)
            }

            VStack(spacing: metrics.isCompact ? 4 : 8) {
                Text("Cancel anytime. Restore purchases if you've subscribed before.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)

                Button {
                    Task {
                        let restored = await storeManager.restorePurchases()
                        if restored { dismiss() }
                        else {
                            errorMessage = storeManager.lastErrorMessage ?? "No purchases found."
                            showingError = true
                        }
                    }
                } label: {
                    Text("Restore Purchases")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(PaywallTheme.accent)
                }
            }
        }
    }

    // MARK: - Helpers

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

// MARK: - Layout Metrics

private struct PaywallLayoutMetrics {
    let isCompact: Bool
    let isVeryCompact: Bool

    let horizontalPadding: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    let sectionSpacing: CGFloat
    let headerSpacing: CGFloat
    let crownSize: CGFloat
    let crownIconSize: CGFloat
    let titleSize: CGFloat
    let featureSectionSpacing: CGFloat
    let featureGridSpacing: CGFloat
    let featureCardPadding: CGFloat
    let pricingSpacing: CGFloat
    let cardSpacing: CGFloat
    let ctaVerticalPadding: CGFloat

    init(height: CGFloat, width: CGFloat) {
        isVeryCompact = height < 650
        isCompact = height < 740

        horizontalPadding = 20
        topPadding = isVeryCompact ? 0 : (isCompact ? 4 : 8)
        bottomPadding = isVeryCompact ? 4 : (isCompact ? 8 : 16)
        sectionSpacing = isVeryCompact ? 8 : (isCompact ? 12 : 20)
        headerSpacing = isVeryCompact ? 6 : (isCompact ? 8 : 14)
        crownSize = isVeryCompact ? 44 : (isCompact ? 52 : 72)
        crownIconSize = isVeryCompact ? 18 : (isCompact ? 22 : 30)
        titleSize = isVeryCompact ? 20 : (isCompact ? 22 : 28)
        featureSectionSpacing = isVeryCompact ? 6 : (isCompact ? 8 : 14)
        featureGridSpacing = isVeryCompact ? 4 : (isCompact ? 6 : 10)
        featureCardPadding = isVeryCompact ? 10 : (isCompact ? 12 : 18)
        pricingSpacing = isVeryCompact ? 8 : (isCompact ? 12 : 16)
        cardSpacing = isVeryCompact ? 8 : (isCompact ? 10 : 14)
        ctaVerticalPadding = isVeryCompact ? 11 : (isCompact ? 13 : 16)
    }
}

// MARK: - Billing Cycle

private enum PaywallPlanCycle: CaseIterable {
    case monthly
    case yearly

    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

// MARK: - Feature Model

private struct PaywallFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
}

// MARK: - Theme

private enum PaywallTheme {
    static let accent = Color(hex: "6366F1")

    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "3B82F6"), Color(hex: "6366F1"), Color(hex: "8B5CF6")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var recommendedGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Background

private struct PaywallBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color(hex: "0A0A0B") : Color(hex: "F8FAFC"))
                .ignoresSafeArea()

            Circle()
                .fill(Color(hex: "3B82F6").opacity(colorScheme == .dark ? 0.18 : 0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -120, y: -220)

            Circle()
                .fill(Color(hex: "8B5CF6").opacity(colorScheme == .dark ? 0.16 : 0.1))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: 140, y: -80)

            Circle()
                .fill(Color(hex: "06B6D4").opacity(colorScheme == .dark ? 0.1 : 0.08))
                .frame(width: 240, height: 240)
                .blur(radius: 60)
                .offset(x: 40, y: 320)
        }
    }
}

// MARK: - Billing Toggle

private struct BillingCycleToggle: View {
    @Binding var selection: PaywallPlanCycle
    let savingsLabel: String?
    let metrics: PaywallLayoutMetrics
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
                            .font(metrics.isCompact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))

                        if cycle == .yearly, let savingsLabel {
                            Text(savingsLabel)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(selection == .yearly ? .white : PaywallTheme.accent)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background {
                                    Capsule()
                                        .fill(selection == .yearly ? Color.white.opacity(0.22) : PaywallTheme.accent.opacity(0.12))
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, metrics.isCompact ? 9 : 11)
                    .foregroundStyle(selection == cycle ? .white : .secondary)
                    .background {
                        if selection == cycle {
                            Capsule()
                                .fill(PaywallTheme.primaryGradient)
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

// MARK: - Feature Cell

private struct PaywallFeatureCell: View {
    let feature: PaywallFeature
    let metrics: PaywallLayoutMetrics
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: metrics.isCompact ? 6 : 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: metrics.isCompact ? 13 : 16, weight: .semibold))
                .foregroundStyle(PaywallTheme.accent)

            Text(feature.title)
                .font(metrics.isVeryCompact ? .system(size: 10) : (metrics.isCompact ? .caption2 : .caption))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, metrics.isCompact ? 8 : 10)
        .padding(.vertical, metrics.isCompact ? 7 : 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: metrics.isCompact ? 10 : 12, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color(hex: "F1F5F9"))
        }
    }
}

// MARK: - Pricing Card

private struct ModernPricingCard: View {
    let product: Product
    let cycle: PaywallPlanCycle
    let isSelected: Bool
    let isPurchased: Bool
    let isRecommended: Bool
    let metrics: PaywallLayoutMetrics
    let onSelect: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var isYearly: Bool { product.id.contains("yearly") }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: metrics.isCompact ? 8 : 12) {
                HStack {
                    if isRecommended {
                        Text("Recommended")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(PaywallTheme.recommendedGradient, in: Capsule())
                    }

                    Spacer()

                    if isPurchased {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(product.displayPrice)
                            .font(.system(size: metrics.isCompact ? 22 : 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)

                        if let period = product.subscription?.subscriptionPeriod {
                            Text("/ \(period.unit.localizedDescription)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if isYearly {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.caption2)
                        Text("1 week free")
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(Color(hex: "10B981"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "10B981").opacity(0.12), in: Capsule())
                }

                HStack {
                    Text(isSelected ? "Selected" : "Select")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(isSelected ? PaywallTheme.accent : .secondary)

                    Spacer()

                    Image(systemName: isPurchased ? "checkmark.circle.fill" : (isSelected ? "largecircle.fill.circle" : "circle"))
                        .font(.caption)
                        .foregroundStyle(isPurchased ? .green : (isSelected ? PaywallTheme.accent : .secondary))
                }
            }
            .padding(metrics.isCompact ? 12 : 16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(cardBackground)
            .overlay(cardBorder)
            .scaleEffect(isRecommended && isSelected ? 1.02 : 1)
            .shadow(
                color: isSelected ? PaywallTheme.accent.opacity(colorScheme == .dark ? 0.28 : 0.18) : .black.opacity(colorScheme == .dark ? 0.2 : 0.05),
                radius: isSelected ? 12 : 6,
                y: isSelected ? 6 : 3
            )
        }
        .buttonStyle(.plain)
        .disabled(isPurchased)
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: isSelected)
    }

    @ViewBuilder
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(colorScheme == .dark ? Color(hex: "1C1C1E") : .white)
    }

    @ViewBuilder
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(
                isSelected
                    ? AnyShapeStyle(PaywallTheme.recommendedGradient)
                    : AnyShapeStyle(Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.06)),
                lineWidth: isSelected ? 2 : 1
            )
    }
}

// MARK: - Legacy Pricing Card (kept for compatibility)

struct PricingCard: View {
    let product: Product
    let isSelected: Bool
    let isPurchased: Bool
    let onSelect: () -> Void

    private var cycle: PaywallPlanCycle {
        product.id.contains("yearly") ? .yearly : .monthly
    }

    var body: some View {
        ModernPricingCard(
            product: product,
            cycle: cycle,
            isSelected: isSelected,
            isPurchased: isPurchased,
            isRecommended: cycle == .yearly,
            metrics: PaywallLayoutMetrics(height: 800, width: 390)
        ) {
            onSelect()
        }
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
