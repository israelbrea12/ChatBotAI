//
//  UseCaseProtocol.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation

protocol UseCaseProtocol {
    associatedtype P
    associatedtype R
    
    func execute(with params: P) async -> Result<R,AppError>
}
