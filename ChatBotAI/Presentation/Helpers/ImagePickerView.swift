//
//  ImagePicker.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 19/3/25.
//

// MARK: ImagePicker.swift

import SwiftUI
import PhotosUI

// Se usa en la seleccion de imagen del registro de user.
struct ImagePickerView: View {
    @Binding var image: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
            
            // Usamos un ZStack para superponer el contenido (imagen o placeholder)
            // dentro de un marco consistente.
            ZStack {
                if let image = image {
                    // La imagen seleccionada
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill() // scaledToFill se asegura de que la imagen llene el marco,
                                        // y el .clipShape(Circle()) la recortará perfectamente.
                } else {
                    // El estado placeholder
                    // Añadimos un fondo de color para que el círculo tenga cuerpo
                    // y un tamaño visible antes de seleccionar una imagen.
                    Circle()
                        .fill(Color(.white))
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                }
            }
            // <<--- ESTOS MODIFICADORES SE APLICAN AHORA AL ZSTACK --- >>
            // Se aplican siempre, sin importar si hay imagen o no.
            .frame(width: 96, height: 96)      // 1. Definimos un tamaño fijo y constante.
            .clipShape(Circle())                 // 2. Aseguramos que la forma sea siempre un círculo.
            .overlay(Circle().stroke(Color.gray, lineWidth: 1)) // 3. Añadimos un borde circular perfecto.
            
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
