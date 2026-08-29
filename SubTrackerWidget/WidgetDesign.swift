//
//  WidgetDesign.swift
//  SubTrackerWidget
//

import SwiftUI

// MARK: - Brand Palette

enum WidgetDesign {
    static let brandGradient = LinearGradient(
        colors: [Color(hex: "#4F8CFF"), Color(hex: "#7C5CFF"), Color(hex: "#B44CFF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let spendGradient = LinearGradient(
        colors: [Color(hex: "#3B82F6"), Color(hex: "#6366F1")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let yearlyGradient = LinearGradient(
        colors: [Color(hex: "#7C5CFF"), Color(hex: "#A855F7"), Color(hex: "#EC4899")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentPurple = Color(hex: "#7C5CFF")
    static let accentBlue = Color(hex: "#4F8CFF")
    static let accentPink = Color(hex: "#EC4899")

    static func urgencyColor(for daysUntil: Int) -> Color {
        if daysUntil < 0 { return Color(hex: "#8E8E93") }
        if daysUntil == 0 { return Color(hex: "#FF3B30") }
        if daysUntil <= 3 { return Color(hex: "#FF9500") }
        if daysUntil <= 7 { return Color(hex: "#FFCC00") }
        return Color(hex: "#34C759")
    }

    static func urgencyLabel(for daysUntil: Int) -> String {
        if daysUntil < 0 { return "Overdue" }
        if daysUntil == 0 { return "Due today" }
        if daysUntil == 1 { return "Tomorrow" }
        return "In \(daysUntil) days"
    }

    static func shortUrgencyLabel(for daysUntil: Int) -> String {
        if daysUntil < 0 { return "Overdue" }
        if daysUntil == 0 { return "Today" }
        if daysUntil == 1 { return "1d" }
        return "\(daysUntil)d"
    }
}

// MARK: - Deep Links

enum WidgetLink {
    static let scheme = "subtracker"

    static var dashboard: URL { URL(string: "\(scheme)://dashboard")! }
    static var subscriptions: URL { URL(string: "\(scheme)://subscriptions")! }

    static func subscription(id: String) -> URL {
        URL(string: "\(scheme)://subscription/\(id)")!
    }
}

// MARK: - Color Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 122, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Reusable Components

struct WidgetBrandMark: View {
    var compact = false

    var body: some View {
        HStack(spacing: compact ? 4 : 6) {
            Image(systemName: "rectangle.stack.fill")
                .font(compact ? .caption2.weight(.bold) : .caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: compact ? 18 : 22, height: compact ? 18 : 22)
                .background(WidgetDesign.brandGradient)
                .clipShape(RoundedRectangle(cornerRadius: compact ? 5 : 6, style: .continuous))

            if !compact {
                Text("SubTracker")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
    }
}

struct WidgetSubscriptionIcon: View {
    let iconName: String
    let colorHex: String
    var size: CGFloat = 36

    var body: some View {
        let tint = Color(hex: colorHex)
        Image(systemName: iconName)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
    }
}

struct WidgetUrgencyBadge: View {
    let daysUntil: Int
    var compact = false

    private var color: Color { WidgetDesign.urgencyColor(for: daysUntil) }

    var body: some View {
        HStack(spacing: compact ? 3 : 5) {
            Circle()
                .fill(color)
                .frame(width: compact ? 5 : 6, height: compact ? 5 : 6)
            Text(compact ? WidgetDesign.shortUrgencyLabel(for: daysUntil) : WidgetDesign.urgencyLabel(for: daysUntil))
                .font(compact ? .caption2.weight(.medium) : .caption.weight(.medium))
                .foregroundStyle(color)
        }
    }
}

struct WidgetEmptyState: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(WidgetDesign.brandGradient)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WidgetBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    var style: BackgroundStyle = .standard

    enum BackgroundStyle {
        case standard
        case vibrant
    }

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [
                        Color(hex: "#1C1C1E"),
                        Color(hex: "#2C2C2E"),
                        Color(hex: "#1A1A2E").opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [
                        Color(hex: "#F8FAFF"),
                        Color(hex: "#F0F4FF"),
                        Color(hex: "#EDE9FE").opacity(0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            if style == .vibrant {
                Circle()
                    .fill(WidgetDesign.accentBlue.opacity(colorScheme == .dark ? 0.12 : 0.08))
                    .frame(width: 120, height: 120)
                    .offset(x: 60, y: -40)
                Circle()
                    .fill(WidgetDesign.accentPurple.opacity(colorScheme == .dark ? 0.1 : 0.06))
                    .frame(width: 80, height: 80)
                    .offset(x: -50, y: 50)
            }
        }
    }
}

struct WidgetSpendCard: View {
    let label: String
    let value: String
    let subtitle: String?
    var compact = false
    var gradient: LinearGradient = WidgetDesign.spendGradient

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 4 : 6) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            Text(value)
                .font(compact ? .title3.bold() : .title2.bold())
                .foregroundStyle(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(compact ? 10 : 12)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct WidgetUpcomingRow: View {
    let item: WidgetSubscriptionSnapshot
    var showDivider = true
    var compact = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: compact ? 8 : 10) {
                WidgetSubscriptionIcon(
                    iconName: item.iconName,
                    colorHex: item.colorHex,
                    size: compact ? 28 : 32
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(compact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))
                        .lineLimit(1)
                    WidgetUrgencyBadge(daysUntil: item.daysUntil, compact: true)
                }

                Spacer(minLength: 4)

                Text(item.price)
                    .font(compact ? .caption.weight(.bold) : .subheadline.weight(.bold))
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, compact ? 6 : 8)

            if showDivider {
                Divider().opacity(0.35)
            }
        }
    }
}
