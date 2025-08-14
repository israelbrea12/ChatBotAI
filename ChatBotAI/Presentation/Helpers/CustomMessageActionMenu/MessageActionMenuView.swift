//
//  MessageActionItem.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 29/5/25.
//


import SwiftUI

struct MessageActionMenuView: View {
    
    // MARK: - Constants
    let items: [MessageActionItem]
    
    // MARK: - Bindings
    @Binding var showMenu: Bool
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items) { item in
                Button(action: {
                    item.action()
                }) {
                    HStack {
                        Text(item.label)
                            .font(.system(size: 15))
                        Spacer()
                        Image(systemName: item.systemImage)
                            .font(.system(size: 15))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                
                if item.id != items.last?.id {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal, 10)
                }
            }
        }
        .frame(minWidth: 200, idealWidth: 220, maxWidth: 250)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Material.regular)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.85, anchor: .top).combined(with: .opacity),
            removal: .scale(scale: 0.85, anchor: .top).combined(with: .opacity)
        ))
    }
}

// MARK: - Preview
struct ContextMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MessageActionMenuView(
            items: [
                MessageActionItem(label: "Editar", systemImage: "pencil.circle.fill", action: { print("Editar") }),
                MessageActionItem(label: "Eliminar", systemImage: "trash.circle.fill", action: { print("Eliminar") })
            ],
            showMenu: .constant(true)
        )
        .padding()
        .background(Color.blue.opacity(0.3))
    }
}
