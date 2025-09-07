//
//  CustomMenuView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 29/5/25.
//

import SwiftUI

struct CustomMenuView<Content: View>: View {
    @Binding var config: MenuConfig
    @ViewBuilder var content: Content
    @MenuActionBuilder var actions: [MenuAction]
    @State private var animateContent: Bool = false
    @State private var animateLabels: Bool = false
    @State private var activeActionID: String?
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                Rectangle()
                    .fill(.bar)
                    .ignoresSafeArea()
                    .opacity(animateContent ? 1 : 0)
                    .allowsHitTesting(false)
            }
            .overlay {
                if animateContent {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .contentShape(.rect)
                        .onDisappear {
                            config.hideSourceView = false
                            activeActionID = actions.first?.id
                        }
                }
            }
            .overlay {
                GeometryReader {
                    MenuScrollView($0)
                    
                    if config.hideSourceView {
                        config.sourceView
                            .scaleEffect(animateContent ? 15 : 1, anchor: .bottom)
                            .offset(x: config.sourceLocation.minX, y: config.sourceLocation.minY)
                            .opacity(animateContent ? 0.25 : 1 )
                            .blur(radius: animateContent ? 130 : 0)
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                    }
                }
                .opacity(config.hideSourceView ? 1 : 0)
            }
            .onChange(of: config.showMenu) { oldValue, newValue in
                if newValue {
                    config.hideSourceView = true
                }
                
                withAnimation(.smooth(duration: 0.45, extraBounce: 0)) {
                    animateContent = newValue
                }
                
                withAnimation(.easeInOut(duration: newValue ? 0.35 : 0.15)) {
                    animateLabels = newValue
                }
            }
    }
    
    @ViewBuilder
    func MenuScrollView(_ proxy: GeometryProxy) -> some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(actions) {
                    MenuActionView($0)
                }
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
        .background {
            Rectangle()
                .foregroundStyle(.clear)
                .frame(width: proxy.size.width, height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom)
                .contentShape(.rect)
                .onTapGesture {
                    guard config.showMenu else { return }
                    config.showMenu = false
                }
                .visualEffect { content, proxy in
                    content
                        .offset(
                            x: -proxy.frame(in: .global).minX,
                            y: -proxy.frame(in: .global).minY
                        )
                }
        }
        .safeAreaPadding(.bottom, 30)
        .opacity(config.showMenu ? 1 : 0)
    }


    
    @ViewBuilder
    func MenuActionView(_ action: MenuAction) -> some View {
        let sourceLocation = config.sourceLocation
        
        HStack(spacing: 20) {
            Image(systemName: action.symbolImage)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background {
                    Circle()
                        .fill(.background)
                        .shadow(radius: 1.5)
                }
                .scaleEffect(animateContent ? 1 : 0.6)
                .opacity(animateContent ? 1 : 0)
                .blur(radius: animateContent ? 0 : 4)
            
            Text(action.text)
                .font(.system(size:19))
                .fontWeight(.medium)
                .lineLimit(1)
                .opacity(animateLabels ? 1 : 0)
                .blur(radius: animateLabels ? 0 : 4)
        }
        .visualEffect({ [animateContent] content, proxy in
            content
                .offset(
                    x: animateContent ? 0 : sourceLocation.minX - proxy.frame(in: .global).minX,
                    y: animateContent ? 0 : sourceLocation.minY - proxy.frame(in: .global).minY
                )
        })
        .frame(height: 70)
        .contentShape(.rect)
        .onTapGesture {
            action.action()
        }
    }
}

struct MenuSourceButton<Content: View>: View {
    @Binding var config: MenuConfig
    @ViewBuilder var content: Content
    var onTap: () -> ()
    var body: some View {
        content
            .contentShape(.rect)
            .onTapGesture {
                onTap()
                config.sourceView = .init(content)
                config.showMenu.toggle()
            }
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .global)
            } action: { newValue in
                config.sourceLocation = newValue
            }
            .opacity(config.hideSourceView ? 0.01 : 1)
    }
}

#Preview {
    ContentView()
}

struct MenuConfig {
    var symbolImage: String
    var sourceLocation: CGRect = .zero
    var showMenu: Bool = false
    var sourceView: AnyView = .init(EmptyView())
    var hideSourceView: Bool = false
}

struct MenuAction: Identifiable {
    private(set) var id: String = UUID().uuidString
    var symbolImage: String
    var text: LocalizedStringKey
    var action: () -> () = {}
}

@resultBuilder
struct MenuActionBuilder {
    static func buildBlock(_ components: MenuAction...) -> [MenuAction] {
        components.compactMap({ $0 })
    }
}
