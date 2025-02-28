//
//  LumeApp.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 24.02.2025.
//

import SwiftUI

@main
struct LumeApp: App {
    @StateObject private var appSettings = AppSettings()
    @State private var showOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainView()
                    .environmentObject(appSettings)
                    .preferredColorScheme(appSettings.colorScheme)
                
                if showOnboarding {
                    OnboardingView(showOnboarding: $showOnboarding)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // Show onboarding on first launch
                if !appSettings.hasCompletedOnboarding {
                    showOnboarding = true
                    appSettings.hasCompletedOnboarding = true
                }
            }
        }
    }
}
