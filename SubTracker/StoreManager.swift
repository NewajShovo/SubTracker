//
//  StoreManager.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import Foundation
import StoreKit
import Combine

/// Product identifiers - Replace with your actual App Store Connect IDs
enum ProductIdentifier: String, CaseIterable {
    case monthlyPro = "com.shovo.subtracker.pro.monthly"
    case yearlyPro = "com.shovo.subtracker.pro.yearly"
    
    var displayName: String {
        switch self {
        case .monthlyPro:
            return "Monthly Pro"
        case .yearlyPro:
            return "Yearly Pro"
        }
    }
}

@MainActor
final class StoreManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isPro: Bool = false
    
    private var transactionListener: Task<Void, Error>?
    
    init() {
        // Start listening for transactions
        transactionListener = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        do {
            let productIdentifiers = ProductIdentifier.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIdentifiers)
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase
    
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
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    // MARK: - Update Purchased Products
    
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                purchasedIDs.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchasedIDs
        isPro = !purchasedIDs.isEmpty
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                await self.updatePurchasedProducts()
                await transaction.finish()
            }
        }
    }
    
    // MARK: - Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Helper Methods
    
    func product(for identifier: ProductIdentifier) -> Product? {
        products.first { $0.id == identifier.rawValue }
    }
    
    func isPurchased(_ product: Product) -> Bool {
        purchasedProductIDs.contains(product.id)
    }
    
    func subscriptionStatus(for product: Product) async -> Product.SubscriptionInfo.Status? {
        guard let subscription = product.subscription else {
            return nil
        }
        
        let statuses = try? await subscription.status
        return statuses?.first
    }
}

// MARK: - Store Error

enum StoreError: Error {
    case failedVerification
}

