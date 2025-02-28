//
//  OnboardingView.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

//
//  OnboardingView.swift
//  Lume
//

//
//  OnboardingView.swift
//  Lume
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    
    // Track the current page
    @State private var currentPage = 0
    
    // Onboarding content
    private let pages: [(image: String, title: String, description: String)] = [
        (
            image: "photo.filters",
            title: "Welcome to Lume",
            description: "Transform your photos with professional filters and adjustments in seconds."
        ),
        (
            image: "slider.horizontal.3",
            title: "Fine-tune Your Photos",
            description: "Adjust brightness, contrast, and more with precision controls."
        ),
        (
            image: "arrow.triangle.2.circlepath",
            title: "Experiment Freely",
            description: "Try different styles with our undo/redo feature to compare results."
        ),
        (
            image: "square.and.arrow.down",
            title: "Save & Share",
            description: "Export your creations in high quality and share them with the world."
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Content
            VStack(spacing: 30) {
                Spacer()
                
                // Image
                Image(systemName: pages[currentPage].image)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                // Title
                Text(pages[currentPage].title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                // Description
                Text(pages[currentPage].description)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Bottom controls
                HStack {
                    // Skip button (except on last page)
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            showOnboarding = false
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.secondaryText)
                    } else {
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    // Next button
                    Button(currentPage < pages.count - 1 ? "Next" : "Get Started") {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            showOnboarding = false
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showOnboarding: .constant(true))
    }
}
