//
//  Main.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/28/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var store: Store<AppState, AppAction, World>

    var body: some View {
        TabView {
            NavigationView {
                Button("button 1") {
                    print("button 1")
                }
            }.tabItem {
                Image(systemName: "heart.fill")
                    .imageScale(.large)
                Text("today")
            }

            NavigationView {
                Button("button 2") {
                    print("button 2")
                }
            }.tabItem {
                Image(systemName: "chevron.up.circle.fill")
                    .imageScale(.large)
                Text("trends")
            }
        }
    }
}
