//
//  AURZAApp.swift
//  AURZA
//
//  Personal planner with tasks, habits, goals, diary, notes, and gamification
//

import SwiftUI
import StoreKit

@main
struct AURZAApp: App {
    @StateObject private var localStore = LocalStore()
    @StateObject private var purchaseService = PurchaseService()
    @StateObject private var notificationService = NotificationService()
    @StateObject private var soundService = SoundService()
    @StateObject private var hapticsService = HapticsService()
    @StateObject private var localizationService = LocalizationService()
    @StateObject private var onboardingService = OnboardingService()
    @StateObject private var appTheme = AppTheme()
    
    @State private var showPaywall = false
    @State private var paywallTimer: Timer?
    
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localStore)
                .environmentObject(purchaseService)
                .environmentObject(notificationService)
                .environmentObject(soundService)
                .environmentObject(hapticsService)
                .environmentObject(localizationService)
                .environmentObject(onboardingService)
                .environmentObject(appTheme)
                .preferredColorScheme(appTheme.currentTheme.colorScheme)
                .accentColor(appTheme.accentColor)
                .sheet(isPresented: $showPaywall) {
                    PaywallView(isPresented: $showPaywall)
                        .environmentObject(purchaseService)
                        .environmentObject(localizationService)
                }
                .onAppear {
                    setupApp()
                }
                .task {
                    await observeTransactions()
                }
        }
    }
    
    private func setupApp() {
        notificationService.requestAuthorization()
        
        Task {
            await purchaseService.loadProducts()
            await purchaseService.checkSubscriptionStatus()
        }
        
        if !onboardingService.hasShownInitialPaywall && !purchaseService.isPro {
            let delay = Double.random(in: 120...180)
            paywallTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                if !purchaseService.isPro {
                    showPaywall = true
                    onboardingService.hasShownInitialPaywall = true
                }
            }
        }
        
        if purchaseService.hasTrialEnded && !purchaseService.isPro {
            showPaywall = true
        }
    }
    
    private func observeTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try await result.payloadValue
                await purchaseService.handleVerifiedTransaction(transaction)
                await transaction.finish()
            } catch {
                print("Transaction failed: \(error)")
            }
        }
    }
    
    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
