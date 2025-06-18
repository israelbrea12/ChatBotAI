import Foundation
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

@MainActor
class LoginViewModel: ObservableObject {
    
    // MARK: - Publisheds
    @Published var currentUser: User?
    @Published var state: ViewState = .success
    @Published var isLoading = false
    @Published var image: UIImage?
    @Published var shouldShowImagePicker = false
    @Published var email = ""
    @Published var password = ""
    @Published var authenticationError: AppError? // Para manejar y mostrar errores

    // MARK: - Validation
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
    
    // MARK: - Use Cases
    private let signInUseCase: SignInUseCase
    private let signInWithGoogleUseCase: SignInWithGoogleUseCase
    private let signInWithAppleUseCase: SignInWithAppleUseCase

    // MARK: Lifecycle functions
    init(
        signInUseCase: SignInUseCase,
        signInWithGoogleUseCase: SignInWithGoogleUseCase,
        signInWithAppleUseCase: SignInWithAppleUseCase
    ) {
        self.signInUseCase = signInUseCase
        self.signInWithGoogleUseCase = signInWithGoogleUseCase
        self.signInWithAppleUseCase = signInWithAppleUseCase
    }
    
    // MARK: - Functions
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
                self.email = ""
                self.password = ""
            }
        case .failure(let error):
            print("DEBUG: Sign-in error \(error.localizedDescription)")
            print("DEBUG: Tipo de error recibido -> \(type(of: error))")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func signInWithGoogle() async {
            let result = await signInWithGoogleUseCase.execute()
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.currentUser = user
                }
            case .failure(let error):
                print("DEBUG: Error signing in with Google: \(error.localizedDescription)")
            }
        }
    
    
    func signInWithApple() async {
        let result = await signInWithAppleUseCase.execute()
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                self.currentUser = user
            }
        case .failure(let error):
            print("DEBUG: Error signing in with Google: \(error.localizedDescription)")
        }
    }

}

