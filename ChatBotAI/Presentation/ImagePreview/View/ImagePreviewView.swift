//
//  ImagePreviewView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 1/6/25.
//

import SwiftUI

struct ImagePreviewView: View {
    let imageData: Data
    @Binding var caption: String
    var onCancel: () -> Void
    var onSend: (_ caption: String) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isCaptionFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.black : Color.white)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isCaptionFieldFocused = false
                    }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .accessibilityLabel(LocalizedKeys.Chat.imagePreviewTitle)
                    } else {
                        Text(LocalizedKeys.Chat.couldNotLoadPreview)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        TextField(LocalizedKeys.Placeholder.addCommentPlaceholder, text: $caption)
                            .focused($isCaptionFieldFocused)
                            .padding(12)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        Button(action: {
                            isCaptionFieldFocused = false
                            onSend(caption)
                        }) {
                            Image(systemName: "paperplane.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 10 > 0 ? 0 : 20)
                    .padding(.bottom, 10)
                }
            }
            .navigationBarItems(
                leading:
                    Button(action: {
                        isCaptionFieldFocused = false
                        onCancel()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                    }
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.blue)
    }
}

struct ImagePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let placeholderImageData = UIImage(systemName: "photo")?.pngData() ?? Data()
        
        ImagePreviewView(
            imageData: placeholderImageData,
            caption: .constant("Un bonito pie de foto"),
            onCancel: { print("Preview Cancelled") },
            onSend: { caption in print("Preview Send with caption: \(caption)") }
        )
    }
}
