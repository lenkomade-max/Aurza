//
//  OnboardingService.swift
//  AURZA
//

import Foundation

class OnboardingService: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var hasShownInitialPaywall: Bool {
        didSet {
            UserDefaults.standard.set(hasShownInitialPaywall, forKey: "hasShownInitialPaywall")
        }
    }
    
    @Published var hasSeenWeekStripHint: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenWeekStripHint, forKey: "hasSeenWeekStripHint")
        }
    }
    
    @Published var hasSeenAddButtonHint: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenAddButtonHint, forKey: "hasSeenAddButtonHint")
        }
    }
    
    @Published var hasSeenMiniHubHint: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenMiniHubHint, forKey: "hasSeenMiniHubHint")
        }
    }
    
    @Published var hasSeenCategoriesHint: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenCategoriesHint, forKey: "hasSeenCategoriesHint")
        }
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.hasShownInitialPaywall = UserDefaults.standard.bool(forKey: "hasShownInitialPaywall")
        self.hasSeenWeekStripHint = UserDefaults.standard.bool(forKey: "hasSeenWeekStripHint")
        self.hasSeenAddButtonHint = UserDefaults.standard.bool(forKey: "hasSeenAddButtonHint")
        self.hasSeenMiniHubHint = UserDefaults.standard.bool(forKey: "hasSeenMiniHubHint")
        self.hasSeenCategoriesHint = UserDefaults.standard.bool(forKey: "hasSeenCategoriesHint")
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        hasSeenWeekStripHint = false
        hasSeenAddButtonHint = false
        hasSeenMiniHubHint = false
        hasSeenCategoriesHint = false
    }
}
