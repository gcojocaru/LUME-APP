//
//  SettingsView.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

//
//  AppSettings.swift
//  Lume
//

//
//  SettingsView.swift
//  Lume
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Appearance section
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $appSettings.themeMode) {
                        ForEach(AppSettings.AppThemeMode.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Export section
                Section(header: Text("Export Options")) {
                    Picker("Export Quality", selection: $appSettings.exportQuality) {
                        ForEach(AppSettings.ExportQuality.allCases) { quality in
                            Text(quality.label).tag(quality)
                        }
                    }
                    
                    Toggle("Save Original with Edit", isOn: $appSettings.saveOriginalWithEdit)
                }
                
                // Interface section
                Section(header: Text("Interface")) {
                    Toggle("Haptic Feedback", isOn: $appSettings.enableHapticFeedback)
                }
                
                // About section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.appVersionLong)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Helper extension to get app version
extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var appVersionLong: String {
        return "\(appVersion) (\(buildNumber))"
    }
}
