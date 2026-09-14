//
//  SubscriptionPlanView.swift
//  SubTracker
//

import StoreKit
import SwiftUI

enum PaywallPlanCycle: CaseIterable {
    case monthly
    case yearly

    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }

    init(product: Product) {
        self = product.id.contains("yearly") ? .yearly : .monthly
    }
}

struct SubscriptionPlanView: View {
    let product: Product
    let isSelected: Bool
    let isPurchased: Bool
    let isRecommended: Bool
    let isCompact: Bool
    let onSelect: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: isCompact ? 8 : 12) {
                HStack {
                    if isRecommended {
                        Text("Best Value")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(BrandTheme.recommendedGradient, in: Capsule())
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
                            .font(.system(size: isCompact ? 22 : 28, weight: .bold, design: .rounded))
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

                if let intro = product.introductoryOfferLabel {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.caption2)
                        Text(intro)
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(BrandTheme.success)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(BrandTheme.success.opacity(0.12), in: Capsule())
                }

                HStack {
                    Text(isSelected ? "Selected" : "Select")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(isSelected ? BrandTheme.accent : .secondary)

                    Spacer()

                    Image(systemName: isPurchased ? "checkmark.circle.fill" : (isSelected ? "largecircle.fill.circle" : "circle"))
                        .font(.caption)
                        .foregroundStyle(isPurchased ? .green : (isSelected ? BrandTheme.accent : .secondary))
                }
            }
            .padding(isCompact ? 12 : 16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(colorScheme == .dark ? Color(hex: "1C1C1E") : .white)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        isSelected
                            ? AnyShapeStyle(BrandTheme.recommendedGradient)
                            : AnyShapeStyle(Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.06)),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .scaleEffect(isRecommended && isSelected ? 1.02 : 1)
            .shadow(
                color: isSelected ? BrandTheme.accent.opacity(colorScheme == .dark ? 0.28 : 0.18) : .black.opacity(colorScheme == .dark ? 0.2 : 0.05),
                radius: isSelected ? 12 : 6,
                y: isSelected ? 6 : 3
            )
        }
        .buttonStyle(.plain)
        .disabled(isPurchased)
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: isSelected)
    }
}

extension Product {
    var introductoryOfferLabel: String? {
        guard let offer = subscription?.introductoryOffer else { return nil }
        let count = offer.period.value
        let unitName: String
        switch offer.period.unit {
        case .day: unitName = count == 1 ? "day" : "days"
        case .week: unitName = count == 1 ? "week" : "weeks"
        case .month: unitName = count == 1 ? "month" : "months"
        case .year: unitName = count == 1 ? "year" : "years"
        @unknown default: unitName = "period"
        }

        let duration = "\(count) \(unitName)"
        switch offer.paymentMode {
        case .freeTrial:
            return "\(duration) free"
        case .payAsYouGo, .payUpFront:
            return "Intro offer"
        default:
            return "Intro offer"
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
