//
//  PurchaseService.swift
//  AURZA
//

import Foundation
import StoreKit

@MainActor
class PurchaseService: ObservableObject {
    @Published var isPro: Bool = false
    @Published var hasTrialEnded: Bool = false
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    
    private let productIds = [
        "com.aurza.pro.monthly",
        "com.aurza.pro.lifetime"
    ]
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIds)
        } catch {
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
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func restore() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Restore failed: \(error)")
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
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if productIds.contains(transaction.productID) {
                    purchasedProductIDs.insert(transaction.productID)
                }
                
                await transaction.finish()
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        self.isPro = !purchasedProductIDs.isEmpty || isInTrialPeriod()
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            guard let self = self else { return }
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction listener error: \(error)")
                }
            }
        }
    }
    
    func checkSubscriptionStatus() async {
        await updatePurchasedProducts()
        checkTrialStatus()
    }
    
    func handleVerifiedTransaction(_ transaction: Transaction) async {
        if productIds.contains(transaction.productID) {
            purchasedProductIDs.insert(transaction.productID)
        }
        await updatePurchasedProducts()
    }
    
    private func isInTrialPeriod() -> Bool {
        let trialStartKey = "trialStartDate"
        
        if let trialStart = UserDefaults.standard.object(forKey: trialStartKey) as? Date {
            let daysSinceStart = Calendar.current.dateComponents([.day], from: trialStart, to: Date()).day ?? 0
            return daysSinceStart < 7
        } else {
            // First launch, start trial
            UserDefaults.standard.set(Date(), forKey: trialStartKey)
            return true
        }
    }
    
    private func checkTrialStatus() {
        let trialStartKey = "trialStartDate"
        
        if let trialStart = UserDefaults.standard.object(forKey: trialStartKey) as? Date {
            let daysSinceStart = Calendar.current.dateComponents([.day], from: trialStart, to: Date()).day ?? 0
            hasTrialEnded = daysSinceStart >= 7 && purchasedProductIDs.isEmpty
        }
    }
    
    var monthlyProduct: Product? {
        products.first { $0.id == "com.aurza.pro.monthly" }
    }
    
    var lifetimeProduct: Product? {
        products.first { $0.id == "com.aurza.pro.lifetime" }
    }
}

enum StoreError: Error {
    case failedVerification
}
