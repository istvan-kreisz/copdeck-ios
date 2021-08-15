//
//  SelectStackItemsView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import SwiftUI
import Combine

struct SelectStackItemsView: View {
    @Binding var showView: Bool
    let inventoryItems: [InventoryItem]
    let requestInfo: [ScraperRequestInfo]
    let saveChanges: ([StackItem]) -> Void
    let title: String

    @State var selectedStackItems: [StackItem]

    init(showView: Binding<Bool>,
         stack: Stack,
         inventoryItems: [InventoryItem],
         requestInfo: [ScraperRequestInfo],
         saveChanges: @escaping ([StackItem]) -> Void) {
        self._showView = showView
        self.inventoryItems = inventoryItems
        self.requestInfo = requestInfo
        self.saveChanges = saveChanges
        self.title = "Edit \(stack.name)"
        self._selectedStackItems = State<[StackItem]>(initialValue: stack.items)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            NavigationBar(showView: $showView, title: title, isBackButtonVisible: true, style: .dark)
                .withDefaultPadding(padding: .horizontal)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(inventoryItems) { inventoryItem in
                        let isSelected = Binding<Bool>(get: { selectedStackItems.map(\.inventoryItemId).contains(inventoryItem.id) },
                                                       set: { selected in
                                                           if selected {
                                                               if !selectedStackItems.map(\.inventoryItemId).contains(inventoryItem.id) {
                                                                   selectedStackItems.append(.init(inventoryItemId: inventoryItem.id))
                                                               }
                                                           } else {
                                                               selectedStackItems.removeAll(where: { $0.inventoryItemId == inventoryItem.id })
                                                           }
                                                       })
                        SelectStackItemsListItem(inventoryItem: inventoryItem,
                                                 isSelected: isSelected,
                                                 requestInfo: requestInfo)
                            .withDefaultPadding(padding: .horizontal)
                    }
                    .padding(.vertical, 6)
                    Color.clear.padding(.bottom, 130)
                }
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .withDefaultPadding(padding: .top)
        .withBackgroundColor()
        .withFloatingButton(button: RoundedButton<EmptyView>(text: "Save Changes",
                                                             width: 200,
                                                             height: 60,
                                                             color: .customBlack,
                                                             accessoryView: nil) {
                saveChanges(selectedStackItems)
                showView = false
            }
            .centeredHorizontally()
            .padding(.top, 20))
        .navigationbarHidden()
    }
}
