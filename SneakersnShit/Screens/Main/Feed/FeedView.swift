//
//  FeedView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/28/21.
//

import SwiftUI
import Combine

struct FeedView: View {
    @EnvironmentObject var store: FeedStore
    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)

    @State private var isFirstLoad = true

    @StateObject private var loader = Loader()

    var selectedInventoryItem: InventoryItem? {
        guard case let .inventoryItem(inventoryItem) = navigationDestination.destination else { return nil }
        return inventoryItem
    }

    var selectedStack: Stack? {
        guard case let .feedPost(feedPost) = navigationDestination.destination else { return nil }
        return feedPost.stack
    }

    var feedPosts: [FeedPost] {
        store.state.feedPosts.data
    }

    var allProfiles: [ProfileData] {
        feedPosts.compactMap { $0.profileData }
    }

    var inventoryItems: [InventoryItem] {
        feedPosts.flatMap { $0.inventoryItems }
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
            let selectedStackBinding = Binding<Stack?>(get: { selectedStack },
                                                       set: { stack in
                                                           if let feedPost = store.state.feedPosts.data.first(where: { $0.stack.id == stack?.id }) {
                                                               navigationDestination += .feedPost(feedPost)
                                                           } else {
                                                            navigationDestination.hide()
                                                           }
                                                       })
            NavigationLink(destination: Destination(store: store,
                                                    requestInfo: store.globalState.requestInfo,
                                                    navigationDestination: $navigationDestination)
                    .navigationbarHidden(),
                isActive: showDetail) { EmptyView() }

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
                            SharedStackSummaryView(selectedInventoryItem: selectedInventoryItemBinding,
                                                   selectedStack: selectedStackBinding,
                                                   stack: feedPostData.stack,
                                                   inventoryItems: feedPostData.inventoryItems,
                                                   requestInfo: store.globalState.requestInfo,
                                                   profileInfo: (user.name ?? "", user.imageURL)) {
                                    if let profileData = feedPostData.profileData {
                                        navigationDestination += .profile(profileData)
                                    }
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

extension FeedView {
    enum NavigationDestination {
        case inventoryItem(InventoryItem), profile(ProfileData), feedPost(FeedPost), empty
    }

    struct Destination: View {
        var store: FeedStore
        let requestInfo: [ScraperRequestInfo]
        @Binding var navigationDestination: Navigation<NavigationDestination>

        var feedPosts: [FeedPost] {
            store.state.feedPosts.data
        }

        func user(for inventoryItem: InventoryItem) -> User? {
            feedPosts.first(where: { $0.stack.itemIds.contains(inventoryItem.id) })?.user
        }

        var body: some View {
            switch navigationDestination.destination {
            case let .inventoryItem(inventoryItem):
                if let user = user(for: inventoryItem) {
                    SharedInventoryItemView(user: user,
                                            inventoryItem: inventoryItem,
                                            requestInfo: requestInfo) { navigationDestination.hide() }
                }
            case let .profile(profile):
                ProfileView(profileData: profile) { navigationDestination.hide() }
            case let .feedPost(feedPost):
                if let user = feedPost.user {
                    SharedStackDetailView(user: user,
                                          stack: feedPost.stack,
                                          inventoryItems: feedPost.inventoryItems,
                                          requestInfo: requestInfo) { navigationDestination.hide() }
                }
            case .empty:
                EmptyView()
            }
        }
    }
}
