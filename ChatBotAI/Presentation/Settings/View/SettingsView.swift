import SwiftUI
import SDWebImageSwiftUI

struct SettingsView: View {
    
    @StateObject var settingsViewModel = Resolver.shared.resolve(SettingsViewModel.self)
    
    @State private var showDeleteAlert = false
    @State private var showSignOutAlert = false
    @State private var showEditProfileSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch settingsViewModel.state {
                case .initial,
                        .loading:
                    loadingView()
                    
                case .success:
                    successView()
                    
                case .error(let errorMessage):
                    errorView(errorMsg: errorMessage)
                    signOutButton()
                    
                case .empty:
                    emptyView()
                    signOutButton()
                }
            }
            .navigationTitle("Settings")
        }
        .fullScreenCover(isPresented: $showEditProfileSheet) {
            if let user = settingsViewModel.currentUser {
                EditProfileView(user: user)
            }
        }
    }
    
    private func successView() -> some View {
        List {
            if let user = settingsViewModel.currentUser {
                
                Section {
                    userProfile(user: user)
                }
                
                Section("General") {
                    myProfileButton()
                }
                
                Section("Account") {
                    signOutButton()
                    deleteAccountButton()
                }
                
                Section("") {
                    helpButton()
                }
            }
        }
        .padding(.bottom, 50)
    }
    
    private func loadingView() -> some View {
        ProgressView()
    }
    
    private func errorView(errorMsg: String) -> some View {
        InfoView(message: errorMsg)
    }
    
    private func emptyView() -> some View {
        InfoView(message: "No user data found")
    }
    
    private func userProfile(user: User) -> some View {
        HStack {
            
            WebImage(
                url: URL(string: user.profileImageUrl ?? "")
            ) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 72, height: 72)
                        .foregroundColor(.gray)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 72, height: 72)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName ?? "")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 4)
                
                Text(user.email ?? "")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func myProfileButton() -> some View {
        Button(action: {
            showEditProfileSheet = true
        }) {
            SettingsRowView(imageName: "pencil.and.scribble", title: "Edit profile", tintColor: .black)
        }
    }
    
    private func signOutButton() -> some View {
        Button {
            showSignOutAlert = true
        } label: {
            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign out", tintColor: .red)
        }
        .alert("¿Seguro que quieres cerrar sesión?", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign out", role: .destructive) {
                Task {
                    settingsViewModel.signOut()
                }
            }
        }
    }
    
    private func deleteAccountButton() -> some View {
        Button {
            showDeleteAlert = true
        } label: {
            SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
        }
        .alert("¿Seguro que quieres eliminar tu cuenta?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await settingsViewModel.deleteAccount()
                }
            }
        }
    }
        
    private func helpButton() -> some View {
        SettingsRowView(imageName: "info.circle", title: "Help", tintColor: .black)
    }
}
