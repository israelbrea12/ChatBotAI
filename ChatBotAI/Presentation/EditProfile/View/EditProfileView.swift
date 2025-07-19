//
//  EditProfileView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 19/7/25.
//


// Create a new file: EditProfileView.swift

import PhotosUI
import SwiftUI
import SDWebImageSwiftUI

struct EditProfileView: View {
    @StateObject var editProfileViewModel: EditProfileViewModel
    @Environment(\.dismiss) var dismiss
        
        // --- MODIFICA EL INIT PARA QUE QUEDE ASÍ ---
    init(user: User) {
        _editProfileViewModel = StateObject(wrappedValue: Resolver.shared.resolve(EditProfileViewModel.self, arguments: user))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section(header: Text("Profile Picture")) {
                        HStack {
                            Spacer()
                            VStack {
                                // ImagePickerView es la misma que usas en el registro
                                ImagePickerSettingsView(
                                    image: $editProfileViewModel.selectedImage,
                                    currentImageUrl: editProfileViewModel.profileImageUrl
                                )
                                .frame(width: 120, height: 120)
                                
                                Text("Tap to change photo")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    
                    Section(header: Text("User Information")) {
                        TextField("Full Name", text: $editProfileViewModel.fullName)
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(editProfileViewModel.email)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if let errorMessage = editProfileViewModel.errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                if editProfileViewModel.isLoading {
                    ProgressView("Saving...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await editProfileViewModel.saveChanges()
                        }
                    }
                    .disabled(editProfileViewModel.isLoading)
                }
            }
            .onReceive(editProfileViewModel.dismissAction) { _ in
                dismiss()
            }
        }
    }
}

struct ImagePickerSettingsView: View {
    @Binding var image: UIImage?
    var currentImageUrl: String?
    
    // 1. Añade un estado para el item seleccionado por PhotosPicker
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        // 2. Envuelve la vista de la imagen en PhotosPicker
        PhotosPicker(
            selection: $selectedPhotoItem,
            matching: .images, // Filtramos para que solo se puedan seleccionar imágenes
            photoLibrary: .shared()
        ) {
            // El "label" del picker es tu vista de imagen actual, no necesita cambios
            if let selectedImage = image {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else if let imageUrl = currentImageUrl, let url = URL(string: imageUrl) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.gray)
                    .clipShape(Circle())
            }
        }
        // 3. Añade el modificador .onChange para procesar la selección
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                // Intentamos cargar los datos de la imagen desde el item seleccionado
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    // Si tenemos datos, creamos la UIImage y la asignamos
                    // a nuestro binding, asegurándonos de hacerlo en el hilo principal.
                    await MainActor.run {
                        image = UIImage(data: data)
                    }
                }
            }
        }
    }
}
