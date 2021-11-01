//
//  SelectStackItemsView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import SwiftUI
import Combine

struct SelectStackItemsView: View {
    var inventoryItems: [InventoryItem]
    let requestInfo: [ScraperRequestInfo]
    let shouldDismiss: () -> Void
    let saveChanges: ([StackItem]) -> Void
    let title: String

    @State var selectedStackItems: [StackItem]

    init(stack: Stack,
         inventoryItems: [InventoryItem],
         requestInfo: [ScraperRequestInfo],
         shouldDismiss: @escaping () -> Void,
         saveChanges: @escaping ([StackItem]) -> Void) {
        self.inventoryItems = inventoryItems
        self.requestInfo = requestInfo
        self.shouldDismiss = shouldDismiss
        self.saveChanges = saveChanges
        self.title = "Edit \(stack.name)"
        self._selectedStackItems = State<[StackItem]>(initialValue: stack.items)
    }

    var body: some View {
        VerticalListView(bottomPadding: Styles.tabScreenBottomPadding) {
            NavigationBar(title: title, isBackButtonVisible: true, style: .dark, shouldDismiss: shouldDismiss)
                .withDefaultPadding(padding: .top)

            ForEach(inventoryItems) { (inventoryItem: InventoryItem) in
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
            }
            .padding(.vertical, 2)
            Color.clear.padding(.bottom, 130)
        }
//        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .withDefaultPadding(padding: .top)
        .withBackgroundColor()
        .withFloatingButton(button: RoundedButton<EmptyView>(text: "Save Changes",
                                                             width: 200,
                                                             height: 60,
                                                             color: .customBlack,
                                                             accessoryView: nil) {
                saveChanges(selectedStackItems)
                shouldDismiss()
            }
            .centeredHorizontally()
            .padding(.top, 20))
        .navigationbarHidden()
    }
}
