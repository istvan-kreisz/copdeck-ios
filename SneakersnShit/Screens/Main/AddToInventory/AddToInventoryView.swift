//
//  AddToInventoryView.swift
//  CopDeck
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct AddToInventoryView: View {
    @EnvironmentObject var store: AppStore
    @State var item: Item
    @Binding var addToInventory: Bool

    @State var name: String
    @State var styleId: String

    @State var inventoryItem1: InventoryItem
    @State var inventoryItem2: InventoryItem?
    @State var inventoryItem3: InventoryItem?
    @State var inventoryItem4: InventoryItem?
    @State var inventoryItem5: InventoryItem?

    private var itemCount: Int {
        [inventoryItem1, inventoryItem2, inventoryItem3, inventoryItem4, inventoryItem5]
            .compactMap { $0 }
            .count
    }

    init(item: Item, addToInventory: Binding<Bool>) {
        self._item = State(initialValue: item)
        self._addToInventory = addToInventory

        self._name = State(initialValue: item.name ?? "")
        self._styleId = State(initialValue: item.bestStoreInfo?.sku ?? "")

        self._inventoryItem1 = State(initialValue: InventoryItem(from: item))
        self._inventoryItem2 = State(initialValue: nil)
        self._inventoryItem3 = State(initialValue: nil)
        self._inventoryItem4 = State(initialValue: nil)
        self._inventoryItem5 = State(initialValue: nil)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 20) {
                ZStack {
                    ImageView(withURL: item.bestStoreInfo?.imageURL ?? "",
                              size: UIScreen.main.bounds.width - 80,
                              aspectRatio: nil)
                        .background(Color.white)
                    NavigationBar(title: nil, isBackButtonVisible: true, style: .dark)
                        .withDefaultPadding(padding: .horizontal)
                        .topAligned()
                }.zIndex(1)

                ZStack {
                    Color.customBackground
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    VStack(alignment: .center, spacing: 8) {
                        Text("Add To Inventory")
                            .font(.bold(size: 30))
                            .foregroundColor(.customText1)
                            .padding(.bottom, 8)
                        HStack(spacing: 10) {
                            TextFieldRounded(title: "name",
                                             placeHolder: "name",
                                             style: .white,
                                             text: $name)
                            TextFieldRounded(title: "styleid (optional)",
                                             placeHolder: "styleid",
                                             style: .white,
                                             text: $styleId)
                        }
                        NewItemCard(inventoryItem: $inventoryItem1)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 14)
                    .padding(.bottom, 20)
                    .background(Color.customBackground.frame(maxWidth: .infinity,
                                                             minHeight: 10000,
                                                             maxHeight: .infinity).edgesIgnoringSafeArea(.all))
                }
            }
        }
        .navigationbarHidden()
        .simultaneousGesture(DragGesture().onChanged {
            if abs($0.translation.height) > 0 {
                UIApplication.shared.endEditing()
            }
        })
        .onAppear {
//            updateItem(newItem: store.state.selectedItem)
//            refreshPrices()
        }
    }
}

struct AddToInventoryView_Previews: PreviewProvider {
    static var previews: some View {
        return AddToInventoryView(item: Item.sample, addToInventory: .constant(true))
    }
}
