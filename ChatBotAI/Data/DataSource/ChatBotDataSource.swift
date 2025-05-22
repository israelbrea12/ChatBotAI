//
//  ChatBotDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//

import Foundation
import FirebaseAI

protocol ChatBotDataSource {
    func generateResponse(prompt: String) async -> Result<String, Error>
}

class ChatBotDataSourceImpl: ChatBotDataSource {

    private lazy var model: GenerativeModel = {
        let ai = FirebaseAI.firebaseAI(
            backend: .googleAI()
        ) // Usa Firebase para conectar con Vertex AI
        return ai
            .generativeModel(
                modelName: DataConstant.geminiModel
            ) // o "gemini-pro" según necesidad
    }()

    func generateResponse(prompt: String) async -> Result<String, Error> {
        do {
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                return .success(text)
            } else {
                let error = NSError(
                    domain: "ChatBotDataSourceError",
                    code: 1002,
                    userInfo: [NSLocalizedDescriptionKey: "La IA no devolvió texto."]
                )
                return .failure(error)
            }
        } catch {
            return .failure(error)
        }
    }
}
