import FirebaseAuth

extension Error {
    func toAppError() -> AppError {
        if let authError = self as? AuthErrorCode {
            switch authError.code {
            case .emailAlreadyInUse:
                return .emailAlreadyInUse
            case .invalidEmail:
                return .invalidEmail
            case .wrongPassword:
                return .wrongPassword
            case .userNotFound:
                return .userNotFound
            case .weakPassword:
                return .weakPassword
            default:
                return .unknownError(self.localizedDescription)
            }
        }
        return .unknownError(self.localizedDescription)
    }
}
