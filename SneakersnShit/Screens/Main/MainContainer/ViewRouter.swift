//
//  ViewRouter.swift
//  CopDeck
//
//  Created by István Kreisz on 7/11/21.
//

import Foundation

class ViewRouter: ObservableObject {
    @Published var currentPage: Page = .search
}

enum Page {
    case home
    case search
    case inventory
}
