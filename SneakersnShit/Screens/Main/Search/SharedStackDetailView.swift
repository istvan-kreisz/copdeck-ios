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

    @State var navigationDestination: NavigationDestination?

    let user: User
    let stack: Stack
    let inventoryItems: [InventoryItem]
    let requestInfo: [ScraperRequestInfo]

    let shouldDismiss: () -> Void

    var selectedInventoryItem: InventoryItem? {
        guard case let .inventoryItem(inventoryItem) = navigationDestination else { return nil }
        return inventoryItem
    }

    var body: some View {
        Group {
            let showDetail = Binding<Bool>(get: { navigationDestination != nil },
                                           set: { show in navigationDestination = show ? navigationDestination : nil })
            let selectedInventoryItemBinding = Binding<InventoryItem?>(get: { selectedInventoryItem },
                                                                       set: { inventoryItem in
                                                                           navigationDestination = inventoryItem.map { .inventoryItem($0) } ?? nil
                                                                       })
            NavigationLink(destination: Destination(requestInfo: requestInfo,
                                                    user: user,
                                                    navigationDestination: $navigationDestination),
                           isActive: showDetail) { EmptyView() }

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
                                      selectedInventoryItem: selectedInventoryItemBinding,
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

extension SharedStackDetailView {
    enum NavigationDestination {
        case inventoryItem(InventoryItem)
    }

    struct Destination: View {
        let requestInfo: [ScraperRequestInfo]
        let user: User
        @Binding var navigationDestination: NavigationDestination?

        var body: some View {
            switch navigationDestination {
            case let .inventoryItem(inventoryItem):
                SharedInventoryItemView(user: user,
                                        inventoryItem: inventoryItem,
                                        requestInfo: requestInfo) { navigationDestination = nil }
            case .none:
                EmptyView()
            }
        }
    }
}
