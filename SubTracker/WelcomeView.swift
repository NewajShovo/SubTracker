//
//  WelcomeView.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import SwiftUI

/// Simple welcome screen that shows before the main app
struct WelcomeView: View {
    @Binding var isWelcomeComplete: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App icon/logo area
                VStack(spacing: 20) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                    
                    Text("SubTracker")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("Never forget a subscription")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Benefits
                VStack(alignment: .leading, spacing: 20) {
                    WelcomeFeature(
                        icon: "dollarsign.circle.fill",
                        text: "Track unlimited subscriptions"
                    )
                    
                    WelcomeFeature(
                        icon: "chart.bar.fill",
                        text: "See your spending at a glance"
                    )
                    
                    WelcomeFeature(
                        icon: "bell.badge.fill",
                        text: "Get reminded before renewals"
                    )
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Action button
                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        completeWelcome()
                    }
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeWelcome() {
        isWelcomeComplete = true
        UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
    }
}

// MARK: - Welcome Feature Row

struct WelcomeFeature: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.white)
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView(isWelcomeComplete: .constant(false))
}
