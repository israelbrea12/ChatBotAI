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

class StorageDataSourceImpl: StorageDataSource {
    private let storageRef = Storage.storage().reference()
    
    func uploadImage(imageData: Data, chatId: String, messageId: String) async throws -> URL {
        
        let imagePath = "\(Constants.Storage.chatImages)/\(chatId)/\(messageId)\(Constants.Storage.imageExtension)"
        let imageRef = storageRef.child(imagePath)

        try await imageRef.putDataAsync(imageData, metadata: nil)
        
        let downloadURL = try await imageRef.downloadURL()
        return downloadURL
    }
    
    func deleteProfileImage(userId: String) async throws {
        let imagePath = "\(Constants.Storage.profileImages)/\(userId)\(Constants.Storage.imageExtension)"
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
