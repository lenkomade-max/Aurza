//
//  PaywallViewModel.swift
//  AURZA
//

import Foundation
import StoreKit

@MainActor
class PaywallViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingError = false
    
    private let purchaseService: PurchaseService
    
    init(purchaseService: PurchaseService) {
        self.purchaseService = purchaseService
    }
    
    var monthlyProduct: Product? {
        purchaseService.monthlyProduct
    }
    
    var lifetimeProduct: Product? {
        purchaseService.lifetimeProduct
    }
    
    var isPro: Bool {
        purchaseService.isPro
    }
    
    func purchase(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let transaction = try await purchaseService.purchase(product)
            if transaction != nil {
                // Purchase successful
                isLoading = false
            }
        } catch {
            errorMessage = NSLocalizedString("purchase_error", comment: "")
            showingError = true
            isLoading = false
        }
    }
    
    func restore() async {
        isLoading = true
        errorMessage = nil
        
        await purchaseService.restore()
        
        if !purchaseService.isPro {
            errorMessage = NSLocalizedString("restore_no_purchases", comment: "")
            showingError = true
        }
        
        isLoading = false
    }
}
