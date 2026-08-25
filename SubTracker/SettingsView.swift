//
//  SettingsView.swift
//  SubTracker
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var featureGate: FeatureGate
    @Query private var allSubscriptions: [Subscription]

    @State private var showingPaywall = false
    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    @State private var restoreMessage: String?
    @State private var iCloudSyncEnabled = SyncManager.isEnabled
    @State private var showingRestartAlert = false

    var body: some View {
        NavigationStack {
            List {
                proSection
                notificationsSection
                featuresSection
                supportSection
                aboutSection
                #if DEBUG
                debugSection
                #endif
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) { PaywallView() }
            .sheet(isPresented: $showingExportSheet) {
                if let exportURL {
                    ShareSheet(items: [exportURL])
                }
            }
            .alert("Restart Required", isPresented: $showingRestartAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please restart the app to apply iCloud sync changes.")
            }
        }
    }

    private var proSection: some View {
        Section("Subscription") {
            if storeManager.isPro {
                HStack {
                    Image(systemName: "crown.fill").foregroundStyle(.yellow)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pro Subscriber").font(.headline)
                        Text("Thank you for your support!").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                }
            } else {
                Button { showingPaywall = true } label: {
                    HStack {
                        Image(systemName: "crown.fill").foregroundStyle(.yellow)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Upgrade to Pro").font(.headline)
                            Text("Scan subscriptions, smart insights, and more").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.secondary)
                    }
                }
            }
            Button {
                Task {
                    let restored = await storeManager.restorePurchases()
                    restoreMessage = restored ? "Purchases restored." : (storeManager.lastErrorMessage ?? "No purchases found.")
                }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
            }
            if let restoreMessage {
                Text(restoreMessage).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Button {
                Task { _ = await NotificationScheduler.requestPermissionIfNeeded() }
            } label: {
                Label("Enable Reminders", systemImage: "bell.badge")
            }
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            } label: {
                Label("Open Notification Settings", systemImage: "gear")
            }
        }
    }

    private var featuresSection: some View {
        Section("Features") {
            if featureGate.hasExportFeature() {
                Menu {
                    Button("Export CSV") { export(format: .csv) }
                    Button("Export PDF") { export(format: .pdf) }
                } label: {
                    Label("Export Subscriptions", systemImage: "square.and.arrow.up")
                }
            } else {
                Button { showingPaywall = true } label: {
                    Label("Export Subscriptions (Pro)", systemImage: "square.and.arrow.up")
                }
            }

            if featureGate.hasICloudSync() {
                Toggle("iCloud Sync", isOn: $iCloudSyncEnabled)
                    .onChange(of: iCloudSyncEnabled) { _, newValue in
                        SyncManager.isEnabled = newValue
                        showingRestartAlert = true
                    }
            } else {
                Button { showingPaywall = true } label: {
                    Label("iCloud Sync (Pro)", systemImage: "icloud")
                }
            }
        }
    }

    private var supportSection: some View {
        Section("Support") {
            Link(destination: URL(string: "mailto:zihadulkabir206@gmail.com")!) {
                Label("Contact Support", systemImage: "envelope.fill")
            }
            Link(destination: URL(string: "https://example.com/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }
            Link(destination: URL(string: "https://example.com/terms")!) {
                Label("Terms of Service", systemImage: "doc.text.fill")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack { Text("Version"); Spacer(); Text("1.0.0").foregroundStyle(.secondary) }
            HStack { Text("Build"); Spacer(); Text("1").foregroundStyle(.secondary) }
        }
    }

    #if DEBUG
    private var debugSection: some View {
        Section("Debug") {
            HStack {
                Text("Pro Override")
                Spacer()
                Toggle("", isOn: Binding(
                    get: { featureGate.debugProOverride ?? storeManager.isPro },
                    set: { featureGate.debugProOverride = $0 }
                ))
            }
            Button {
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            } label: {
                Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
            }
        }
    }
    #endif

    private enum ExportFormat { case csv, pdf }

    private func export(format: ExportFormat) {
        let data: Data
        let filename: String
        switch format {
        case .csv:
            data = ExportService.csvData(from: allSubscriptions)
            filename = "subtracker-export.csv"
        case .pdf:
            data = ExportService.pdfData(from: allSubscriptions)
            filename = "subtracker-export.pdf"
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: url)
        exportURL = url
        showingExportSheet = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .environmentObject(StoreManager.shared)
        .environmentObject(FeatureGate(storeManager: StoreManager.shared))
}
