//
//  SplashView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/9/25.
//

import SwiftUI

struct SplashView: View {
    
    @Binding var isActive: Bool

    // Nuevos colores para el gradiente
    // Un azul celeste suave (casi blanco)
    let colorArribaIzquierda = Color(red: 220/255, green: 230/255, blue: 250/255) // #DCE6FA
    // Un azul ligeramente más profundo, cercano al de la burbuja
    let colorAbajoDerecha = Color(red: 160/255, green: 180/255, blue: 230/255)   // #A0B4E6

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
