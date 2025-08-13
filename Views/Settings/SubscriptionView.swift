//
//  SubscriptionView.swift
//  AURZA
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject var purchaseService: PurchaseService
    @StateObject private var viewModel: PaywallViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: PaywallViewModel(purchaseService: PurchaseService()))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if purchaseService.isPro {
                    // Current subscription status
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text(NSLocalizedString("pro_active", comment: ""))
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(NSLocalizedString("pro_active_description", comment: ""))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            await viewModel.restore()
                        }
                    }) {
                        Text(NSLocalizedString("restore_purchases", comment: ""))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                } else {
                    // Purchase options
                    VStack(spacing: 16) {
                        Text(NSLocalizedString("choose_plan", comment: ""))
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        // Monthly subscription
                        if let monthly = viewModel.monthlyProduct {
                            PurchaseButton(
                                product: monthly,
                                isLoading: viewModel.isLoading,
                                onPurchase: {
                                    Task {
                                        await viewModel.purchase(monthly)
                                    }
                                }
                            )
                        }
                        
                        // Lifetime purchase
                        if let lifetime = viewModel.lifetimeProduct {
                            PurchaseButton(
                                product: lifetime,
                                isLoading: viewModel.isLoading,
                                isHighlighted: true,
                                onPurchase: {
                                    Task {
                                        await viewModel.purchase(lifetime)
                                    }
                                }
                            )
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.restore()
                            }
                        }) {
                            Text(NSLocalizedString("restore_purchases", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                
                // Features list
                VStack(alignment: .leading, spacing: 12) {
                    Text(NSLocalizedString("pro_features", comment: ""))
                        .font(.headline)
                    
                    ForEach(1...10, id: \.self) { index in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Text(NSLocalizedString("pro_feature_\(index)", comment: ""))
                                .font(.body)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(NSLocalizedString("subscription", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .alert(NSLocalizedString("error", comment: ""), isPresented: $viewModel.showingError) {
            Button(NSLocalizedString("ok", comment: ""), role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

struct PurchaseButton: View {
    let product: Product
    let isLoading: Bool
    var isHighlighted: Bool = false
    let onPurchase: () -> Void
    
    var body: some View {
        Button(action: onPurchase) {
            VStack(spacing: 8) {
                if isHighlighted {
                    Text(NSLocalizedString("best_value", comment: ""))
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.displayName)
                            .font(.headline)
                        
                        Text(product.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(product.displayPrice)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(isHighlighted ? Color.accentColor.opacity(0.1) : Color(UIColor.secondarySystemGroupedBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isHighlighted ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .cornerRadius(10)
        }
        .disabled(isLoading)
        .padding(.horizontal)
    }
}
