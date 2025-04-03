//
//  AppError.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation

enum AppError: Error {
    case networkError(String)  // Para problemas de conexión
    case authenticationError(String)  // Errores de autenticación en Firebase
    case databaseError(String)  // Errores en Firestore o Realtime Database
    case unknownError(String)  // Para errores no identificados
}
