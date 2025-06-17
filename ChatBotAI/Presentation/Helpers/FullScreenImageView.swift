//
//  FullScreenImageView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 16/6/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct FullScreenImageView: View {
    let url: URL?
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.white
                .edgesIgnoringSafeArea(.all)
            WebImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}
