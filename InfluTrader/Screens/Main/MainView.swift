//
//  Main.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/28/21.
//

import SwiftUI
import FirebaseFunctions

struct MainView: View {
    @EnvironmentObject var store: Store<MainState, FunctionAction, Main>

    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }.tabItem {
                Image(systemName: "heart.fill")
                    .imageScale(.large)
                Text("today")
            }

            NavigationView {
                Text("Second view")
            }.tabItem {
                Image(systemName: "chevron.up.circle.fill")
                    .imageScale(.large)
                Text("trends")
            }
        }
        .onAppear {
            store.send(.getMainFeedData)
        }
    }
}
