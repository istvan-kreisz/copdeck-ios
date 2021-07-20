//
//  AddToInventoryView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct AddToInventoryView: View {
    @EnvironmentObject var store: AppStore
    @State var item: Item
    @State var name: String
    @State var styleId: String

    @Binding var addToInventory: Bool

    @StateObject private var loader = Loader()

    init(item: Item, addToInventory: Binding<Bool>) {
        self._item = State(initialValue: item)
        self._addToInventory = addToInventory
        self._name = State(initialValue: item.name ?? "")
        self._styleId = State(initialValue: item.bestStoreInfo?.sku ?? "")
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 20) {
                ImageView(withURL: item.bestStoreInfo?.imageURL ?? "", size: UIScreen.main.bounds.width - 80, aspectRatio: nil)
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
