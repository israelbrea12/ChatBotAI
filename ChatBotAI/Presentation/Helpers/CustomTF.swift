//
//  CustomTF.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 18/6/25.
//


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
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: sfIcon)
                .foregroundStyle(iconTint)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                ZStack(alignment: .trailing) {
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
                }
                
                Divider()
                
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
