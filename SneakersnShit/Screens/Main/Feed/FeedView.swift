//
//  FeedView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/28/21.
//

import SwiftUI
import Combine
import Firebase

struct FeedView: View {
    static var preloadedPosts: PaginatedResult<[FeedPost]>?
    static var didStartPreloading = false

    @EnvironmentObject var store: AppStore
    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)

    @State private var isFirstLoad = true

    @StateObject private var loader = Loader()

    @State var feedState = FeedState()
    var alert = State<(String, String)?>(initialValue: nil)

    let userId: String

    var selectedInventoryItem: InventoryItem? {
        guard case let .inventoryItem(inventoryItem) = navigationDestination.destination else { return nil }
        return inventoryItem
    }

    var selectedStack: Stack? {
        guard case let .feedPost(feedPost) = navigationDestination.destination else { return nil }
        return feedPost.stack
    }

    var feedPosts: [FeedPost] {
        feedState.feedPosts.data
    }

    var inventoryItems: [InventoryItem] {
        feedPosts.flatMap { $0.inventoryItems }
    }

    init(userId: String) {
        self.userId = userId
        if Self.preloadedPosts == nil && !Self.didStartPreloading {
            Self.didStartPreloading = true
            loadFeedPosts(loadMore: false, preload: true)
        }
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
                                                           if let feedPost = feedPosts.first(where: { $0.stack.id == stack?.id }) {
                                                               navigationDestination += .feedPost(feedPost)
                                                           } else {
                                                               navigationDestination.hide()
                                                           }
                                                       })
            NavigationLink(destination: Destination(navigationDestination: $navigationDestination, feedPosts: $feedState.feedPosts)
                    .navigationbarHidden(),
                isActive: showDetail) { EmptyView() }

            VerticalListView(bottomPadding: Styles.tabScreenBottomPadding, spacing: 0) {
                Text("Feed")
                    .tabTitle()
                
                if !AppStore.default.state.globalState.isContentLocked {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your inventory's value:")
                            .font(.regular(size: 14))
                            .foregroundColor(.customText2)
                            .padding(.leading, 5)
                        
                        Text(store.state.inventoryValue?.asString ?? "-")
                            .font(.bold(size: UIScreen.isSmallScreen ? 40 : 45))
                            .foregroundColor(.customText1)
                    }
                }

                PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                    loadFeedPosts(loadMore: false)
                }

                if loader.isLoading && feedState.feedPosts.isLastPage {
                    CustomSpinner(text: "Loading posts...", animate: true)
                        .padding(.top, 21)
                        .centeredHorizontally()
                }

                ForEach(feedPosts) { (feedPostData: FeedPost) in
                    if let user = feedPostData.user {
                        SharedStackSummaryView(selectedInventoryItem: selectedInventoryItemBinding,
                                               selectedStack: selectedStackBinding,
                                               stack: feedPostData.stack,
                                               stackOwnerId: feedPostData.userId,
                                               userId: userId,
                                               userCountry: feedPostData.user?.country,
                                               inventoryItems: feedPostData.inventoryItems,
                                               profileInfo: (user.name ?? "", user.imageURL)) {
                            if let profileData = feedPostData.profileData {
                                navigationDestination += .profile(profileData)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 4)
                    }
                }

                if feedState.feedPosts.isLastPage {
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
            .hideKeyboardOnScroll()
        }
        .onAppear {
            if isFirstLoad {
                Analytics.logEvent("visited_feed", parameters: ["userId": store.state.user?.id ?? ""])
                if let preloadedPosts = Self.preloadedPosts {
                    self.feedState.feedPosts = preloadedPosts
                } else {
                    if feedPosts.isEmpty {
                        loadFeedPosts(loadMore: false)
                    }
                }
                isFirstLoad = false
            }
        }
        .withAlert(alert: alert.projectedValue)
    }

    private func loadFeedPosts(loadMore: Bool, preload: Bool = false) {
        var loader: ((Result<Void, AppError>) -> Void)? = nil
        if !preload {
            loader = self.loader.getLoader()
        }
        AppStore.default.send(.main(action: .getFeedPosts(loadMore: loadMore, completion: { result in
            handleResult(result: result, loader: loader) { new in
                if preload {
                    Self.preloadedPosts = new
                } else {
                    if loadMore {
                        let currentPostIds = feedState.feedPosts.data.map { $0.id }
                        feedState.feedPosts.data += new.data.filter { post in !currentPostIds.contains(post.id) }
                        feedState.feedPosts.isLastPage = new.isLastPage
                    } else {
                        feedState.feedPosts = new
                    }
                }
            }
        })))
    }
}

extension FeedView {
    enum NavigationDestination {
        case inventoryItem(InventoryItem), profile(ProfileData), feedPost(FeedPost), empty
    }

    struct Destination: View {
        @Binding var navigationDestination: Navigation<NavigationDestination>
        @Binding var feedPosts: PaginatedResult<[FeedPost]>

        func user(for inventoryItem: InventoryItem) -> User? {
            feedPosts.data.first(where: { $0.stack.itemIds.contains(inventoryItem.id) })?.user
        }

        var body: some View {
            switch navigationDestination.destination {
            case let .inventoryItem(inventoryItem):
                if let user = user(for: inventoryItem) {
                    SharedInventoryItemView(user: user, inventoryItem: inventoryItem) { navigationDestination.hide() }
                }
            case let .profile(profile):
                ProfileView(profileData: profile) { navigationDestination.hide() }
            case let .feedPost(feedPost):
                if let user = feedPost.user {
                    SharedStackDetailView(user: user,
                                          stack: feedPost.stack,
                                          inventoryItems: feedPost.inventoryItems) { navigationDestination.hide() }
                }
            case .empty:
                EmptyView()
            }
        }
    }
}

extension FeedView: LoadViewWithAlert {}
