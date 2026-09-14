//
//  PaywallButton.swift
//  SubTracker
//

import SwiftUI

struct PaywallButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(buttonFill)
            }
            .foregroundStyle(.white)
            .shadow(color: BrandTheme.accent.opacity(isDisabled ? 0 : 0.35), radius: 12, y: 6)
        }
        .buttonStyle(ScalePressButtonStyle())
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
    }

    private var buttonFill: AnyShapeStyle {
        if isDisabled && !isLoading {
            AnyShapeStyle(Color.secondary.opacity(0.35))
        } else {
            AnyShapeStyle(BrandTheme.primaryGradient)
        }
    }
}
