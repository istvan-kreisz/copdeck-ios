//
//  InventoryView.swift
//  CopDeck
//
//  Created by István Kreisz on 3/30/21.
//

import SwiftUI
import Combine

struct InventoryView: View {
    @EnvironmentObject var authStore: AppStore
    @State private var selectedInventoryItemId: String?

    var body: some View {
        ZStack {
//            NavigationLink("",
//                           destination: AddToInventoryView(item: item, addToInventory: $addToInventory),
//                           isActive: $addToInventory)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 20) {
                    Button("Sign out") {
                        authStore.send(.authentication(action: .signOut))
                    }
                }
            }
        }
    }

//    func deleteFromInventory(inventoryItem: InventoryItem) {
//        store.send(.removeFromInventory(inventoryItem: inventoryItem))
//    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            InventoryView()
                .environmentObject(AppStore.default)
        }
    }
}
