//
//  CustomTF.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 18/6/25.
//


// MARK: CustomTF.swift

import SwiftUI

struct CustomTF: View {
    var sfIcon: String
    var iconTint: Color = .gray
    var hint: String
    var isPassword: Bool = false
    @Binding var value: String
    var error: String?
    
    @State private var showPassword: Bool = false
    @FocusState private var passwordState: HideState?
    
    enum HideState {
        case hide, reveal
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: sfIcon)
                .foregroundStyle(iconTint)
                .frame(width: 30)
                .offset(y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                // MARK: - SOLUCIÓN
                // Agrupamos el campo de texto y el botón en un ZStack.
                // Esto asegura que se mantengan alineados verticalmente.
                ZStack(alignment: .trailing) {
                    // Grupo de TextFields
                    Group {
                        if isPassword {
                            if showPassword {
                                TextField(hint, text: $value)
                                    .focused($passwordState, equals: .reveal)
                            } else {
                                SecureField(hint, text: $value)
                                    .focused($passwordState, equals: .hide)
                            }
                        } else {
                            TextField(hint, text: $value)
                        }
                    }
                    
                    // Botón del ojo, ahora dentro del ZStack
                    if isPassword {
                        Button(action: {
                            withAnimation { showPassword.toggle() }
                            passwordState = showPassword ? .reveal : .hide
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundStyle(.gray)
                                .padding(10)
                                .contentShape(.rect)
                        }
                    }
                } // Fin del ZStack
                
                Divider()
                
                // El mensaje de error ahora no afecta al alineamiento del botón
                if let error, !error.isEmpty {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.top, 2)
                }
            }
        }
    }
}
