//
//  OnboardingView.swift
//  AURZA
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var onboardingService: OnboardingService
    @State private var currentStep = 0
    
    let steps = [
        OnboardingStep(
            icon: "calendar",
            title: NSLocalizedString("onboarding_calendar_title", comment: ""),
            description: NSLocalizedString("onboarding_calendar_description", comment: "")
        ),
        OnboardingStep(
            icon: "plus.circle.fill",
            title: NSLocalizedString("onboarding_add_title", comment: ""),
            description: NSLocalizedString("onboarding_add_description", comment: "")
        ),
        OnboardingStep(
            icon: "book.closed",
            title: NSLocalizedString("onboarding_minihub_title", comment: ""),
            description: NSLocalizedString("onboarding_minihub_description", comment: "")
        ),
        OnboardingStep(
            icon: "chart.xyaxis.line",
            title: NSLocalizedString("onboarding_stats_title", comment: ""),
            description: NSLocalizedString("onboarding_stats_description", comment: "")
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                
                Button(action: {
                    onboardingService.hasCompletedOnboarding = true
                    isPresented = false
                }) {
                    Text(NSLocalizedString("skip", comment: ""))
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            Spacer()
            
            // Content
            VStack(spacing: 30) {
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                
                Text(steps[currentStep].title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(steps[currentStep].description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .id(currentStep)
            
            Spacer()
            
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentStep)
                }
            }
            .padding()
            
            // Navigation buttons
            HStack {
                if currentStep > 0 {
                    Button(action: {
                        withAnimation {
                            currentStep -= 1
                        }
                    }) {
                        Text(NSLocalizedString("previous", comment: ""))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    if currentStep < steps.count - 1 {
                        withAnimation {
                            currentStep += 1
                        }
                    } else {
                        onboardingService.hasCompletedOnboarding = true
                        isPresented = false
                    }
                }) {
                    Text(currentStep < steps.count - 1 ? NSLocalizedString("next", comment: "") : NSLocalizedString("get_started", comment: ""))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct OnboardingStep {
    let icon: String
    let title: String
    let description: String
}
