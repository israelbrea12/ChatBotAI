import SwiftUI
import SDWebImageSwiftUI

struct ImageDetailView: View {
    @Environment(UICoordinator.self) private var coordinator
        
    var body: some View {
        VStack(spacing: 0) {
            // ✅ USAREMOS LA NUEVA BARRA DE NAVEGACIÓN
            NavigationBar()
                .background(.ultraThinMaterial) // Un fondo estándar para la barra
            
            GeometryReader { geometry in
                let size = geometry.size
                
                // Carrusel de imágenes a pantalla completa (sin cambios aquí)
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(coordinator.imageMessages) { message in
                            imageView(for: message, size: size)
                                .id(message.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .scrollPosition(id: .init(
                    get: { coordinator.detailScrollPosition },
                    set: { coordinator.detailScrollPosition = $0 }
                ))
                .onChange(of: coordinator.detailScrollPosition, coordinator.didDetailPageChanged)
                .background {
                    if let selectedMessage = coordinator.selectedMessage {
                        Rectangle()
                            .fill(.clear)
                            .anchorPreference(key: HeroKey.self, value: .bounds) { anchor in
                                return [selectedMessage.id + "DEST": anchor]
                            }
                    }
                }
                .offset(coordinator.offset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Rectangle()
                .fill(.white)
                .ignoresSafeArea()
                .opacity(1 - coordinator.dragProgress)
        }
        .overlay(alignment: .bottom) {
            BottomIndicatorView()
        }
        .opacity(coordinator.animateView ? 1 : 0)
    }
    
    // --- Vistas auxiliares ---
    
    @ViewBuilder
    func NavigationBar() -> some View {
        HStack {
            // Botón para volver atrás
            Button(action: { coordinator.toggleView(show: false) }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                Text(LocalizedKeys.Common.chat)
            }
            .foregroundStyle(Color.primary)
            
            Spacer()
            
            // Título central con nombre y fecha
            if let message = coordinator.selectedMessage {
                VStack(spacing: 2) {
                    // Determina el nombre del remitente
                    let senderName = message.senderId == coordinator.currentUserID
                    ? LocalizedKeys.ImageDetail.senderYou
                    : coordinator.otherUserName ?? LocalizedKeys.Common.unknown
                    
                    Text(senderName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    // Formatea y muestra la fecha y hora
                    if let timestamp = message.sentAt {
                        Text(formatTimestamp(timestamp))
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.left").opacity(0)
            Text(LocalizedKeys.Common.chat).opacity(0)
            
        }
        .padding(.horizontal)
        .padding(.bottom, 10) // Padding inferior para darle altura a la barra
        .safeAreaInset(edge: .top) {
            // Esto empuja la barra hacia abajo para que respete la safe area del notch
            Color.clear.frame(height: 0)
        }
    }
    
    private func formatTimestamp(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    @ViewBuilder
    func imageView(for message: Message, size: CGSize) -> some View {
        if let urlString = message.imageURL, let url = URL(string: urlString) {
            WebImage(url: url)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width, height: size.height)
                .clipped()
                // Ocultamos la imagen real hasta que la transición termine
                .opacity(coordinator.showDetailView ? 1 : 0)
        }
    }
}

/// El nuevo indicador de paginación inferior.
struct BottomIndicatorView: View {
    @Environment(UICoordinator.self) private var coordinator
    
    var body: some View {
        // Envolvemos con ScrollViewReader para tener control programático.
        ScrollViewReader { proxy in
            GeometryReader {
                let size = $0.size
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(coordinator.imageMessages) { message in
                            if let urlString = message.imageURL, let url = URL(string: urlString) {
                                let isSelected = coordinator.detailIndicatorPosition == message.id
                                
                                WebImage(url: url)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(.rect(cornerRadius: 10))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.primary, lineWidth: isSelected ? 2.5 : 0)
                                    }
                                    .scaleEffect(0.97)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .scrollTargetLayout()
                }
                .scrollPosition(id: .init(
                    get: { coordinator.detailIndicatorPosition },
                    set: { coordinator.detailIndicatorPosition = $0 }
                ))
                .safeAreaPadding(.horizontal, (size.width - 50) / 2)
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
                .allowsHitTesting(false)
                .onChange(of: coordinator.detailIndicatorPosition) { oldValue, newValue in
                    // Se activa tanto la primera vez (cuando es nil -> valor) como en los swipes.
                    if let newPosition = newValue {
                        // Usamos una animación para que el deslizamiento del indicador sea suave.
                        withAnimation(.easeInOut) {
                           proxy.scrollTo(newPosition, anchor: .center)
                        }
                    }
                }
            }
            .frame(height: 70)
            .background(.ultraThinMaterial)
        }
    }
}
