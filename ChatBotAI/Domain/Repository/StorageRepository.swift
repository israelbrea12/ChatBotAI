//
//  StorageRepository.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 1/6/25.
//


import Foundation

protocol StorageRepository {
    func uploadImage(imageData: Data, chatId: String, messageId: String) async -> Result<URL, AppError>
    func deleteProfileImage(userId: String) async -> Result<Void, AppError>
}
