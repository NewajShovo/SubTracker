//
//  StoreManager.swift
//  SubTracker
//

import Combine
import Foundation
import StoreKit

enum ProductIdentifier: String, CaseIterable {
    case monthlyPro = "com.shovo.subtracker.pro.monthly"
    case yearlyPro = "com.shovo.subtracker.pro.yearly"

    var displayName: String {
        switch self {
        case .monthlyPro: return "Monthly Pro"
        case .yearlyPro: return "Yearly Pro"
        }
    }
}

@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isPro: Bool = false
    @Published private(set) var lastErrorMessage: String?

    private var transactionListener: Task<Void, Error>?

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            let productIdentifiers = ProductIdentifier.allCases.map(\.rawValue)
            products = try await Product.products(for: productIdentifiers)
                .sorted { $0.price < $1.price }
        } catch {
            lastErrorMessage = "Couldn't load subscription options. Please try again."
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
        case .userCancelled:
            return nil
        case .pending:
            lastErrorMessage = "Purchase is pending approval."
            return nil
        @unknown default:
            return nil
        }
    }

    func restorePurchases() async -> Bool {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            return isPro
        } catch {
            lastErrorMessage = "Restore couldn't be completed. Please try again."
            print("Failed to restore purchases: \(error)")
            return false
        }
    }

    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil {
                purchasedIDs.insert(transaction.productID)
            }
        }

        purchasedProductIDs = purchasedIDs
        isPro = !purchasedIDs.isEmpty
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await self?.updatePurchasedProducts()
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    func product(for identifier: ProductIdentifier) -> Product? {
        products.first { $0.id == identifier.rawValue }
    }

    func isPurchased(_ product: Product) -> Bool {
        purchasedProductIDs.contains(product.id)
    }
}

enum StoreError: Error, LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Purchase couldn't be verified."
        }
    }
}
