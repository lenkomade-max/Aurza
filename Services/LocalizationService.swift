//
//  LocalizationService.swift
//  AURZA
//

import Foundation
import SwiftUI

class LocalizationService: ObservableObject {
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
            Bundle.setLanguage(currentLanguage)
        }
    }
    
    let availableLanguages = [
        "en": "English",
        "ru": "Русский",
        "az": "Azərbaycan",
        "es": "Español",
        "fr": "Français",
        "de": "Deutsch",
        "pt-BR": "Português (BR)",
        "tr": "Türkçe",
        "ar": "العربية",
        "zh-Hans": "简体中文"
    ]
    
    init() {
        if let saved = UserDefaults.standard.string(forKey: "selectedLanguage") {
            self.currentLanguage = saved
            Bundle.setLanguage(saved)
        } else {
            self.currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        }
    }
    
    func getMotivationalPhrase() -> String {
        let phrases = [
            NSLocalizedString("motivation_1", comment: ""),
            NSLocalizedString("motivation_2", comment: ""),
            NSLocalizedString("motivation_3", comment: ""),
            NSLocalizedString("motivation_4", comment: ""),
            NSLocalizedString("motivation_5", comment: ""),
            NSLocalizedString("motivation_6", comment: ""),
            NSLocalizedString("motivation_7", comment: ""),
            NSLocalizedString("motivation_8", comment: ""),
            NSLocalizedString("motivation_9", comment: ""),
            NSLocalizedString("motivation_10", comment: "")
        ]
        return phrases.randomElement() ?? phrases[0]
    }
}

// Extension to support dynamic language switching
extension Bundle {
    private static var bundleKey: UInt8 = 0
    
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private class AnyLanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &Bundle.bundleKey) as? String,
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
