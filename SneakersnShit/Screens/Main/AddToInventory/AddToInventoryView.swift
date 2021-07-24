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
    @State var notes: String

    @State var inventoryItem1: InventoryItem
    @State var inventoryItem2: InventoryItem?
    @State var inventoryItem3: InventoryItem?
    @State var inventoryItem4: InventoryItem?
    @State var inventoryItem5: InventoryItem?

    var allInventoryItems: [InventoryItem?] { [inventoryItem1,
                                               inventoryItem2,
                                               inventoryItem3,
                                               inventoryItem4,
                                               inventoryItem5] }

    private var itemCount: Int {
        allInventoryItems.compactMap { $0 }.count
    }

    init(item: Item, addToInventory: Binding<Bool>) {
        self._item = State(initialValue: item)
        self._addToInventory = addToInventory

        self._name = State(initialValue: item.name ?? "")
        self._styleId = State(initialValue: item.bestStoreInfo?.sku ?? "")
        self._notes = State(initialValue: "")

        self._inventoryItem1 = State(initialValue: InventoryItem(fromItem: item))
        self._inventoryItem2 = State(initialValue: nil)
        self._inventoryItem3 = State(initialValue: nil)
        self._inventoryItem4 = State(initialValue: nil)
        self._inventoryItem5 = State(initialValue: nil)
    }

    var body: some View {
        ZStack {
            NavigationBar(title: nil, isBackButtonVisible: true, style: .dark)
                .withDefaultPadding(padding: .horizontal)
                .topAligned()
                .zIndex(1)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 20) {
                    ImageView(withURL: item.bestStoreInfo?.imageURL ?? "",
                              size: UIScreen.main.bounds.width - 80,
                              aspectRatio: nil)
                        .background(Color.white)

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
                        if let inventoryItem2 = inventoryItem2 {
                            let item = Binding<InventoryItem>(get: { inventoryItem2 }, set: { self.inventoryItem2 = $0 })
                            NewItemCard(inventoryItem: item)
                        }
                        if let inventoryItem3 = inventoryItem3 {
                            let item = Binding<InventoryItem>(get: { inventoryItem3 }, set: { self.inventoryItem3 = $0 })
                            NewItemCard(inventoryItem: item)
                        }
                        if let inventoryItem4 = inventoryItem4 {
                            let item = Binding<InventoryItem>(get: { inventoryItem4 }, set: { self.inventoryItem4 = $0 })
                            NewItemCard(inventoryItem: item)
                        }
                        if let inventoryItem5 = inventoryItem5 {
                            let item = Binding<InventoryItem>(get: { inventoryItem5 }, set: { self.inventoryItem5 = $0 })
                            NewItemCard(inventoryItem: item)
                        }
                        if itemCount != allInventoryItems.count {
                            RoundedButton(text: "Add More",
                                          size: .init(width: 110, height: 30),
                                          fontSize: 12,
                                          color: .clear,
                                          borderColor: Color.customBlue.opacity(0.4),
                                          textColor: Color.customBlue,
                                          padding: 10,
                                          accessoryView: (AnyView(ZStack {
                                              Circle()
                                                  .fill(Color.customBlue.opacity(0.2))
                                                  .frame(width: 18, height: 18)
                                              Image(systemName: "plus")
                                                  .font(.bold(size: 7))
                                                  .foregroundColor(.customBlue)
                                          }.frame(width: 18, height: 18)),
                                          .left, 10, .none)) {
                                    addMore()
                            }
                            .leftAligned()
                        }

                        TextFieldRounded(title: "notes (optional)",
                                         placeHolder: "add any notes here",
                                         style: .white,
                                         size: .large,
                                         text: $notes)
                            .padding(.top, 15)

                        RoundedButton(text: "Add \(itemCount) item\(itemCount == 1 ? "" : "s")",
                                      size: .init(width: 145, height: 60),
                                      maxSize: nil,
                                      color: .customBlack,
                                      accessoryView: nil,
                                      tapped: { addItems() })
                            .centeredHorizontally()
                            .padding(.top, 15)

                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 14)
                    .padding(.bottom, 20)
                    .background(Color.customBackground
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all))
                }
            }
        }
        .navigationbarHidden()
        .simultaneousGesture(DragGesture().onChanged {
            if abs($0.translation.height) > 0 {
                UIApplication.shared.endEditing()
            }
        })
    }

    private func addMore() {
        if inventoryItem2 == nil {
            inventoryItem2 = InventoryItem(fromItem: item)
        } else if inventoryItem3 == nil {
            inventoryItem3 = InventoryItem(fromItem: item)
        } else if inventoryItem4 == nil {
            inventoryItem4 = InventoryItem(fromItem: item)
        } else if inventoryItem5 == nil {
            inventoryItem5 = InventoryItem(fromItem: item)
        }
    }

    private func addItems() {
    }
}

struct AddToInventoryView_Previews: PreviewProvider {
    static var previews: some View {
        return AddToInventoryView(item: Item.sample, addToInventory: .constant(true))
    }
}
