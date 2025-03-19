import Foundation
import UIKit
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var state: ViewState = .success
    
    private let signInUseCase: SignInUseCase
    private let signUpUseCase: SignUpUseCase
    private let uploadImageUseCase: UploadImageUseCase
    
    @Published var image: UIImage?
    @Published var shouldShowImagePicker = false
    
    init(signInUseCase: SignInUseCase, signUpUseCase: SignUpUseCase, uploadImageUseCase: UploadImageUseCase) {
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
        self.uploadImageUseCase = uploadImageUseCase
    }
    
    func signIn(withEmail email: String, password: String) async {
        let result = await signInUseCase.execute(with: SignInParam(email: email, password: password))
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                SessionManager.shared.userSession = Auth.auth().currentUser
                self.currentUser = user
            }
        case .failure(let error):
            print("DEBUG: Sign-in error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async {
            let result = await signUpUseCase.execute(with: SignUpParam(email: email, fullName: fullName, password: password))
            
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    SessionManager.shared.userSession = Auth.auth().currentUser
                    self.currentUser = user
                }
                await persistImageToStorage(userId: user.id)
                
            case .failure(let error):
                print("DEBUG: Error al registrar usuario: \(error.localizedDescription)")
            }
        }
        
        private func persistImageToStorage(userId: String) async {
            guard let image = self.image else { return }
            let result = await uploadImageUseCase.execute(image: image, userId: userId)
            
            switch result {
            case .success(let imageUrl):
                print("DEBUG: Imagen subida con éxito: \(imageUrl)")
                // Aquí podrías actualizar el perfil del usuario en Firestore con la URL
            case .failure(let error):
                print("DEBUG: Error al subir imagen: \(error.localizedDescription)")
            }
        }
}
