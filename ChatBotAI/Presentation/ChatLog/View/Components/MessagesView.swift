//
//  MessagesView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import SwiftUI

struct MessagesView: View {
    let messages: [Message]
    let currentUserId: String?
    
    @Namespace private var bottomID
    
    // Estados para el menú contextual
    @State private var showContextMenu: Bool = false
    @State private var contextMenuMessage: Message? = nil
    @State private var contextMenuAnchorFrame: CGRect = .zero // Frame de la burbuja pulsada

    // Estimación del tamaño del menú para cálculos de posición.
    // Podrías hacerlo más dinámico si es necesario.
    private let menuEstimatedSize = CGSize(width: 200, height: 110) // (opción_alto + padding_v) * num_opciones + (num_opciones -1) * alto_divisor

    var groupedMessages: [(date: String, messages: [Message])] {
        // ... (tu lógica existente para agrupar mensajes)
        Dictionary(grouping: messages) { message in
            guard let timestamp = message.sentAt else { return "Desconocido" }
            let date = Date(timeIntervalSince1970: timestamp)
            return date.whatsappFormattedTimeAgoWithoutAMOrPM() // Asumo que esta extensión existe
        }
        .map { (key: String, value: [Message]) in (date: key, messages: value) }
        .sorted { a, b in
            guard let firstDate = a.messages.first?.sentAt, let secondDate = b.messages.first?.sentAt else { return false }
            return firstDate < secondDate
        }
    }

    var body: some View {
        // GeometryReader para obtener las dimensiones de la pantalla para posicionar el menú
        GeometryReader { screenGeometry in
            ZStack { // ZStack principal para superponer el menú
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        LazyVStack(spacing: 0) { // Reducir spacing si se desea
                            ForEach(groupedMessages, id: \.date) { group in
                                Text(group.date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color.gray.opacity(0.2)))
                                    .padding(.vertical, 10) // Espacio alrededor de la fecha
                            
                                ForEach(group.messages) { message in
                                    MessageBubbleView(
                                        message: message,
                                        isCurrentUser: message.senderId == currentUserId,
                                        onLongPress: { tappedMessage, bubbleFrameGlobal in
                                            self.contextMenuMessage = tappedMessage
                                            self.contextMenuAnchorFrame = bubbleFrameGlobal
                                            // Animación para la aparición del menú
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                                                self.showContextMenu = true
                                            }
                                            print("pulsado\(message.id ?? "N/A")") // Defensive unwrap
                                            // Feedback háptico
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }
                                    )
                                    .id(message.id) // ID para el ScrollViewReader
                                    // El padding inferior ya estaba, lo mantenemos
                                    .padding(.bottom, group.messages.last?.id == message.id ? 5 : 0)
                                }
                            }
                            Color.clear
                                .frame(height: 1)
                                .id(bottomID)
                        }
                        .padding(.vertical, 8)
                    }
                    .simultaneousGesture(
                        DragGesture().onChanged { _ in
                            UIApplication.shared.endEditing()
                        }
                    )
                    .background(Color(.init(white: 0.95, alpha: 1))) // Tu fondo existente
                    .onAppear { // Tu lógica onAppear existente
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            scrollToBottom(proxy: scrollViewProxy, animated: false)
                        }
                    }
                    .onChange(of: messages.count) { // Tu lógica onChange existente
                        scrollToBottom(proxy: scrollViewProxy)
                    }
                    .onChange(of: messages.last?.id) { // Tu lógica onChange existente
                         // Swift 5.9+ can use: onChange(of: messages.last?.id) { oldValue, newValue in ... }
                         // For older Swift:
                        // if messages.last?.id != nil { // Check if it's not nil before scrolling
                            scrollToBottom(proxy: scrollViewProxy)
                        // }
                    }
                } // Fin ScrollViewReader

                // Overlay para el menú contextual
                if showContextMenu {
                    // Fondo semi-transparente para cerrar el menú al tocar fuera
                    Color.black.opacity(0.001) // Casi invisible pero tappable
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                self.showContextMenu = false
                                self.contextMenuMessage = nil // Limpiar el mensaje seleccionado
                            }
                        }

                    // El menú en sí
                    if let message = contextMenuMessage {
                        ContextMenuView( // Assuming ContextMenuView and MessageActionItem are defined elsewhere
                            items: [
                                MessageActionItem(label: "Editar", systemImage: "pencil.circle.fill") {
                                    print("Acción: Editar mensaje con ID '\(message.id ?? "N/A")'")
                                    // Aquí implementarías la lógica de edición
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        self.showContextMenu = false // Cierra el menú después de la acción
                                    }
                                },
                                MessageActionItem(label: "Eliminar", systemImage: "trash.circle.fill") {
                                    print("Acción: Eliminar mensaje con ID '\(message.id ?? "N/A")'")
                                    // Aquí implementarías la lógica de eliminación
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        self.showContextMenu = false // Cierra el menú después de la acción
                                    }
                                }
                            ],
                            showMenu: $showContextMenu
                        )
                        .transition(.scale(scale: 0.95, anchor: .center).combined(with: .opacity)) // Added a nice transition
                    }
                }
            } // Fin ZStack principal
        } // Fin GeometryReader
    }
    
    // Función helper para hacer scroll al fondo
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        guard !messages.isEmpty, let lastId = messages.last?.id else { // Ensure there is an ID to scroll to
            // Attempt to scroll to bottomID if messages might be empty or last has no id
            // This ensures scrolling even if the very last item doesn't conform to Identifiable in a specific way
            // but bottomID (the Color.clear view) exists.
            if animated {
                withAnimation(.spring()) { proxy.scrollTo(bottomID, anchor: .bottom) }
            } else {
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
            return
        }
        
        if animated {
            withAnimation(.spring()) { // Puedes ajustar la animación
                proxy.scrollTo(lastId, anchor: .bottom) // Scroll to the last message
            }
        } else {
            proxy.scrollTo(lastId, anchor: .bottom) // Scroll to the last message
        }
        // As a fallback or alternative, you can always scroll to bottomID
        // proxy.scrollTo(bottomID, anchor: .bottom)
    }

}

/*
// --- Estas structs son necesarias para que el código compile ---
// --- Asegúrate de tenerlas definidas en tu proyecto ---

struct Message: Identifiable, Equatable { // Added Equatable for onChange
    let id: String? // Make sure id is consistently non-nil if used as ForEach key directly
    let text: String
    let senderId: String
    let sentAt: TimeInterval?

    // Ejemplo de inicializador si id es opcional pero siempre debería tener valor para mensajes mostrados
    init(id: String = UUID().uuidString, text: String, senderId: String, sentAt: TimeInterval?) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.sentAt = sentAt
    }
}

// Para el menú contextual (ejemplo)
struct MessageActionItem: Identifiable {
    let id = UUID()
    let label: String
    let systemImage: String
    let action: () -> Void
}

struct ContextMenuView: View {
    let items: [MessageActionItem]
    @Binding var showMenu: Bool // Necesario para que el menú sepa si debe mostrarse

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items) { item in
                Button(action: {
                    item.action()
                    // La animación y el cierre del menú se manejan en MessagesView
                }) {
                    HStack {
                        Text(item.label)
                        Spacer()
                        Image(systemName: item.systemImage)
                    }
                    .padding()
                }
                .foregroundColor(.primary) // O el color que prefieras

                if item.id != items.last?.id { // No añadir divisor después del último ítem
                    Divider()
                }
            }
        }
        .frame(width: 200) // Ancho fijo como en tu estimación
        .background(Color(UIColor.systemGray6)) // Un color de fondo típico para menús
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal, 5) // Evita que el shadow se corte si el menú está justo en el borde
    }
}

// Extensiones de Date (ejemplos placeholder, usa las tuyas)
extension Date {
    func whatsappFormattedTimeAgoWithoutAMOrPM() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy" // Ejemplo: "Tuesday, May 28, 2025"
        if Calendar.current.isDateInToday(self) {
            formatter.dateFormat = "'Hoy'" // Today
        } else if Calendar.current.isDateInYesterday(self) {
            formatter.dateFormat = "'Ayer'" // Yesterday
        }
        return formatter.string(from: self)
    }

    func BublesFormattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // Ejemplo: 14:30
        return formatter.string(from: self)
    }
}
*/
