//
//  OnboardingPageIndicator.swift
//  SubTracker
//

import SwiftUI

struct OnboardingPageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? BrandTheme.accent : Color.primary.opacity(0.12))
                    .frame(width: index == currentIndex ? 28 : 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentIndex + 1) of \(count)")
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: currentIndex)
    }
}
