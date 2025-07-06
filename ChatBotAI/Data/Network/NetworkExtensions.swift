import FirebaseAuth

extension Error {
    func toAppError() -> AppError {
        let nsError = self as NSError

        if nsError.domain == AuthErrorDomain {
            if let authErrorCode = AuthErrorCode(rawValue: nsError.code) {
                print("Firebase Auth Error Code: \(nsError.code)")
                switch authErrorCode {
                case .networkError:
                    return .networkError("Error de conexión. Verifica tu internet.")
                case .wrongPassword, .invalidCredential:
                    return .authenticationError("Contraseña incorrecta, pruebe de nuevo o recupere su contraseña.")
                case .userNotFound:
                    return .authenticationError("Usuario no encontrado.")
                case .emailAlreadyInUse:
                    return .authenticationError("El correo ya está en uso. Pruebe a iniciar sesión")
                case .weakPassword:
                    return .authenticationError("La contraseña es demasiado débil.")
                default:
                    print("Unhandled Auth Error: \(authErrorCode.rawValue)")
                    return .authenticationError("Error de autenticación: \(authErrorCode.rawValue)")

                }
            }
        }

        return .unknownError(nsError.localizedDescription)
    }
}
