//
//  Main.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/28/21.
//

import SwiftUI
import FirebaseFunctions
import Erik

struct MainView: View {
    @EnvironmentObject var store: Store<MainState, MainAction, Main>

    var body: some View {
//        TabView {
//            NavigationView {
//                HomeView()
//            }.tabItem {
//                Image(systemName: "heart.fill")
//                    .imageScale(.large)
//                Text("today")
//            }
//
//            NavigationView {
//                Text("Second view")
//            }.tabItem {
//                Image(systemName: "chevron.up.circle.fill")
//                    .imageScale(.large)
//                Text("trends")
//            }
//        }
        HomeView()
    }
}
