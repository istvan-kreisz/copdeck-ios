//
//  TabBar.swift
//  CopDeck
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct TabBar: View {
    @ObservedObject var viewRouter: ViewRouter
    
    static let width: CGFloat = 70
    
    private func tabItem(page: Page, iconName: String) -> some View {
        Button(action: { [weak viewRouter] in
            viewRouter?.currentPage = page
        }) { [weak viewRouter] in
                Image(iconName)
                    .renderingMode(.template)
                    .frame(height: 24)
                    .foregroundColor(viewRouter?.currentPage == page ? .customText1 : .customAccent1)
                    .centeredHorizontally()
        }
        .frame(width: Self.width)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            tabItem(page: .feed, iconName: "home")
            tabItem(page: .search, iconName: "search")
            tabItem(page: .inventory, iconName: "inventory")
            tabItem(page: .chat, iconName: "message")
        }
        .frame(width: Self.width * CGFloat(Page.allCases.count), height: 60)
        .background(Color.customWhite)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}
