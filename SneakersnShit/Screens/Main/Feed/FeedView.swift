//
//  FeedView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/28/21.
//

import SwiftUI
import Combine

var yo = true

struct FeedView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedInventoryItemId: String?
    @State private var selectedStackId: String?

    @State private var selectedStack: Stack?

    var feedPosts: [FeedPostData] {
        store.state.feedPosts
    }

    var stacks: [Stack] {
        store.state.feedPosts.flatMap { $0.stack }
    }

    var inventoryItems: [InventoryItem] {
        feedPosts.flatMap { $0.inventoryItems }
    }

    func user(for inventoryItem: InventoryItem) -> User? {
        feedPosts.first(where: { $0.stack.itemIds.contains(inventoryItem.id) })?.user
    }

    var body: some View {
        Group {
            ForEach(inventoryItems) { (inventoryItem: InventoryItem) in
                if let user = user(for: inventoryItem) {
                    NavigationLink(destination: SharedInventoryItemView(user: user,
                                                                        inventoryItem: inventoryItem,
                                                                        requestInfo: store.state.requestInfo) { selectedInventoryItemId = nil },
                                   tag: inventoryItem.id,
                                   selection: $selectedInventoryItemId) { EmptyView() }
                }
            }

            ForEach(feedPosts) { (feedPost: FeedPostData) in
                NavigationLink(destination: SharedStackDetailView(user: feedPost.user,
                                                                  stack: feedPost.stack,
                                                                  inventoryItems: feedPost.inventoryItems,
                                                                  requestInfo: store.state.requestInfo) { selectedStackId = nil },
                               tag: feedPost.stack.id,
                               selection: $selectedStackId) { EmptyView() }
            }

            VStack(alignment: .leading, spacing: 19) {
                Text("Feed")
                    .foregroundColor(.customText1)
                    .font(.bold(size: 35))
                    .leftAligned()
                    .padding(.leading, 6)
                    .withDefaultPadding(padding: .horizontal)

                VerticalListView(bottomPadding: Styles.tabScreenBottomPadding, spacing: 0, addListRowStyling: false) {
                    ForEach(store.state.feedPosts) { (feedPostData: FeedPostData) in
                        SharedStackSummaryView(selectedInventoryItemId: $selectedInventoryItemId,
                                               selectedStackId: $selectedStackId,
                                               stack: feedPostData.stack,
                                               inventoryItems: feedPostData.inventoryItems,
                                               requestInfo: store.state.requestInfo,
                                               profileInfo: (feedPostData.user.name ?? "", feedPostData.user.imageURL))
                            .buttonStyle(PlainButtonStyle())
                            .padding(.bottom, 8)
                            .listRow()
                    }
                }
            }
        }
        .onAppear {
            if yo {
                yo = false
                store.send(.main(action: .getFeedPosts))
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            FeedView()
                .environmentObject(AppStore.default)
        }
    }
}
