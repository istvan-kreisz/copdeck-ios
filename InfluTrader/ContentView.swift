//
//  ContentView.swift
//  InfluTrader
//
//  Created by István Kreisz on 12/13/20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store<AppState, AppAction, World>

    var body: some View {
        TabView {
            NavigationView {
                SummaryContainerView()
                    .navigationBarTitle("today")
                    .environmentObject(store.derived(deriveState: \.calendar,
                                                     deriveAction: AppAction.calendar))
            }.tabItem {
                Image(systemName: "heart.fill")
                    .imageScale(.large)
                Text("today")
            }

            NavigationView {
                TrendsContainerView()
                    .navigationBarTitle("trends")
                    .environmentObject(store.derived(deriveState: \.trends,
                                                     deriveAction: AppAction.trends))
            }.tabItem {
                Image(systemName: "chevron.up.circle.fill")
                    .imageScale(.large)
                Text("trends")
            }
        }
    }
}

struct SummaryContainerView: View {
    @EnvironmentObject var store: Store<CalendarState, CalendarAction, Void>

    var body: some View {
        Text("summary")
    }
}

struct TrendsContainerView: View {
    @EnvironmentObject var store: Store<TrendsState, TrendsAction, Void>

    var body: some View {
        Text("summary")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppStore(initialState: .init(),
                                        reducer: appReducer,
                                        environment: World()))
    }
}
