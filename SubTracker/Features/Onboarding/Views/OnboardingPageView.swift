//
//  OnboardingPageView.swift
//  SubTracker
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    @State private var textVisible = false

    var body: some View {
        VStack(spacing: 28) {
            OnboardingVisualView(kind: page.visual, accent: page.accent)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 220, maxHeight: 340)
                .padding(.horizontal, 8)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .opacity(textVisible ? 1 : 0)
                    .offset(y: textVisible ? 0 : 12)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .minimumScaleFactor(0.85)
                    .opacity(textVisible ? 1 : 0)
                    .offset(y: textVisible ? 0 : 10)
            }
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 20)
        .onAppear(perform: revealText)
        .onChange(of: page.id) { _, _ in
            textVisible = false
            revealText()
        }
    }

    private func revealText() {
        withAnimation(.easeOut(duration: 0.45).delay(0.08)) {
            textVisible = true
        }
    }
}
