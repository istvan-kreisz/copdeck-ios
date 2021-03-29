//
//  Main.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/28/21.
//

import SwiftUI
import FirebaseFunctions

struct MainView: View {
    @EnvironmentObject var store: Store<MainState, MainAction, Main>

    var body: some View {
        TabView {
            NavigationView {
            HomeView()
                .environmentObject(store)
            }.tabItem {
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
                Text("Search")
            }

            NavigationView {
                Text("Inventory")
            }.tabItem {
                Image(systemName: "tray.2")
                    .imageScale(.large)
                Text("Inventory")
            }
        }
    }
}
