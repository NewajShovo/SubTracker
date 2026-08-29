//
//  OnboardingView.swift
//  SubTracker
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "chart.pie.fill",
            iconColor: .blue,
            title: "Know where your money goes.",
            description: "See monthly and yearly subscription spending at a glance."
        ),
        OnboardingPage(
            icon: "bell.badge.fill",
            iconColor: .orange,
            title: "Never miss a renewal.",
            description: "Get smart reminders before you're charged again."
        ),
        OnboardingPage(
            icon: "doc.viewfinder",
            iconColor: .purple,
            title: "Scan a subscription instead of typing it.",
            description: "Snap a screenshot and let SubTracker extract the details for you."
        ),
        OnboardingPage(
            icon: "lightbulb.fill",
            iconColor: .green,
            title: "Find opportunities to save.",
            description: "Review spending patterns and consider subscriptions worth revisiting."
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.08), Color.purple.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.25))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.top, 20)

                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 16) {
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation { currentPage += 1 }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentPage == pages.count - 1 ? "Start Tracking" : "Next")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                    }

                    if currentPage < pages.count - 1 {
                        Button("Skip") { completeOnboarding() }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 88))
                .foregroundStyle(page.iconColor)
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
