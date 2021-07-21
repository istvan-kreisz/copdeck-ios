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
                    NavigationBar(title: nil, isBackButtonVisible: true, style: .dark)
                        .withDefaultPadding(padding: .horizontal)
                        .topAligned()
                }

                ZStack {
                    Color.customBackground.edgesIgnoringSafeArea(.all)
                    VStack(alignment: .center, spacing: 8) {
                        Text("Add To Inventory")
                            .font(.bold(size: 30))
                            .foregroundColor(.customText1)
                            .padding(.bottom, 8)
                        HStack(spacing: 10) {
                            TextFieldRounded(title: "name", placeHolder: "name", text: $name)
                            TextFieldRounded(title: "styleid (optional)", placeHolder: "styleid", text: $styleId)
                        }
                        Form {
//                            VStack(alignment: .center, spacing: 10) {
//                                Section {
//                            HStack(alignment: .center, spacing: 10) {

                                TextFieldRounded(title: "purchase price",
                                                 placeHolder: inventoryItem1.purchasePrice.asString,
                                                 backgroundColor: .customAccent4,
                                                 text: $inventoryItem1.name)
                                TextFieldRounded(title: "purchase price",
                                                 placeHolder: inventoryItem1.purchasePrice.asString,
                                                 backgroundColor: .customAccent4,
                                                 text: $inventoryItem1.name)

//                                    GroupBox {
//                                        DisclosureGroup("Menu 1") {
//                                            Text("Item 1")
//                                            Text("Item 2")
//                                            Text("Item 3")
//                                            Text("Item 3")
//                                            Text("Item 3")
//                                            Text("Item 3")
//                                            Text("Item 3")
//                                        }
//                                    }
//                            }
//                                }
//                            }
                        }
//                        .padding(.vertical, 6)
//                        .padding(.horizontal, 10)
//                        .background(Color.white)
//                        .cornerRadius(12)
//                        .withDefaultShadow()
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 14)
                    .padding(.bottom, 20)
                }
            }
        }
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
        let storeInfo = Item.StoreInfo(name: "Stockx",
                                       sku: "GHVDY45",
                                       slug: "",
                                       retailPrice: 234,
                                       brand: "Adidas",
                                       store: Store(id: .stockx, name: .StockX),
                                       imageURL: "",
                                       url: "",
                                       sellUrl: "",
                                       buyUrl: "",
                                       productId: "")
        let item = Item(id: "GHVDY45",
                        storeInfo: [storeInfo],
                        storePrices: [],
                        ownedByCount: 0,
                        priceAlertCount: 0,
                        created: 0,
                        updated: 0,
                        name: "yolo",
                        retailPrice: 12,
                        imageURL: nil)
        return AddToInventoryView(item: item, addToInventory: .constant(true))
    }
}
