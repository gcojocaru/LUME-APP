//
//  AppTheme.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

import SwiftUI

// A sleek black and white color theme for the app
struct AppTheme {
    // Primary colors
    static let primary = Color.white
    static let accent = Color(white: 0.85)
    
    // Background colors
    static let background = Color.black
    static let secondaryBackground = Color(white: 0.12)
    static let cardBackground = Color(white: 0.18)
    
    // Text colors
    static let text = Color.white
    static let secondaryText = Color(white: 0.7)
    static let tertiaryText = Color(white: 0.5)
    
    // Gradients
    static let accentGradient = LinearGradient(
        colors: [Color.white, Color(white: 0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Adding primaryGradient to fix references
    static let primaryGradient = LinearGradient(
        colors: [Color.white, Color(white: 0.9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// Animation durations
struct AppAnimation {
    static let quick = 0.2
    static let standard = 0.3
    static let slow = 0.5
}

// Custom button styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
            )
            .foregroundColor(.black)
            .font(.headline)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: AppAnimation.quick), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 1)
            )
            .foregroundColor(.white)
            .font(.headline)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: AppAnimation.quick), value: configuration.isPressed)
    }
}

// Custom floating card style view modifier
struct FloatingCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.cardBackground)
            )
    }
}

extension View {
    func floatingCard() -> some View {
        self.modifier(FloatingCardStyle())
    }
}
