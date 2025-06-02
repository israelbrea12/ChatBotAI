//
//  FloatingTabView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/6/25.
//

import SwiftUI

protocol FLoatingTabProtocol {
    var symbolImage: String { get }
    var tabTitle: String { get }
}

fileprivate class FloatingTabViewHelper: ObservableObject {
    @Published var hideTabBar: Bool = false
}

fileprivate struct HideFloatingTabBarModifier: ViewModifier {
    var status: Bool
    @EnvironmentObject private var helper: FloatingTabViewHelper
    func body(content: Content) -> some View {
        content.onChange(of: status, initial: true) { oldValue, newValue in
            helper.hideTabBar = newValue
        }
    }
}

extension View {
    func hideFloatingTabBar(_ status: Bool) -> some View {
        self
            .modifier(HideFloatingTabBarModifier(status: status))
    }
}

struct FloatingTabView<Content: View, Value: CaseIterable & Hashable & FLoatingTabProtocol>: View where Value.AllCases:  RandomAccessCollection {
    var config: FloatingTabConfig
    @Binding var selection: Value
    var content: (Value, CGFloat) -> Content // This return the height of the floating tab bar. With this information, we can add additional bottom padding to the tab views since they are floating tab views.
    
    init(config: FloatingTabConfig = .init(), selection: Binding<Value>, @ViewBuilder content: @escaping (Value, CGFloat) -> Content) {
        self.config = config
        self._selection = selection
        self.content = content
    }
    
    @State private var tabBarSize: CGSize = .zero
    @StateObject private var helper: FloatingTabViewHelper = .init()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if #available(iOS 18, *) {
                /// New Tab View
                TabView(selection: $selection) {
                    ForEach(Value.allCases, id: \.hashValue) { tab in
                        content(tab, tabBarSize.height)
                        /// Hiding Native Tab Bar
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                }
            } else {
                /// Old Tab View
                TabView(selection: $selection) {
                    ForEach(Value.allCases, id: \.hashValue) { tab in
                        content(tab, tabBarSize.height)
                        /// Old tag type tab view
                            .tag(tab)
                        /// Hiding Native Tab Bar
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
            }
            FloatingTabBar(config: config, activeTab: $selection)
                .frame(maxWidth: .infinity)
                .onGeometryChange(for: CGSize.self) {
                    $0.size
                } action: { newValue in
                    tabBarSize = newValue
                }
                .offset(y: helper.hideTabBar ? (tabBarSize.height + 100) : 0)
                .animation(config.tabAnimation, value: helper.hideTabBar)

        }
        .environmentObject(helper)
    }
}

struct FloatingTabConfig {
    var activeTint: Color = .blue
    var activeBackgroundTint: Color = .blue
    var inactiveTint: Color = .gray
    var tabAnimation: Animation = .smooth(duration: 0.35, extraBounce: 0)
    var backgroundColor: Color = .gray.opacity(0.1)
    var insetAmount: CGFloat = 6
    var isTranslucent: Bool = true
    var hPadding: CGFloat = 15
    var vPadding: CGFloat = 5
}

fileprivate struct FloatingTabBar<Value: CaseIterable & Hashable & FLoatingTabProtocol>: View where Value.AllCases: RandomAccessCollection {
    var config: FloatingTabConfig
    @Binding var activeTab: Value
    @Namespace private var animation
    @State private var toggleSymbolEffect: [Bool] = Array(repeating: false, count: Value.allCases.count)
    
    var body: some View {
        VStack(spacing: 0) {
            // Línea separadora
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
            
            HStack(spacing: 0) {
                ForEach(Value.allCases, id: \.hashValue) { tab in
                    let isActive = activeTab == tab
                    let index = (Value.allCases.firstIndex(of: tab) as? Int) ?? 0
                    
                    VStack(spacing: 4) {
                        Image(systemName: tab.symbolImage)
                            .font(.title3)
                            .foregroundStyle(isActive ? config.activeTint : config.inactiveTint)
                            .symbolEffect(.bounce.byLayer.down, value: toggleSymbolEffect[index])
                        Text(tab.tabTitle)
                            .font(.caption2)
                            .foregroundColor(isActive ? config.activeTint : config.inactiveTint)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        activeTab = tab
                        toggleSymbolEffect[index].toggle()
                    }
                }
            }
            .padding(.vertical, config.insetAmount)
            .frame(height: 60)
            .background(
                config.isTranslucent
                ? Color(.systemBackground).opacity(0.95)
                : config.backgroundColor
            )
        }
    }
}

