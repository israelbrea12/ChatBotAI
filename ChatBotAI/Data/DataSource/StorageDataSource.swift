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
                // Firebase Storage devuelve un error 'objectNotFound' si el archivo no existe.
                // Para nuestro caso de uso, si no existe, es un éxito, así que lo ignoramos.
                if error.domain == StorageErrorDomain && error.code == StorageErrorCode.objectNotFound.rawValue {
                    print("StorageDataSource: No se encontró imagen de perfil para el usuario \(userId), se considera borrado exitoso.")
                    return // No hay nada que borrar, así que no es un error.
                }
                // Si es otro tipo de error, lo lanzamos.
                throw error
            }
        }
}

// Extensión para DatabaseReference.putData (si no usas las más recientes de Firebase que incluyen async/await)
// Si ya tienes Firebase con async/await para Storage, no necesitas esto.
extension StorageReference {
    func putDataAsync(_ uploadData: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
        try await withCheckedThrowingContinuation { continuation in
            self.putData(uploadData, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: NSError(domain: "FirebaseStorage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload data and no metadata received."]))
                }
            }
        }
    }
}
