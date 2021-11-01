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
    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)

    let user: User
    let stack: Stack
    let inventoryItems: [InventoryItem]
    let requestInfo: [ScraperRequestInfo]

    let shouldDismiss: () -> Void
    
    @State private var alert: (String, String)? = nil

    var selectedInventoryItem: InventoryItem? {
        guard case let .inventoryItem(inventoryItem) = navigationDestination.destination else { return nil }
        return inventoryItem
    }

    var body: some View {
        Group {
            let showDetail = Binding<Bool>(get: { navigationDestination.show },
                                           set: { show in show ? navigationDestination.display() : navigationDestination.hide() })
            let selectedInventoryItemBinding = Binding<InventoryItem?>(get: { selectedInventoryItem },
                                                                       set: { inventoryItem in
                                                                           if let inventoryItem = inventoryItem {
                                                                               navigationDestination += .inventoryItem(inventoryItem)
                                                                           } else {
                                                                               navigationDestination.hide()
                                                                           }
                                                                       })
            NavigationLink(destination: Destination(requestInfo: requestInfo,
                                                    user: user,
                                                    navigationDestination: $navigationDestination).navigationbarHidden(),
                           isActive: showDetail) { EmptyView() }

            VerticalListView(bottomPadding: 30, spacing: 2, addHorizontalPadding: false) {
                NavigationBar(title: stack.name, isBackButtonVisible: true, style: .dark, shouldDismiss: shouldDismiss)
                    .withDefaultPadding(padding: [.horizontal, .top])

                OwnerCardView(user: user) { result in
                    switch result {
                    case let .failure(error):
                        alert = (error.title, error.message)
                    case let .success((channel, userId)):
                        navigationDestination += .chat(channel, userId)
                    }
                }

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
                                      priceName: "Price",
                                      isContentLocked: false,
                                      bestPrice: inventoryItem.copdeckPrice,
                                      selectedInventoryItem: selectedInventoryItemBinding,
                                      isSelected: false,
                                      isInSharedStack: false,
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
        .withAlert(alert: $alert)
    }
}

extension SharedStackDetailView {
    enum NavigationDestination {
        case inventoryItem(InventoryItem)
        case chat(Channel, String)
        case empty
    }

    struct Destination: View {
        let requestInfo: [ScraperRequestInfo]
        let user: User
        @Binding var navigationDestination: Navigation<NavigationDestination>

        var body: some View {
            switch navigationDestination.destination {
            case let .inventoryItem(inventoryItem):
                SharedInventoryItemView(user: user,
                                        inventoryItem: inventoryItem,
                                        requestInfo: requestInfo) { navigationDestination.hide() }
            case let .chat(channel, userId):
                MessagesView(channel: channel, userId: userId, store: DerivedGlobalStore.default)
            case .empty:
                EmptyView()
            }
        }
    }
}
