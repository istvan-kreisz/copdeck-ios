//
//  SettingsView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button(action: {
            store.send(.authentication(action: .signOut))
        }, label: {
            Text("bye")
        })
        .onChange(of: store.state.user) { user in
            if user == nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            SettingsView()
                .environmentObject(AppStore.default)
        }
    }
}
