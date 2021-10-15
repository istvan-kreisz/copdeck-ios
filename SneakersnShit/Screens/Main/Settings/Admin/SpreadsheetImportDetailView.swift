//
//  SpreadsheetImportDetailView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/30/21.
//

import SwiftUI

struct SpreadsheetImportDetailView: View {
    let text: String
    let userId: String
    @State var inventoryItems: [InventoryItem] = []
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: DerivedGlobalStore

    @State var selectedInventoryItem: InventoryItem?
    @State private var error: (String, String)? = nil
    
    @State private var isFirstShow = true

    @StateObject private var loader = Loader()

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })
        let showInventoryItemDetail = Binding<Bool>(get: { selectedInventoryItem != nil }, set: { new in
            selectedInventoryItem = new ? selectedInventoryItem : nil
        })
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink("", isActive: showInventoryItemDetail) {
                InventoryItemDetailView(inventoryItem: selectedInventoryItem ?? .empty, importSummaryMode: true, isInSharedStack: false) {
                    selectedInventoryItem = nil
                }
            }
            NavigationBar(title: "Errors", isBackButtonVisible: true, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .withDefaultPadding(padding: .top)

            Text("Errors: ")
                .font(.bold(size: 18))
                .foregroundColor(.customText1)
                .padding(.vertical, 10)

            Text(text)
                .font(.regular(size: 15))
                .foregroundColor(.customText1)

            Text("Items: ")
                .font(.bold(size: 18))
                .foregroundColor(.customText1)
                .padding(.vertical, 10)
            
            if loader.isLoading {
                CustomSpinner(text: "Loading", animate: true)
            }

            ForEach(inventoryItems) { (inventoryItem: InventoryItem) in
                InventoryListItem(inventoryItem: inventoryItem,
                                  bestPrice: nil,
                                  selectedInventoryItem: $selectedInventoryItem,
                                  isSelected: false,
                                  isInSharedStack: false,
                                  isEditing: .constant(false),
                                  requestInfo: store.globalState.requestInfo) {}
            }

            Spacer()
        }
        .withDefaultPadding(padding: .horizontal)
        .onAppear {
            if isFirstShow {
                isFirstShow = false
                refreshInventoryItems()
            }
        }
        .alert(isPresented: presentErrorAlert) {
            let title = error?.0 ?? ""
            let description = error?.1 ?? ""
            return Alert(title: Text(title), message: Text(description), dismissButton: Alert.Button.cancel(Text("Okay")))
        }
        .navigationbarHidden()
    }

    private func refreshInventoryItems() {
        let loader = loader.getLoader()
        store.send(.main(action: .getImportedInventoryItems(importedUserId: userId, completion: { result in
            switch result {
            case let .success(inventoryItems):
                self.inventoryItems = inventoryItems
            case let .failure(error):
                self.error = ("Error", error.localizedDescription)
            }
            loader(.success(()))

        })))
    }
}
