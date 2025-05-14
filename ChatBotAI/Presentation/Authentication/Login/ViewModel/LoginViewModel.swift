import Foundation
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

@MainActor
class LoginViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var state: ViewState = .success
    @Published var isLoading = false // Estado de carga
    
    private let signInUseCase: SignInUseCase
    private let signInWithGoogleUseCase: SignInWithGoogleUseCase
    private let signInWithAppleUseCase: SignInWithAppleUseCase
    @Published var image: UIImage?
    @Published var shouldShowImagePicker = false

    
    init(
        signInUseCase: SignInUseCase,
        signInWithGoogleUseCase: SignInWithGoogleUseCase,
        signInWithAppleUseCase: SignInWithAppleUseCase
    ) {
        self.signInUseCase = signInUseCase
        self.signInWithGoogleUseCase = signInWithGoogleUseCase
        self.signInWithAppleUseCase = signInWithAppleUseCase
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

