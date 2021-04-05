//
//  InventoryView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 3/30/21.
//

import SwiftUI
import Combine

struct InventoryView: View {
    @EnvironmentObject var store: Store<MainState, MainAction, Main>
    @State private var selectedInventoryItemId: String?

    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(store.state.inventoryItems) { inventoryItem in
                        NavigationLink(destination: InventoryItemDetailView(inventoryItem: inventoryItem),
                                       tag: inventoryItem.id,
                                       selection: self.$selectedInventoryItemId) { EmptyView() }
                    }

                    ForEach(store.state.inventoryItems) { inventoryItem in
                        // todo: make list items generic
                        HStack {
                            ImageView(withURL: inventoryItem.images?.first ?? "", size: 80)
                                .cornerRadius(8)
                            VStack {
                                HStack {
                                    Text(inventoryItem.name)
                                        .font(.semiBold(size: 13))
                                    Spacer()
                                }
//                                HStack(spacing: 10) {
//                                    ForEach(item.storeInfo) { storeInfo in
//                                        Text(storeInfo.store.rawValue)
//                                            .font(.regular(size: 12))
//                                    }
//                                    Spacer()
//                                }
//                                .frame(maxWidth: 300)
                            }
                            Button(action: {
                                self.removeFromInventory(inventoryItem: inventoryItem)
                            }) {
                                    Text("Remove")
                                        .font(.bold(size: 18))
                                        .foregroundColor(.red)
                            }
                        }.onTapGesture {
                            selectedInventoryItemId = inventoryItem.id
                        }
                    }
                }
                .withDefaultPadding()
            }
            .frame(maxWidth: UIScreen.main.bounds.width)
        }
        .onAppear {
            store.send(.getInventoryItems)
        }
    }

    func removeFromInventory(inventoryItem: InventoryItem) {
        store.send(.removeFromInventory(inventoryItem: inventoryItem))
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        let store = AppStore(initialState: .mockAppState,
                             reducer: appReducer,
                             environment: World(isMockInstance: true))
        return Group {
            InventoryView()
                .environmentObject(store
                    .derived(deriveState: \.mainState,
                             deriveAction: AppAction.main,
                             derivedEnvironment: store.environment.main))
        }
    }
}
