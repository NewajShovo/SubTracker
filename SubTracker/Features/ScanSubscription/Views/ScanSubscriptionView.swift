//
//  ScanSubscriptionView.swift
//  SubTracker
//

import PhotosUI
import SwiftUI

struct ScanSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var featureGate: FeatureGate

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var phase: ScanPhase = .pick
    @State private var extracted: ExtractedSubscription?
    @State private var errorMessage: String?
    @State private var showingPaywall = false

    enum ScanPhase {
        case pick, scanning, review, error
    }

    var body: some View {
        NavigationStack {
            Group {
                switch phase {
                case .pick:
                    pickView
                case .scanning:
                    scanningView
                case .review:
                    if let extracted {
                        ScanReviewView(extracted: extracted) {
                            dismiss()
                        }
                    }
                case .error:
                    errorView
                }
            }
            .navigationTitle("Scan Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .onChange(of: selectedItem) { _, newItem in
                Task { await loadImage(from: newItem) }
            }
        }
    }

    private var pickView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "doc.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            Text("Scan a bill or screenshot")
                .font(.title2.bold())

            Text("We'll read the subscription details and let you confirm before saving.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Choose Photo", systemImage: "photo.on.rectangle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    private var scanningView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Reading subscription details…")
                .font(.headline)
            Text("This stays on your device.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text(errorMessage ?? "Something went wrong.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") {
                phase = .pick
                selectedImage = nil
                selectedItem = nil
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func loadImage(from item: PhotosPickerItem?) async {
        guard featureGate.hasScanSubscription() else {
            showingPaywall = true
            return
        }
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else {
            errorMessage = IntelligenceError.ocrFailed.errorDescription
            phase = .error
            return
        }
        selectedImage = image
        await process(image: image)
    }

    private func process(image: UIImage) async {
        phase = .scanning
        do {
            let text = try await VisionOCRService.recognizeText(from: image)
            let service = SubscriptionIntelligenceService()
            let result = try await service.extract(from: text)
            if let validated = ExtractedSubscriptionValidator.validate(result) {
                extracted = validated
                phase = .review
            } else {
                errorMessage = IntelligenceError.lowConfidence.errorDescription
                phase = .error
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            phase = .error
        }
    }
}
