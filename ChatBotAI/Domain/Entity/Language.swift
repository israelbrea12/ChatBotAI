//
//  Language.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 24/7/25.
//


import Foundation

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    
    var id: String { self.rawValue }
    
    var fullName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        }
    }
    
    var nameInSpanish: String {
        switch self {
        case .english: return "inglés"
        case .spanish: return "español"
        case .french: return "francés"
        }
    }
}
