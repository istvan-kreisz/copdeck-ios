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
                CalendarContainerView(title: store.state.calendar.title, onCommit: { result in
                    if result == "hey" {
                        store.send(.calendar(action: .action1(title: "hey")))
                    } else {
                        store.send(.calendar(action: .action2))
                    }
                })
                    .navigationBarTitle("today")
//                    .environmentObject(store.derived(deriveState: \.calendar,
//                                                     deriveAction: AppAction.calendar))
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

struct CalendarContainerView: View {
    let title: String

    let onCommit: (String) -> Void

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
            Button("hey") {
                onCommit("hey")
            }
                .foregroundColor(.white)
                .frame(width: 100, height: 50)
                .background(Color.blue)
                .clipShape(Capsule())

            Button("hi") {
                onCommit("hi")
            }
                .foregroundColor(.white)
                .frame(width: 100, height: 50)
                .background(Color.blue)
                .clipShape(Capsule())
        }
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
