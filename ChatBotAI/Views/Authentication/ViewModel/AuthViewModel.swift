import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var state: ViewState = .success
    
    private let signInUseCase: SignInUseCase
    private let signUpUseCase: SignUpUseCase
    private let uploadImageUseCase: UploadImageUseCase
    
    @Published var image: UIImage?
    @Published var shouldShowImagePicker = false
    
    init(
        signInUseCase: SignInUseCase,
        signUpUseCase: SignUpUseCase,
        uploadImageUseCase: UploadImageUseCase
    ) {
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
        self.uploadImageUseCase = uploadImageUseCase
    }
    
    func signIn(withEmail email: String, password: String) async {
        let result = await signInUseCase.execute(
            with: SignInParam(email: email, password: password)
        )
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
        let result = await signUpUseCase.execute(
            with: SignUpParam(email: email, fullName: fullName, password: password),
            profileImage: self.image
        )
            
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                SessionManager.shared.userSession = Auth.auth().currentUser
                self.currentUser = user
                SessionManager.shared.currentUser = user
            }
        case .failure(let error):
            print("DEBUG: Error al registrar usuario: \(error.localizedDescription)")
        }
    }
}
