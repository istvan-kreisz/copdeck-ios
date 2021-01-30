//
//  Main.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/28/21.
//

import SwiftUI
import FirebaseFunctions

struct MainView: View {
    @EnvironmentObject var store: Store<AppState, AppAction, World>

    let functions = Functions.functions()

    func loadView() {
        functions.useEmulator(withHost: "http://istvans-macbook-pro-2.local", port: 5001)
        functions.httpsCallable("getMainFeedData").call(["userId": "wTHauqSNruQewLr4FfB6k0tVIAg2"]) { result, error in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print(message)
                    print(details)
                }
            }
            if let result = result?.data as? [String: Any], let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) {
                do {
                    let mainFeed = try JSONDecoder().decode(MainFeed.self, from: jsonData)
                    print(mainFeed)
                } catch {
                    print(error)
                    print(result)
                }
                
            }
        }
    }

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
        .onTapGesture {
            print("------------------")
            print("------------------")
            loadView()
        }
    }
}
