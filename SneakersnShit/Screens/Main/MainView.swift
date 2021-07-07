//
//  Main.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/28/21.
//

import SwiftUI
import FirebaseFunctions

struct MainView: View {
    @EnvironmentObject var store: MainStore

    var body: some View {
        TabView {
            NavigationView {
                SearchView()
                    .environmentObject(store)
            }.tabItem {
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
                Text("Search")
            }

//            NavigationView {
//                InventoryView()
//                    .environmentObject(store)
//            }.tabItem {
//                Image(systemName: "tray.2")
//                    .imageScale(.large)
//                Text("Inventory")
//            }
        }
    }
}
