//
//  FeedView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/28/21.
//

import SwiftUI
import Combine

struct FeedView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedInventoryItemId: String?
    @State private var selectedStackId: String?

    @State private var selectedStack: Stack?
    @State private var selectedUser: ProfileData?

    @State private var isFirstLoad = true

    @StateObject private var loader = Loader()

    var feedPosts: [FeedPost] {
        store.state.feedPosts.data
    }

    var allProfiles: [ProfileData] {
        feedPosts.compactMap { $0.profileData }
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

            ForEach(allProfiles) { (profileData: ProfileData) in
                NavigationLink(destination: ProfileView(profileData: profileData) { selectedUser = nil },
                               tag: profileData.user.id,
                               selection: convertToId(_selectedUser)) { EmptyView() }
            }

            ForEach(feedPosts) { (feedPost: FeedPost) in
                if let user = feedPost.user {
                    NavigationLink(destination: SharedStackDetailView(user: user,
                                                                      stack: feedPost.stack,
                                                                      inventoryItems: feedPost.inventoryItems,
                                                                      requestInfo: store.state.requestInfo) { selectedStackId = nil },
                                   tag: feedPost.stack.id,
                                   selection: $selectedStackId) { EmptyView() }
                }
            }

            VStack(alignment: .leading, spacing: 19) {
                Text("Feed")
                    .foregroundColor(.customText1)
                    .font(.bold(size: 35))
                    .leftAligned()
                    .padding(.leading, 6)
                    .withDefaultPadding(padding: .horizontal)

                VerticalListView(bottomPadding: Styles.tabScreenBottomPadding, spacing: 0) {
                    PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                        loadFeedPosts(loadMore: false)
                    }

                    if loader.isLoading && store.state.feedPosts.isLastPage {
                        CustomSpinner(text: "Loading posts...", animate: true)
                            .padding(.top, 21)
                            .centeredHorizontally()
                    }

                    ForEach(feedPosts) { (feedPostData: FeedPost) in
                        if let user = feedPostData.user {
                            SharedStackSummaryView(selectedInventoryItemId: $selectedInventoryItemId,
                                                   selectedStackId: $selectedStackId,
                                                   stack: feedPostData.stack,
                                                   inventoryItems: feedPostData.inventoryItems,
                                                   requestInfo: store.state.requestInfo,
                                                   profileInfo: (user.name ?? "", user.imageURL)) {
                                    selectedUser = feedPostData.profileData
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.bottom, 4)
                        }
                    }

                    if store.state.feedPosts.isLastPage {
                        Text("That's it!")
                            .font(.bold(size: 14))
                            .foregroundColor(.customText2)
                            .padding(.top, 21)
                            .centeredHorizontally()
                    } else {
                        CustomSpinner(text: "Loading posts...", animate: true)
                            .padding(.top, 21)
                            .centeredHorizontally()
                            .onAppear {
                                if !feedPosts.isEmpty {
                                    loadFeedPosts(loadMore: true)
                                }
                            }
                    }
                }
                .environment(\.defaultMinListRowHeight, 1)
                .coordinateSpace(name: "pullToRefresh")
            }
        }
        .onAppear {
            if isFirstLoad {
                loadFeedPosts(loadMore: false)
                isFirstLoad = false
            }
        }
    }

    private func loadFeedPosts(loadMore: Bool) {
        store.send(.main(action: .getFeedPosts(loadMore: loadMore)), debounceDelayMs: 2000, completed: loader.getLoader())
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
