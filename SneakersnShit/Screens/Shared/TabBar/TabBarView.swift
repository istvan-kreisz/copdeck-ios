//
//  TabBarView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/17/21.
//

import SwiftUI
import UIKit

fileprivate struct UITabBarControllerWrapper: UIViewControllerRepresentable {
    var viewControllers: [UIViewController]

    func makeUIViewController(context: UIViewControllerRepresentableContext<UITabBarControllerWrapper>) -> UITabBarController {
        let tabBar = UITabBarController()
        return tabBar
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: UIViewControllerRepresentableContext<UITabBarControllerWrapper>) {
        uiViewController.setViewControllers(viewControllers, animated: true)
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

struct TabBarElementItem {
    var title: String
    var systemImageName: String
}

protocol TabBarElementView: View {
    associatedtype Content
    var content: Content { get set }
    var tabBarElementItem: TabBarElementItem { get set }
}

struct TabBarElement: TabBarElementView {
    var content: AnyView

    var tabBarElementItem: TabBarElementItem

    init<Content: View>(tabBarElementItem: TabBarElementItem, @ViewBuilder _ content: () -> Content) {
        self.tabBarElementItem = tabBarElementItem
        self.content = AnyView(content())
    }

    var body: some View { content }
}

struct TabBarElement_Previews: PreviewProvider {
    static var previews: some View {
        TabBarElement(tabBarElementItem: .init(title: "Test", systemImageName: "house.fill")) {
            Text("Hello, world!")
        }
    }
}

struct UITabBarWrapper: View {
    var controllers: [UIHostingController<TabBarElement>]

    init(_ elements: [TabBarElement]) {
        controllers = elements.enumerated().map {
            let hostingController = UIHostingController(rootView: $1)
            hostingController.tabBarItem = UITabBarItem(title: $1.tabBarElementItem.title,
                                                        image: UIImage.init(systemName: $1.tabBarElementItem.systemImageName),
                                                        tag: $0)
            return hostingController
        }
    }

    var body: some View {
        UITabBarControllerWrapper(viewControllers: controllers)
    }
}

struct UITabBarWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UITabBarWrapper([TabBarElement(tabBarElementItem:
            TabBarElementItem(title: "Test 1", systemImageName: "house.fill")) {
                Text("Test 1 Text")
        }])
    }
}
