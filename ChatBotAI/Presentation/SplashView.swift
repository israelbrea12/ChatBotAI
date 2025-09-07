//
//  SplashView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/9/25.
//

import SwiftUI

struct SplashView: View {
    
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBlue, Color.tooLightBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                LottieView(fileName: "chatbotia_splash_lottie")
                    .frame(width: 300, height: 300)
                
                Text("Chatbot IA")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    isActive = false
                }
            }
        }
    }
}
