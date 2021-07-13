//
//  TabBar.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct TabBar: View {
    @ObservedObject var viewRouter: ViewRouter

    var body: some View {
        VStack {
            Spacer()
                .layoutPriority(2)
            HStack(alignment: .center, spacing: 10) {
                Button(action: {
                    viewRouter.currentPage = .home
                }) {
                        Image("home")
                            .renderingMode(.template)
                            .frame(height: 24)
                            .foregroundColor(viewRouter.currentPage == .home ? .customText1 : .customAccent1)
                            .centeredHorizontally()
                }
                .frame(width: 82)
                Button(action: {
                    viewRouter.currentPage = .search
                }) {
                        Image("search")
                            .renderingMode(.template)
                            .frame(height: 24)
                            .foregroundColor(viewRouter.currentPage == .search ? .customText1 : .customAccent1)
                            .centeredHorizontally()
                }
                .frame(width: 82)
                Button(action: {
                    viewRouter.currentPage = .inventory
                }) {
                        Image("inventory")
                            .renderingMode(.template)
                            .frame(height: 24)
                            .foregroundColor(viewRouter.currentPage == .inventory ? .customText1 : .customAccent1)
                            .centeredHorizontally()
                }
                .frame(width: 82)
            }
            .frame(width: 246, height: 60)
            .background(Color.white)
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
            .layoutPriority(2)
            Spacer(minLength: 35)
        }
    }
}
