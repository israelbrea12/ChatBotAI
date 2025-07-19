//
//  ImageStorageDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 1/6/25.
//


import FirebaseStorage
import SwiftUI

protocol StorageDataSource {
    func uploadImage(imageData: Data, chatId: String, messageId: String) async throws -> URL
    func deleteProfileImage(userId: String) async throws
}

// Implementación para Firebase Storage
class StorageDataSourceImpl: StorageDataSource {
    private let storageRef = Storage.storage().reference()

    func uploadImage(imageData: Data, chatId: String, messageId: String) async throws -> URL {
        // Define una ruta única para la imagen en Storage
        let imagePath = "chat_images/\(chatId)/\(messageId).jpg"
        let imageRef = storageRef.child(imagePath)

        // Sube los datos de la imagen
        // Firebase SDK provee putDataAsync a partir de ciertas versiones o puedes envolverlo
        // Aquí un ejemplo de cómo envolverlo si no está disponible directamente:
        try await imageRef.putDataAsync(imageData, metadata: nil) // putDataAsync es una extensión de ejemplo

        // Obtiene la URL de descarga
        let downloadURL = try await imageRef.downloadURL()
        return downloadURL
    }
    
    func deleteProfileImage(userId: String) async throws {
        let imagePath = "profile_images/\(userId).jpg"
        let imageRef = storageRef.child(imagePath)
        
        do {
            try await imageRef.delete()
            print("StorageDataSource: Imagen de perfil eliminada con éxito para el usuario \(userId).")
        } catch let error as NSError {
            if error.domain == StorageErrorDomain && error.code == StorageErrorCode.objectNotFound.rawValue {
                print("StorageDataSource: No se encontró imagen de perfil para el usuario \(userId), se considera borrado exitoso.")
                return
            }
            throw error
        }
    }
}
