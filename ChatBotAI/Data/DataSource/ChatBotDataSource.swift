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
    func generateResponseStream(prompt: String) -> AsyncThrowingStream<String, Error>
}

class ChatBotDataSourceImpl: ChatBotDataSource {

    private lazy var model: GenerativeModel = {
        let ai = FirebaseAI.firebaseAI(
            backend: .googleAI()
        )
        return ai
            .generativeModel(
                modelName: DataConstant.geminiModel
            )
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
    
    func generateResponseStream(prompt: String) -> AsyncThrowingStream<String, Error> {
            return AsyncThrowingStream { continuation in
                Task {
                    do {
                        let stream = try model.generateContentStream(prompt)
                        
                        for try await chunk in stream {
                            if let text = chunk.text {
                                continuation.yield(text)
                            }
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
        }
}
