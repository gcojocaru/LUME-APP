//
//  AppSettings.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

//
//  AppSettings.swift
//  Lume
//

import SwiftUI
import Combine

// App settings manager
class AppSettings: ObservableObject {
    // Settings keys
    private enum Keys {
        static let theme = "app.theme"
        static let saveOriginal = "app.saveOriginal"
        static let exportQuality = "app.exportQuality"
        static let hapticFeedback = "app.hapticFeedback"
        static let hasCompletedOnboarding = "app.hasCompletedOnboarding"
    }
    
    // Theme options
    enum AppThemeMode: String, CaseIterable, Identifiable {
        case dark = "Dark"
        case light = "Light"
        case system = "System"
        
        var id: String { self.rawValue }
    }
    
    // Quality options
    enum ExportQuality: Int, CaseIterable, Identifiable {
        case high = 100
        case medium = 80
        case low = 60
        
        var id: Int { self.rawValue }
        
        var label: String {
            switch self {
            case .high: return "High"
            case .medium: return "Medium"
            case .low: return "Low"
            }
        }
    }
    
    // Published properties
    @Published var themeMode: AppThemeMode {
        didSet {
            UserDefaults.standard.set(themeMode.rawValue, forKey: Keys.theme)
        }
    }
    
    @Published var saveOriginalWithEdit: Bool {
        didSet {
            UserDefaults.standard.set(saveOriginalWithEdit, forKey: Keys.saveOriginal)
        }
    }
    
    @Published var exportQuality: ExportQuality {
        didSet {
            UserDefaults.standard.set(exportQuality.rawValue, forKey: Keys.exportQuality)
        }
    }
    
    @Published var enableHapticFeedback: Bool {
        didSet {
            UserDefaults.standard.set(enableHapticFeedback, forKey: Keys.hapticFeedback)
        }
    }
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
        }
    }
    
    // Computed property for system appearance
    var colorScheme: ColorScheme? {
        switch themeMode {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return nil
        }
    }
    
    // Initialize with stored settings or defaults
    init() {
        // Theme
        let storedTheme = UserDefaults.standard.string(forKey: Keys.theme) ?? AppThemeMode.dark.rawValue
        self.themeMode = AppThemeMode(rawValue: storedTheme) ?? .dark
        
        // Save original
        self.saveOriginalWithEdit = UserDefaults.standard.bool(forKey: Keys.saveOriginal)
        
        // Export quality
        let storedQuality = UserDefaults.standard.integer(forKey: Keys.exportQuality)
        if storedQuality == 0 {
            // Default to high if not set
            self.exportQuality = .high
        } else {
            self.exportQuality = ExportQuality(rawValue: storedQuality) ?? .high
        }
        
        // Haptic feedback
        self.enableHapticFeedback = UserDefaults.standard.bool(forKey: Keys.hapticFeedback)
        if !UserDefaults.standard.contains(key: Keys.hapticFeedback) {
            // Default to true if not set
            self.enableHapticFeedback = true
        }
        
        // Onboarding status
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
    }
    
    // Trigger haptic feedback if enabled
    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard enableHapticFeedback else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// Helper extension for UserDefaults
extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
}
