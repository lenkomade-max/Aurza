//
//  ContentView.swift
//  AURZA
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var localStore: LocalStore
    @EnvironmentObject var purchaseService: PurchaseService
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var soundService: SoundService
    @EnvironmentObject var hapticsService: HapticsService
    @EnvironmentObject var localizationService: LocalizationService
    @EnvironmentObject var onboardingService: OnboardingService
    @EnvironmentObject var appTheme: AppTheme
    
    @State private var selectedTab = 0
    @State private var showingOnboarding = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label(NSLocalizedString("today", comment: ""), systemImage: "calendar.day.timeline.left")
                }
                .tag(0)
            
            HabitsView()
                .tabItem {
                    Label(NSLocalizedString("habits", comment: ""), systemImage: "repeat")
                }
                .tag(1)
            
            GoalsView()
                .tabItem {
                    Label(NSLocalizedString("goals", comment: ""), systemImage: "target")
                }
                .tag(2)
            
            StatsView()
                .tabItem {
                    Label(NSLocalizedString("stats", comment: ""), systemImage: "chart.xyaxis.line")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label(NSLocalizedString("settings", comment: ""), systemImage: "gearshape")
                }
                .tag(4)
        }
        .accentColor(appTheme.accentColor)
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView(isPresented: $showingOnboarding)
                .environmentObject(onboardingService)
        }
        .onAppear {
            if !onboardingService.hasCompletedOnboarding {
                showingOnboarding = true
            }
        }
    }
}
