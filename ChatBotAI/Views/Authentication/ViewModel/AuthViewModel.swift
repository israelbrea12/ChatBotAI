import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var state: ViewState = .success
    
    private let signInUseCase: SignInUseCase
    private let signUpUseCase: SignUpUseCase
    
    init(signInUseCase: SignInUseCase, signUpUseCase: SignUpUseCase) {
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
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
        case .failure(let error):
            print("DEBUG: Error al registrar usuario: \(error.localizedDescription)")
        }
    }
}
