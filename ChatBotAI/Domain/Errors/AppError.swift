//
//  AppError.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation

enum AppError: Error {
    case networkError(String)
    case authenticationError(String)
    case databaseError(String)
    case emailAlreadyInUse
    case invalidEmail
    case wrongPassword
    case userNotFound
    case weakPassword
    case requiresRecentLogin
    case validationError(String)
    case unknownError(String)
    
    var localizedDescription: String {
        switch self {
        case .emailAlreadyInUse:
            return "Este correo electrónico ya está en uso. Por favor, inicia sesión."
        case .invalidEmail:
            return "El formato del correo electrónico no es válido."
        case .wrongPassword:
            return "La contraseña es incorrecta. Inténtalo de nuevo."
        case .userNotFound:
            return "No se encontró ninguna cuenta con este correo electrónico."
        case .weakPassword:
            return "La contraseña es demasiado débil. Debe tener al menos 6 caracteres."
        case .validationError(let message):
            return message
        case .unknownError(let message):
            return "Ha ocurrido un error inesperado: \(message)"
        case .requiresRecentLogin:
            return "Esta operación requiere un inicio de sesión reciente."
        case .networkError(_):
            return "Error de red. Inténtalo más tarde."
        case .authenticationError(_):
            return "Error de autenticación. Inténtalo de nuevo."
        case .databaseError(_):
            return "Error en la base de datos"
        }
    }
}
