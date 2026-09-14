//
//  BrandTheme.swift
//  SubTracker
//

import SwiftUI

enum BrandTheme {
    static let accent = Color(hex: "6366F1")
    static let accentBlue = Color(hex: "4F8CFF")
    static let accentPurple = Color(hex: "7C5CFF")
    static let accentPink = Color(hex: "EC4899")
    static let amber = Color(hex: "F59E0B")
    static let success = Color(hex: "10B981")

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

    static let privacyURL = URL(string: "https://example.com/privacy")!
    static let termsURL = URL(string: "https://example.com/terms")!
}

struct AmbientMeshBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color(hex: "0A0A0B") : Color(hex: "F8FAFC"))
                .ignoresSafeArea()

            Circle()
                .fill(Color(hex: "3B82F6").opacity(colorScheme == .dark ? 0.22 : 0.16))
                .frame(width: 340, height: 340)
                .blur(radius: 80)
                .offset(x: -130, y: -240)

            Circle()
                .fill(Color(hex: "8B5CF6").opacity(colorScheme == .dark ? 0.2 : 0.14))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: 150, y: -60)

            Circle()
                .fill(Color(hex: "06B6D4").opacity(colorScheme == .dark ? 0.12 : 0.1))
                .frame(width: 260, height: 260)
                .blur(radius: 60)
                .offset(x: 20, y: 340)
        }
        .allowsHitTesting(false)
    }
}

struct ScalePressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
