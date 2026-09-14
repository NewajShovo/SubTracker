//
//  OnboardingVisualView.swift
//  SubTracker
//

import SwiftUI

struct OnboardingVisualView: View {
    let kind: OnboardingPage.Visual
    let accent: Color

    @State private var animate = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                }
                .shadow(color: accent.opacity(0.18), radius: 24, y: 12)

            content
                .padding(20)
                .scaleEffect(animate ? 1 : 0.92)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 16)
        }
        .onAppear(perform: playEntrance)
        .onChange(of: kind) { _, _ in
            animate = false
            playEntrance()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch kind {
        case .spending:
            SpendingPreview(accent: accent, floating: animate)
        case .reminders:
            RemindersPreview(accent: accent, floating: animate)
        case .scan:
            ScanPreview(accent: accent, floating: animate)
        case .insights:
            InsightsPreview(accent: accent, floating: animate)
        }
    }

    private func playEntrance() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            animate = true
        }
    }
}

// MARK: - Spending

private struct SpendingPreview: View {
    let accent: Color
    let floating: Bool

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: 0.68)
                        .stroke(BrandTheme.primaryGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text("$84")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Text("this month")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 108, height: 108)
                .offset(y: floating ? 0 : 6)

                VStack(alignment: .leading, spacing: 8) {
                    MiniStat(title: "Yearly", value: "$1,008", color: BrandTheme.accentPurple)
                    MiniStat(title: "Active", value: "12", color: accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 8) {
                BrandChip(name: "Netflix", color: Color(hex: "E50914"))
                BrandChip(name: "Spotify", color: Color(hex: "1DB954"))
                BrandChip(name: "iCloud", color: Color(hex: "007AFF"))
            }
            .offset(y: floating ? 0 : 8)
        }
        .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: floating)
    }
}

private struct MiniStat: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct BrandChip: View {
    let name: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(name)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.background.opacity(0.7), in: Capsule())
    }
}

// MARK: - Reminders

private struct RemindersPreview: View {
    let accent: Color
    let floating: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.16))
                    .frame(width: 72, height: 72)
                    .scaleEffect(floating ? 1.08 : 0.96)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(accent)
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: 8) {
                ReminderRow(name: "Netflix", when: "Tomorrow", amount: "$17.99", color: Color(hex: "E50914"))
                ReminderRow(name: "iCloud+", when: "In 3 days", amount: "$2.99", color: Color(hex: "007AFF"))
                ReminderRow(name: "Spotify", when: "In 1 week", amount: "$10.99", color: Color(hex: "1DB954"))
            }
        }
        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: floating)
    }
}

private struct ReminderRow: View {
    let name: String
    let when: String
    let amount: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle().fill(color).frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.subheadline.weight(.semibold))
                Text(when).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Text(amount)
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Scan

private struct ScanPreview: View {
    let accent: Color
    let floating: Bool

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
                    .frame(height: 150)

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(accent.opacity(0.55), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                    .frame(width: 168, height: 112)
                    .scaleEffect(floating ? 1.03 : 0.97)

                VStack(spacing: 8) {
                    Image(systemName: "doc.viewfinder")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(accent)
                    Text("Netflix  ·  $17.99 / mo")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(BrandTheme.accent)
                Text("Details extracted instantly")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floating)
    }
}

// MARK: - Insights

private struct InsightsPreview: View {
    let accent: Color
    let floating: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom, spacing: 10) {
                InsightBar(height: 42, color: Color(hex: "93C5FD"))
                InsightBar(height: 68, color: Color(hex: "60A5FA"))
                InsightBar(height: 54, color: Color(hex: "818CF8"))
                InsightBar(height: 88, color: BrandTheme.accent)
                InsightBar(height: 62, color: Color(hex: "A78BFA"))
                InsightBar(height: 74, color: Color(hex: "C084FC"))
            }
            .frame(maxWidth: .infinity)
            .offset(y: floating ? 0 : 6)

            HStack(spacing: 10) {
                Label("Unused trial", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BrandTheme.amber)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(BrandTheme.amber.opacity(0.12), in: Capsule())

                Label("Save $24/mo", systemImage: "leaf.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(accent.opacity(0.12), in: Capsule())
            }
        }
        .animation(.easeInOut(duration: 2.1).repeatForever(autoreverses: true), value: floating)
    }
}

private struct InsightBar: View {
    let height: CGFloat
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(color)
            .frame(width: 22, height: height)
    }
}
