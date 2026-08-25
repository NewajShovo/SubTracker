//
//  ProBanner.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import SwiftUI

struct ProBanner: View {
    let title: String
    let message: String
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Button {
                onUpgrade()
            } label: {
                Text("Upgrade to Pro")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Subscription Limit Alert

struct SubscriptionLimitView: View {
    @Environment(\.dismiss) private var dismiss
    let currentCount: Int
    let onUpgrade: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                
                VStack(spacing: 12) {
                    Text("Subscription Limit Reached")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You've reached the free limit of \(FeatureManager.freeSubscriptionLimit) subscriptions. Upgrade to Pro for unlimited subscriptions and advanced features.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 16) {
                    Button {
                        dismiss()
                        onUpgrade()
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text("Upgrade to Pro")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview("Banner") {
    ProBanner(
        title: "Unlock Advanced Analytics",
        message: "Get deep insights into your spending patterns"
    ) {
        print("Upgrade tapped")
    }
    .padding()
}

#Preview("Limit View") {
    SubscriptionLimitView(currentCount: 5) {
        print("Upgrade tapped")
    }
}
