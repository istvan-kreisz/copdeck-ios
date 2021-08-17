//
//  TabBarView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/17/21.
//

import SwiftUI
import UIKit

struct TabBarElementItem {
    var title: String
    var systemImageName: String
}

protocol TabBarElementView: View {
    associatedtype Content
    var content: Content { get set }
    var tabBarElementItem: TabBarElementItem { get set }
}

fileprivate struct UITabBarControllerWrapper: UIViewControllerRepresentable {
    var viewControllers: [UIViewController]
    @Binding var selectedIndex: Int

    func makeUIViewController(context: UIViewControllerRepresentableContext<UITabBarControllerWrapper>) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.isHidden = true
        tabBarController.viewControllers = viewControllers
        return tabBarController
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: UIViewControllerRepresentableContext<UITabBarControllerWrapper>) {
        uiViewController.selectedIndex = selectedIndex
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: UITabBarControllerWrapper

        init(_ controller: UITabBarControllerWrapper) {
            parent = controller
        }
    }
}

struct TabBarElement<Content: View>: TabBarElementView {
    var content: Content

    var tabBarElementItem: TabBarElementItem

    init(tabBarElementItem: TabBarElementItem, @ViewBuilder _ content: () -> Content) {
        self.tabBarElementItem = tabBarElementItem
        self.content = content()
    }

    var body: some View { content }
}

struct UITabBarWrapper<Tab1: View, Tab2: View, Tab3: View>: View {
    let controller1: UIHostingController<TabBarElement<Tab1>>
    let controller2: UIHostingController<TabBarElement<Tab2>>
    let controller3: UIHostingController<TabBarElement<Tab3>>
    @Binding var selectedIndex: Int

    init(selectedIndex: Binding<Int>,
         _ tabs: () -> (tab1: TabBarElement<Tab1>, tab2: TabBarElement<Tab2>, tab3: TabBarElement<Tab3>)) {
        self._selectedIndex = selectedIndex
        let tabs = tabs()
        controller1 = UIHostingController(rootView: tabs.tab1)
        controller1.tabBarItem = UITabBarItem(title: tabs.tab1.tabBarElementItem.title,
                                              image: UIImage(systemName: tabs.tab1.tabBarElementItem.systemImageName),
                                              tag: 0)

        controller2 = UIHostingController(rootView: tabs.tab2)
        controller2.tabBarItem = UITabBarItem(title: tabs.tab2.tabBarElementItem.title,
                                              image: UIImage(systemName: tabs.tab2.tabBarElementItem.systemImageName),
                                              tag: 0)

        controller3 = UIHostingController(rootView: tabs.tab3)
        controller3.tabBarItem = UITabBarItem(title: tabs.tab3.tabBarElementItem.title,
                                              image: UIImage(systemName: tabs.tab3.tabBarElementItem.systemImageName),
                                              tag: 0)
    }

    var body: some View {
        UITabBarControllerWrapper(viewControllers: [controller1, controller2, controller3], selectedIndex: $selectedIndex)
    }
}

// @resultBuilder
// enum TabBuilder {
//    static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleView<(C0, C1, C2)> where C0: View, C1: View, C2: View {
//        TupleView((c0, c1, c2))
//    }
// }

