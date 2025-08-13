//
//  SettingsViewModel.swift
//  AURZA
//

import Foundation
import SwiftUI
import LocalAuthentication

class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var showingExportSheet = false
    @Published var showingImportPicker = false
    @Published var showingResetConfirmation = false
    @Published var exportURL: URL?
    
    private let localStore: LocalStore
    private let purchaseService: PurchaseService
    private let notificationService: NotificationService
    private let soundService: SoundService
    private let hapticsService: HapticsService
    private let localizationService: LocalizationService
    private let exportImportService: ExportImportService
    private let onboardingService: OnboardingService
    
    init(
        localStore: LocalStore,
        purchaseService: PurchaseService,
        notificationService: NotificationService,
        soundService: SoundService,
        hapticsService: HapticsService,
        localizationService: LocalizationService,
        exportImportService: ExportImportService,
        onboardingService: OnboardingService
    ) {
        self.localStore = localStore
        self.purchaseService = purchaseService
        self.notificationService = notificationService
        self.soundService = soundService
        self.hapticsService = hapticsService
        self.localizationService = localizationService
        self.exportImportService = exportImportService
        self.onboardingService = onboardingService
        self.settings = localStore.settings
    }
    
    var isPro: Bool {
        purchaseService.isPro
    }
    
    var tags: [Tag] {
        localStore.tags
    }
    
    func updateTheme(_ theme: AppSettings.Theme) {
        settings.theme = theme
        localStore.settings = settings
    }
    
    func updateAccentColor(_ colorName: String) {
        settings.accentColorName = colorName
        localStore.settings = settings
    }
    
    func updateLanguage(_ language: String) {
        settings.language = language
        localizationService.currentLanguage = language
        localStore.settings = settings
    }
    
    func toggleSounds() {
        settings.soundsEnabled.toggle()
        soundService.isEnabled = settings.soundsEnabled
        localStore.settings = settings
    }
    
    func toggleHaptics() {
        settings.hapticsEnabled.toggle()
        hapticsService.isEnabled = settings.hapticsEnabled
        localStore.settings = settings
    }
    
    func toggleNotifications() {
        settings.notificationsEnabled.toggle()
        if settings.notificationsEnabled {
            notificationService.requestAuthorization()
        }
        localStore.settings = settings
    }
    
    func toggleDailyQuestion() {
        settings.dailyQuestionEnabled.toggle()
        if settings.dailyQuestionEnabled {
            notificationService.scheduleDailyQuestion(at: settings.dailyQuestionTime)
        } else {
            notificationService.removeDailyQuestion()
        }
        localStore.settings = settings
    }
    
    func updateDailyQuestionTime(_ time: Date) {
        settings.dailyQuestionTime = time
        if settings.dailyQuestionEnabled {
            notificationService.scheduleDailyQuestion(at: time)
        }
        localStore.settings = settings
    }
    
    func toggleCombinedView() {
        settings.combineDiaryAndNotes.toggle()
        localStore.settings = settings
    }
    
    func toggleAppLock() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            settings.appLockEnabled.toggle()
            localStore.settings = settings
        }
    }
    
    func toggleProductivityPulse() {
        settings.showProductivityPulse.toggle()
        localStore.settings = settings
    }
    
    func updateMoodTheme(_ theme: AppSettings.MoodTheme) {
        settings.selectedMoodTheme = theme
        localStore.settings = settings
    }
    
    func addTag(_ tag: Tag) {
        localStore.addTag(tag)
    }
    
    func updateTag(_ tag: Tag) {
        localStore.updateTag(tag)
    }
    
    func deleteTag(_ tag: Tag) {
        localStore.deleteTag(tag)
    }
    
    func exportData() {
        exportURL = exportImportService.exportData(store: localStore)
        if exportURL != nil {
            showingExportSheet = true
        }
    }
    
    func importData(from url: URL) {
        let success = exportImportService.importData(from: url, into: localStore)
        if success {
            settings = localStore.settings
        }
    }
    
    func resetAll() {
        // Clear all data
        localStore.tasks.removeAll()
        localStore.habits.removeAll()
        localStore.goals.removeAll()
        localStore.completions.removeAll()
        localStore.journalEntries.removeAll()
        localStore.notes.removeAll()
        localStore.xpLevel = XPLevel()
        localStore.streak = Streak()
        localStore.settings = AppSettings()
        settings = localStore.settings
        
        // Reset onboarding
        onboardingService.resetOnboarding()
    }
    
    func restartOnboarding() {
        onboardingService.resetOnboarding()
    }
}
