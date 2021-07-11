//
//  ViewRouter.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/11/21.
//

import Foundation

class ViewRouter: ObservableObject {
    @Published var currentPage: Page = .home
}

enum Page {
    case home
    case search
    case inventory
}
