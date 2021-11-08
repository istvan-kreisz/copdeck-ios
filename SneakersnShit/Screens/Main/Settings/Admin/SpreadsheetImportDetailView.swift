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
            List {
                NavigationBar(title: "Errors", isBackButtonVisible: true, style: .dark) {
                    presentationMode.wrappedValue.dismiss()
                }
                .withDefaultPadding(padding: [.top, .horizontal])
                .listRow(backgroundColor: .customWhite)

                Text("Errors: ")
                    .font(.bold(size: 18))
                    .foregroundColor(.customText1)
                    .padding(.vertical, 10)
                    .withDefaultPadding(padding: .horizontal)
                    .listRow(backgroundColor: .customWhite)

                Text(text)
                    .font(.regular(size: 15))
                    .foregroundColor(.customText1)
                    .withDefaultPadding(padding: .horizontal)
                    .listRow(backgroundColor: .customWhite)

                Text("Items: ")
                    .font(.bold(size: 18))
                    .foregroundColor(.customText1)
                    .padding(.vertical, 10)
                    .withDefaultPadding(padding: .horizontal)
                    .listRow(backgroundColor: .customWhite)

                if loader.isLoading {
                    CustomSpinner(text: "Loading", animate: true)
                        .withDefaultPadding(padding: .horizontal)
                        .listRow(backgroundColor: .customWhite)
                }

                ForEach(inventoryItems) { (inventoryItem: InventoryItem) in
                    InventoryListItem(inventoryItem: inventoryItem,
                                      priceName: nil,
                                      isContentLocked: false,
                                      bestPrice: nil,
                                      selectedInventoryItem: $selectedInventoryItem,
                                      isSelected: false,
                                      isInSharedStack: false,
                                      isEditing: .constant(false)) {}
                }
                .withDefaultPadding(padding: .horizontal)
                .listRow(backgroundColor: .customWhite)

                Spacer()
            }
        }
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
        AppStore.default.send(.main(action: .getImportedInventoryItems(importedUserId: userId, completion: { result in
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
