//
//  MessageActionItem.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 29/5/25.
//


import SwiftUI

struct MessageActionItem: Identifiable {
    let id = UUID()
    let label: String
    let systemImage: String
    let action: () -> Void
}

struct ContextMenuView: View {
    let items: [MessageActionItem]
    @Binding var showMenu: Bool // Controla la visibilidad, puede ser útil para cierres internos

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items) { item in
                Button(action: {
                    item.action()
                    // La animación y el cierre se manejan externamente al pulsar una opción,
                    // pero podrías forzar el cierre aquí si fuera necesario.
                    // withAnimation { showMenu = false }
                }) {
                    HStack {
                        Text(item.label)
                            .font(.system(size: 15))
                        Spacer()
                        Image(systemName: item.systemImage)
                            .font(.system(size: 15))
                    }
                    .foregroundColor(.primary) // Puedes cambiarlo a .white si usas un fondo oscuro
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle()) // Asegura que toda el área sea tappable
                }

                if item.id != items.last?.id {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal, 10)
                }
            }
        }
        .frame(minWidth: 200, idealWidth: 220, maxWidth: 250) // Ancho adaptable
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Material.regular) // Efecto translúcido moderno
                // Alternativa: Color(UIColor.systemGray5) para un look más opaco
                // Alternativa: Color.black.opacity(0.8) para un look oscuro tipo WhatsApp
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.85, anchor: .top).combined(with: .opacity),
            removal: .scale(scale: 0.85, anchor: .top).combined(with: .opacity)
        ))
        // Pequeña animación de "rebote" al aparecer, si se desea (usar con withAnimation(.interpolatingSpring(...)))
        // .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: showMenu)
    }
}

// Preview para ContextMenuView (opcional)
struct ContextMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ContextMenuView(
            items: [
                MessageActionItem(label: "Editar", systemImage: "pencil.circle.fill", action: { print("Editar") }),
                MessageActionItem(label: "Eliminar", systemImage: "trash.circle.fill", action: { print("Eliminar") })
            ],
            showMenu: .constant(true)
        )
        .padding()
        .background(Color.blue.opacity(0.3)) // Fondo para previsualizar
    }
}
