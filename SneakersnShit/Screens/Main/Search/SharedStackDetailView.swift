//
//  SharedStackDetailView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import SwiftUI
import Combine

struct SharedStackDetailView: View {
    private static let profileImageSize: CGFloat = 38

    let user: User
    let stack: Stack
    let inventoryItems: [InventoryItem]
    let requestInfo: [ScraperRequestInfo]

    let shouldDismiss: () -> Void

    @State var selectedInventoryItemId: String?

    var body: some View {
        Group {
            ForEach(inventoryItems) { (inventoryItem: InventoryItem) in
                NavigationLink(destination: SharedInventoryItemView(user: user,
                                                                    inventoryItem: inventoryItem,
                                                                    requestInfo: requestInfo) { selectedInventoryItemId = nil },
                               tag: inventoryItem.id,
                               selection: $selectedInventoryItemId) { EmptyView() }
            }

            VerticalListView(bottomPadding: 30, spacing: 2, addHorizontalPadding: false) {
                NavigationBar(title: stack.name, isBackButtonVisible: true, style: .dark, shouldDismiss: shouldDismiss)
                    .withDefaultPadding(padding: .horizontal)

                OwnerCardView(user: user)

                if let caption = stack.caption {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("notes")
                                .font(.regular(size: 12))
                                .foregroundColor(.customText2)
                            Text(caption)
                                .font(.regular(size: 14))
                                .foregroundColor(.customText1)
                        }
                        Spacer()
                    }
                    .asCard()
                    .withDefaultPadding(padding: .horizontal)
                    .padding(.vertical, 6)
                }

                ForEach(inventoryItems) { (inventoryItem: InventoryItem) in
                    InventoryListItem(inventoryItem: inventoryItem,
                                      bestPrice: inventoryItem.copdeckPrice.map { .init(price: $0.price.price, currencyCode: $0.price.currencyCode) },
                                      selectedInventoryItemId: $selectedInventoryItemId,
                                      isSelected: false,
                                      isEditing: .constant(false),
                                      requestInfo: requestInfo) {}
                }
                .padding(.vertical, 2)
                .withDefaultPadding(padding: .horizontal)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .withDefaultPadding(padding: .top)
        .withBackgroundColor()
        .navigationbarHidden()
    }
}
