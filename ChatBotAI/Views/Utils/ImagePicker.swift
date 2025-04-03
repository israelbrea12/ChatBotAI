//
//  ImagePicker.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 19/3/25.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    @Binding var image: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 128, height: 128)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 64))
                        .padding()
                        .foregroundColor(.gray)
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.gray, lineWidth: 1))
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    image = UIImage(data: data)
                }
            }
        }
    }
}
