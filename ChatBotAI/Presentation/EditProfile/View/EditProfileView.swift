//
//  EditProfileView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 19/7/25.
//

import PhotosUI
import SwiftUI
import SDWebImageSwiftUI

struct EditProfileView: View {
    @StateObject var editProfileViewModel: EditProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    init(user: User) {
        _editProfileViewModel = StateObject(wrappedValue: Resolver.shared.resolve(EditProfileViewModel.self, arguments: user))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section(header: Text(LocalizedKeys.Settings.profilePictureTitle)) {
                        HStack {
                            Spacer()
                            VStack {
                                ImagePickerSettingsView(
                                    image: $editProfileViewModel.selectedImage,
                                    currentImageUrl: editProfileViewModel.profileImageUrl
                                )
                                .frame(width: 120, height: 120)
                                
                                Text(LocalizedKeys.Settings.tapToChangePhoto)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    
                    Section(header: Text(LocalizedKeys.Settings.userInformationTitle)) {
                        TextField(LocalizedKeys.Placeholder.fullnamePlaceholder, text: $editProfileViewModel.fullName)
                        
                        HStack {
                            Text(LocalizedKeys.Placeholder.emailPlaceholder)
                            Spacer()
                            Text(editProfileViewModel.email)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section(header: Text(LocalizedKeys.Settings.preferences)) {
                        Picker(LocalizedKeys.Features.learningLanguage, selection: $editProfileViewModel.learningLanguage) {
                            ForEach(Language.allCases) { lang in
                                Text("\(lang.flag) \(lang.fullName)").tag(lang)
                            }
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
                    ProgressView(LocalizedKeys.LoadingState.saving)
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
            }
            .navigationTitle(LocalizedKeys.Settings.editProfile)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedKeys.Common.cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedKeys.Common.save) {
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
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
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
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        image = UIImage(data: data)
                    }
                }
            }
        }
    }
}
