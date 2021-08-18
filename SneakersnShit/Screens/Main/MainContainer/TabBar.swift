//
//  TabBar.swift
//  CopDeck
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct TabBar: View {
    @ObservedObject var viewRouter: ViewRouter

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button(action: { [weak viewRouter] in
                viewRouter?.currentPage = 0
            }) { [weak viewRouter] in
                    Image("home")
                        .renderingMode(.template)
                        .frame(height: 24)
                        .foregroundColor(viewRouter?.currentPage == 0 ? .customText1 : .customAccent1)
                        .centeredHorizontally()
            }
            .frame(width: 82)
            Button(action: { [weak viewRouter] in
                viewRouter?.currentPage = 1
            }) { [weak viewRouter] in
                    Image("search")
                        .renderingMode(.template)
                        .frame(height: 24)
                        .foregroundColor(viewRouter?.currentPage == 1 ? .customText1 : .customAccent1)
                        .centeredHorizontally()
            }
            .frame(width: 82)
            Button(action: { [weak viewRouter] in
                viewRouter?.currentPage = 2
            }) { [weak viewRouter] in
                    Image("inventory")
                        .renderingMode(.template)
                        .frame(height: 24)
                        .foregroundColor(viewRouter?.currentPage == 2 ? .customText1 : .customAccent1)
                        .centeredHorizontally()
            }
            .frame(width: 82)
        }
        .frame(width: 246, height: 60)
        .background(Color.customWhite)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}
