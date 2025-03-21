import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var state: ViewState = .success
    @Published var isLoading = false // Estado de carga
    
    private let signInUseCase: SignInUseCase
    private let signUpUseCase: SignUpUseCase
    @Published var image: UIImage?
    @Published var shouldShowImagePicker = false
    
    init(
        signInUseCase: SignInUseCase,
        signUpUseCase: SignUpUseCase
    ) {
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
    }
    
    func signIn(withEmail email: String, password: String) async {
        isLoading = true
        let result = await signInUseCase.execute(
            with: SignInParam(email: email, password: password)
        )
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                self.isLoading = false
                SessionManager.shared.userSession = Auth.auth().currentUser
                self.currentUser = user
            }
        case .failure(let error):
            print("DEBUG: Sign-in error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async {
        DispatchQueue.main.async { self.isLoading = true }
        let result = await signUpUseCase.execute(
            with: SignUpParam(email: email, fullName: fullName, password: password),
            profileImage: self.image
        )            
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                self.isLoading = false
                SessionManager.shared.userSession = Auth.auth().currentUser
                self.currentUser = user
                SessionManager.shared.currentUser = user
            }
        case .failure(let error):
            state = .loading
            print("DEBUG: Error al registrar usuario: \(error.localizedDescription)")
        }
    }
}
