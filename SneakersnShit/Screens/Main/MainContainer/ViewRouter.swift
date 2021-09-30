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

enum Page: Int {
    case feed = 0
    case search
    case inventory
}
