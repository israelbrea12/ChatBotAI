//
//  LoadingView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 18/6/25.
//

import SwiftUI

struct LoadingView: View {
    
    let message: String
    
    var body: some View {
        
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            VStack {
                ProgressView(message)
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    .shadow(radius: 5)
            }
            .frame(maxWidth: 200)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView(message: "Creating new account...")
}
