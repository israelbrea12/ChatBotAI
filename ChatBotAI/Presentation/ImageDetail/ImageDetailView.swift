import SwiftUI
import SDWebImageSwiftUI

struct ImageDetailView: View {
    @Environment(UICoordinator.self) private var coordinator
    
    var body: some View {
        VStack(spacing: 0) {
            // La barra de navegación se oculta al arrastrar hacia abajo.
            NavigationBar()
                .offset(y: coordinator.showDetailView ? (-120 * coordinator.dragProgress) : -120)
                .animation(.easeInOut(duration: 0.15), value: coordinator.dragProgress)
            
            GeometryReader { geometry in
                let size = geometry.size
                
                // Carrusel de imágenes a pantalla completa
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
                    // El ancla de destino ahora se actualiza dinámicamente.
                    if let selectedMessage = coordinator.selectedMessage {
                        Rectangle()
                            .fill(.clear)
                            .anchorPreference(key: HeroKey.self, value: .bounds) { anchor in
                                return [selectedMessage.id + "DEST": anchor]
                            }
                    }
                }
                // Aplicamos el offset del arrastre a este carrusel.
                .offset(coordinator.offset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // La opacidad del fondo ahora depende del progreso del arrastre.
        .background {
             Rectangle()
                .fill(.white)
                .ignoresSafeArea()
                .opacity(1 - coordinator.dragProgress)
        }
        .overlay(alignment: .bottom) {
            // El indicador inferior también se oculta al arrastrar.
            BottomIndicatorView()
                .offset(y: coordinator.showDetailView ? (120 * coordinator.dragProgress) : 120)
                .animation(.easeInOut(duration: 0.15), value: coordinator.dragProgress)
        }
        .opacity(coordinator.animateView ? 1 : 0) // Controla la visibilidad general.
    }
    
    // --- Vistas auxiliares ---
    
    @ViewBuilder
    func NavigationBar() -> some View {
        HStack {
            Button(action: { coordinator.toggleView(show: false) }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.black.opacity(0.1))
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding()
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
                                    // 2. Dibujamos el borde solo si está seleccionada
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.primary, lineWidth: isSelected ? 2.5 : 0) // El grosor cambia
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
        }
        .frame(height: 70)
        .background(.ultraThinMaterial)
    }
}
