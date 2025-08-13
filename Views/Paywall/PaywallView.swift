//
//  PaywallView.swift
//  AURZA
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var purchaseService: PurchaseService
    @EnvironmentObject var localizationService: LocalizationService
    @StateObject private var viewModel: PaywallViewModel
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        _viewModel = StateObject(wrappedValue: PaywallViewModel(purchaseService: PurchaseService()))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.purple.opacity(0.3), .blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero section
                        VStack(spacing: 16) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                            
                            Text("AURZA PRO")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(NSLocalizedString("paywall_subtitle", comment: ""))
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // Features list
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(1...10, id: \.self) { index in
                                HStack(spacing: 16) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                    
                                    Text(NSLocalizedString("pro_feature_\(index)", comment: ""))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Pricing options
                        VStack(spacing: 12) {
                            // Monthly subscription
                            if let monthly = viewModel.monthlyProduct {
                                PaywallPriceCard(
                                    product: monthly,
                                    isPopular: false,
                                    isLoading: viewModel.isLoading
                                ) {
                                    Task {
                                        await viewModel.purchase(monthly)
                                        if viewModel.isPro {
                                            isPresented = false
                                        }
                                    }
                                }
                            }
                            
                            // Lifetime purchase
                            if let lifetime = viewModel.lifetimeProduct {
                                PaywallPriceCard(
                                    product: lifetime,
                                    isPopular: true,
                                    isLoading: viewModel.isLoading
                                ) {
                                    Task {
                                        await viewModel.purchase(lifetime)
                                        if viewModel.isPro {
                                            isPresented = false
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Footer buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                Task {
                                    await viewModel.restore()
                                    if viewModel.isPro {
                                        isPresented = false
                                    }
                                }
                            }) {
                                Text(NSLocalizedString("restore_purchases", comment: ""))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 20) {
                                Button(action: {}) {
                                    Text(NSLocalizedString("terms_of_service", comment: ""))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Button(action: {}) {
                                    Text(NSLocalizedString("privacy_policy", comment: ""))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarItems(
                trailing: Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            )
        }
        .alert(NSLocalizedString("error", comment: ""), isPresented: $viewModel.showingError) {
            Button(NSLocalizedString("ok", comment: ""), role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

struct PaywallPriceCard: View {
    let product: Product
    let isPopular: Bool
    let isLoading: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        Button(action: onPurchase) {
            VStack(spacing: 12) {
                if isPopular {
                    Text(NSLocalizedString("most_popular", comment: ""))
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                
                VStack(spacing: 8) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if isLoading {
                        ProgressView()
                            .padding(.vertical, 8)
                    } else {
                        Text(product.displayPrice)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if product.id.contains("monthly") {
                            Text(NSLocalizedString("per_month", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text(NSLocalizedString("one_time", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(isPopular ? Color.accentColor.opacity(0.1) : Color(UIColor.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isPopular ? Color.accentColor : Color.clear, lineWidth: 2)
                )
            }
        }
        .disabled(isLoading)
        .cornerRadius(12)
    }
}
