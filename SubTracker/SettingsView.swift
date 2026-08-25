//
//  SettingsView.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @StateObject private var storeManager = StoreManager()
    @StateObject private var featureManager = FeatureManager.shared
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationStack {
            List {
                // Pro Status Section
                Section {
                    if storeManager.isPro {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pro Subscriber")
                                    .font(.headline)
                                
                                Text("Thank you for your support!")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        }
                    } else {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Upgrade to Pro")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    Text("Unlock all features")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Subscription")
                }
                
                // Account Section
                Section {
                    Button {
                        Task {
                            await storeManager.restorePurchases()
                        }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                } header: {
                    Text("Account")
                }
                
                // Support Section
                Section {
                    Link(destination: URL(string: "mailto:zihadulkabir206@gmail.com")!) {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                } header: {
                    Text("Support")
                }
                
                // App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
                
                // Debug Section (only in DEBUG builds)
                #if DEBUG
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Pro Status (Debug)")
                                .font(.subheadline)
                            Text("Toggle to test Pro features")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $featureManager.isPro)
                    }
                    
                    Button {
                        // Reset welcome screen
                        UserDefaults.standard.set(false, forKey: "hasSeenWelcome")
                        exit(0)
                    } label: {
                        Label("Reset Welcome Screen", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(.orange)
                    }
                } header: {
                    Text("🧪 Debug Tools")
                } footer: {
                    Text("These options only appear in debug builds and will be removed in production.")
                        .font(.caption2)
                }
                #endif
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

#Preview {
    SettingsView()
}
