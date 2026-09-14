//
//  OnboardingView.swift
//  SubTracker
//

import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var currentPage = 0

    private let pages = OnboardingPage.pages

    var body: some View {
        ZStack {
            AmbientMeshBackground()

            VStack(spacing: 0) {
                OnboardingPageIndicator(count: pages.count, currentIndex: currentPage)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        ScrollView(showsIndicators: false) {
                            OnboardingPageView(page: page)
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                        }
                        .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.32), value: currentPage)

                VStack(spacing: 12) {
                    OnboardingPrimaryButton(
                        title: currentPage == pages.count - 1 ? "Start Tracking" : "Continue"
                    ) {
                        advance()
                    }

                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            onComplete()
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
                .padding(.top, 8)
            }
        }
    }

    private func advance() {
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.32)) {
                currentPage += 1
            }
        } else {
            onComplete()
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
