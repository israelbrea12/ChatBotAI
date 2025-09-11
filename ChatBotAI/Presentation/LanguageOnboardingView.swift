//
//  LanguageOnboardingView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 24/7/25.
//

import SwiftUI

struct LanguageOnboardingView: View {
    
    var onContinue: (Language) -> Void
    
    @State private var selectedLanguage: Language?
    @State private var animateIcon: Bool = false
    @State private var animateTitle: Bool = false
    @State private var animateCards: Bool = false
    @State private var animateFooter: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {

                    Image(systemName: "globe.europe.africa.fill")
                        .font(.system(size: 50))
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.white)
                        .background(Color.appBlue.gradient, in: .rect(cornerRadius: 25))
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .blurSlide(animateIcon)

                    Text(LocalizedKeys.Onboarding.languageTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .blurSlide(animateTitle)
                    
                    LanguageSelectionView()
                        .blurSlide(animateCards)
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            
            VStack(spacing: 15) {
                Text(LocalizedKeys.Onboarding.languageSubtitle)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
                
                Button(action: {
                    if let selectedLanguage {
                        onContinue(selectedLanguage)
                    }
                }) {
                    Text(LocalizedKeys.Common.continue)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .tint(.appBlue)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .disabled(selectedLanguage == nil)
                .opacity(selectedLanguage == nil ? 0.5 : 1)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .blurSlide(animateFooter)
        }
        .frame(maxWidth: 400)
        .interactiveDismissDisabled()
        .allowsHitTesting(animateFooter)
        .task {
            await animateView()
        }
    }
    
    @ViewBuilder
    private func LanguageSelectionView() -> some View {
        VStack(spacing: 15) {
            ForEach(Language.allCases) { lang in
                Button(action: {
                    withAnimation(.spring) {
                        selectedLanguage = lang
                    }
                }) {
                    HStack(spacing: 15) {
                        Text(lang.flag).font(.largeTitle)
                        Text(lang.fullName).fontWeight(.semibold)
                        Spacer()
                        if selectedLanguage == lang {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.appBlue)
                                .font(.title2)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
                    .clipShape(.rect(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(selectedLanguage == lang ? Color.appBlue : .clear, lineWidth: 2)
                    )
                }
                .tint(.primary)
            }
        }
        .padding(.horizontal)
    }
    
    private func animateView() async {
        guard !animateIcon else { return }
        
        await delayedAnimation(0.35) { animateIcon = true }
        await delayedAnimation(0.2) { animateTitle = true }
        await delayedAnimation(0.2) { animateCards = true }
        await delayedAnimation(0.2) { animateFooter = true }
    }
    
    private func delayedAnimation(_ delay: Double, action: @escaping () -> ()) async {
        try? await Task.sleep(for: .seconds(delay))
        withAnimation(.smooth(duration: 0.6)) {
            action()
        }
    }
}

#Preview {
    LanguageOnboardingView { lang in
        print("Selected: \(lang.fullName)")
    }
    .preferredColorScheme(.dark)
}
