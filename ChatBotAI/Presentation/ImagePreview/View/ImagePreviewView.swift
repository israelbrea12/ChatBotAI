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
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .padding()
                            .accessibilityLabel(LocalizedKeys.Chat.imagePreviewTitle)
                    } else {
                        Text(LocalizedKeys.Chat.couldNotLoadPreview)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        TextField(LocalizedKeys.Placeholder.addCommentPlaceholder, text: $caption)
                            .focused($isCaptionFieldFocused)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.secondary.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            isCaptionFieldFocused = false
                            onSend(caption)
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
            .navigationBarItems(
                leading:
                    Button(action: {
                        isCaptionFieldFocused = false
                        onCancel()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.secondary)
                    }
            )
            .navigationBarTitleDisplayMode(.inline)
        }
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
