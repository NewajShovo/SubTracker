//
//  OnboardingPrimaryButton.swift
//  SubTracker
//

import SwiftUI

struct OnboardingPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(BrandTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: BrandTheme.accent.opacity(0.32), radius: 14, y: 8)
        }
        .buttonStyle(ScalePressButtonStyle())
        .accessibilityLabel(title)
    }
}
