//
//  SettingsView.swift
//  AURZA
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var localStore: LocalStore
    @EnvironmentObject var purchaseService: PurchaseService
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var soundService: SoundService
    @EnvironmentObject var hapticsService: HapticsService
    @EnvironmentObject var localizationService: LocalizationService
    @EnvironmentObject var onboardingService: OnboardingService
    @EnvironmentObject var appTheme: AppTheme
    
    @StateObject private var viewModel: SettingsViewModel
    @State private var showingSubscription = false
    @State private var showingTagsManagement = false
    @State private var showingImportPicker = false
    @State private var showingExportSheet = false
    @State private var showingResetAlert = false
    
    init() {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            localStore: LocalStore(),
            purchaseService: PurchaseService(),
            notificationService: NotificationService(),
            soundService: SoundService(),
            hapticsService: HapticsService(),
            localizationService: LocalizationService(),
            exportImportService: ExportImportService(),
            onboardingService: OnboardingService()
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Appearance
                Section(header: Text(NSLocalizedString("appearance", comment: ""))) {
                    Picker(NSLocalizedString("theme", comment: ""), selection: $viewModel.settings.theme) {
                        ForEach(AppSettings.Theme.allCases, id: \.self) { theme in
                            Text(theme.localizedName).tag(theme)
                        }
                    }
                    .onChange(of: viewModel.settings.theme) { newValue in
                        viewModel.updateTheme(newValue)
                        appTheme.currentTheme = newValue
                    }
                    
                    NavigationLink(destination: AccentColorPicker(selectedColor: $viewModel.settings.accentColorName)) {
                        HStack {
                            Text(NSLocalizedString("accent_color", comment: ""))
                            Spacer()
                            Circle()
                                .fill(appTheme.accentColor)
                                .frame(width: 24, height: 24)
                        }
                    }
                    
                    if viewModel.isPro {
                        Picker(NSLocalizedString("mood_theme", comment: ""), selection: $viewModel.settings.selectedMoodTheme) {
                            ForEach(AppSettings.MoodTheme.allCases, id: \.self) { theme in
                                Text(theme.localizedName).tag(theme)
                            }
                        }
                        .onChange(of: viewModel.settings.selectedMoodTheme) { newValue in
                            viewModel.updateMoodTheme(newValue)
                        }
                    }
                }
                
                // Language
                Section(header: Text(NSLocalizedString("language", comment: ""))) {
                    Picker(NSLocalizedString("app_language", comment: ""), selection: $viewModel.settings.language) {
                        ForEach(Array(localizationService.availableLanguages.keys), id: \.self) { code in
                            Text(localizationService.availableLanguages[code] ?? code).tag(code)
                        }
                    }
                    .onChange(of: viewModel.settings.language) { newValue in
                        viewModel.updateLanguage(newValue)
                    }
                }
                
                // Notifications & Sounds
                Section(header: Text(NSLocalizedString("notifications_sounds", comment: ""))) {
                    Toggle(NSLocalizedString("notifications", comment: ""), isOn: $viewModel.settings.notificationsEnabled)
                        .onChange(of: viewModel.settings.notificationsEnabled) { _ in
                            viewModel.toggleNotifications()
                        }
                    
                    Toggle(NSLocalizedString("sounds", comment: ""), isOn: $viewModel.settings.soundsEnabled)
                        .onChange(of: viewModel.settings.soundsEnabled) { _ in
                            viewModel.toggleSounds()
                        }
                    
                    Toggle(NSLocalizedString("haptics", comment: ""), isOn: $viewModel.settings.hapticsEnabled)
                        .onChange(of: viewModel.settings.hapticsEnabled) { _ in
                            viewModel.toggleHaptics()
                        }
                    
                    Toggle(NSLocalizedString("daily_question", comment: ""), isOn: $viewModel.settings.dailyQuestionEnabled)
                        .onChange(of: viewModel.settings.dailyQuestionEnabled) { _ in
                            viewModel.toggleDailyQuestion()
                        }
                    
                    if viewModel.settings.dailyQuestionEnabled {
                        DatePicker(NSLocalizedString("question_time", comment: ""),
                                 selection: $viewModel.settings.dailyQuestionTime,
                                 displayedComponents: .hourAndMinute)
                            .onChange(of: viewModel.settings.dailyQuestionTime) { newValue in
                                viewModel.updateDailyQuestionTime(newValue)
                            }
                    }
                }
                
                // Tags
                Section(header: Text(NSLocalizedString("tags", comment: ""))) {
                    NavigationLink(destination: TagsManagementView()) {
                        HStack {
                            Text(NSLocalizedString("manage_tags", comment: ""))
                            Spacer()
                            Text("\(viewModel.tags.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Subscription
                Section(header: Text(NSLocalizedString("subscription", comment: ""))) {
                    NavigationLink(destination: SubscriptionView()) {
                        HStack {
                            Text(NSLocalizedString("manage_subscription", comment: ""))
                            Spacer()
                            if viewModel.isPro {
                                Text("PRO")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.yellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                // Mini Hub
                Section(header: Text(NSLocalizedString("mini_hub", comment: ""))) {
                    Toggle(NSLocalizedString("combine_diary_notes", comment: ""), isOn: $viewModel.settings.combineDiaryAndNotes)
                        .onChange(of: viewModel.settings.combineDiaryAndNotes) { _ in
                            viewModel.toggleCombinedView()
                        }
                    
                    Toggle(NSLocalizedString("app_lock", comment: ""), isOn: $viewModel.settings.appLockEnabled)
                        .onChange(of: viewModel.settings.appLockEnabled) { _ in
                            viewModel.toggleAppLock()
                        }
                }
                
                // Productivity
                Section(header: Text(NSLocalizedString("productivity", comment: ""))) {
                    Toggle(NSLocalizedString("show_productivity_pulse", comment: ""), isOn: $viewModel.settings.showProductivityPulse)
                        .onChange(of: viewModel.settings.showProductivityPulse) { _ in
                            viewModel.toggleProductivityPulse()
                        }
                }
                
                // Data
                Section(header: Text(NSLocalizedString("data", comment: ""))) {
                    Button(action: { viewModel.exportData() }) {
                        Label(NSLocalizedString("export_data", comment: ""), systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: { showingImportPicker = true }) {
                        Label(NSLocalizedString("import_data", comment: ""), systemImage: "square.and.arrow.down")
                    }
                    
                    Button(action: { showingResetAlert = true }) {
                        Label(NSLocalizedString("reset_all", comment: ""), systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // Help
                Section(header: Text(NSLocalizedString("help", comment: ""))) {
                    Button(action: { viewModel.restartOnboarding() }) {
                        Label(NSLocalizedString("restart_onboarding", comment: ""), systemImage: "questionmark.circle")
                    }
                }
            }
            .navigationTitle(NSLocalizedString("settings", comment: ""))
            .sheet(isPresented: $viewModel.showingExportSheet) {
                if let url = viewModel.exportURL {
                    ShareSheet(items: [url])
                }
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        viewModel.importData(from: url)
                    }
                case .failure(let error):
                    print("Import error: \(error)")
                }
            }
            .alert(NSLocalizedString("reset_confirmation", comment: ""), isPresented: $showingResetAlert) {
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) { }
                Button(NSLocalizedString("reset", comment: ""), role: .destructive) {
                    viewModel.resetAll()
                }
            } message: {
                Text(NSLocalizedString("reset_warning", comment: ""))
            }
        }
    }
}

struct AccentColorPicker: View {
    @Binding var selectedColor: String
    @EnvironmentObject var appTheme: AppTheme
    
    let colors: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("purple", .purple),
        ("pink", .pink),
        ("red", .red),
        ("orange", .orange),
        ("yellow", .yellow),
        ("green", .green),
        ("teal", .teal)
    ]
    
    var body: some View {
        List {
            ForEach(colors, id: \.name) { item in
                HStack {
                    Circle()
                        .fill(item.color)
                        .frame(width: 30, height: 30)
                    
                    Text(item.name.capitalized)
                    
                    Spacer()
                    
                    if selectedColor == item.name {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedColor = item.name
                    appTheme.accentColorName = item.name
                }
            }
        }
        .navigationTitle(NSLocalizedString("accent_color", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
