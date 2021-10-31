//
//  ChatView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/30/21.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var store: DerivedGlobalStore

    @State var isFirstLoad = true
    @State var channels: [Channel] = []
    @StateObject private var channelsLoader = Loader()

    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)
    
    @State var cancelListener: (() -> Void)?
    @State private var error: (String, String)? = nil
    
    var userId: String? {
        store.globalState.user?.id
    }

    var selectedChannel: Channel? {
        guard case let .chat(channel) = navigationDestination.destination else { return nil }
        return channel
    }

    var selectedUser: ProfileData? {
        guard case let .profile(profile) = navigationDestination.destination else { return nil }
        return profile
    }

//    var allProfiles: [ProfileData] {
//        let selectedProfile: [ProfileData] = selectedUser.map { (profile: ProfileData) in [profile] } ?? []
//        let searchResults: [ProfileData] = store.state.userSearchResults.map { (user: User) in ProfileData(user: user, stacks: [], inventoryItems: []) }
//        var uniqued: [ProfileData] = []
//        (selectedProfile + searchResults).forEach { profileData in
//            if !uniqued.contains(where: { $0.user.id == profileData.user.id }) {
//                uniqued.append(profileData)
//            }
//        }
//        return uniqued
//    }

    var body: some View {
        Group {
            let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })
            let showDetail = Binding<Bool>(get: { navigationDestination.show },
                                           set: { show in show ? navigationDestination.display() : navigationDestination.hide() })
            let selectedUserBinding = Binding<ProfileData?>(get: { selectedUser },
                                                            set: { profile in
                                                                if let profile = profile {
                                                                    navigationDestination += .profile(profile)
                                                                } else {
                                                                    navigationDestination.hide()
                                                                }
                                                            })

            NavigationLink(destination: Destination(store: store,
                                                    navigationDestination: $navigationDestination).navigationbarHidden(),
                           isActive: showDetail) { EmptyView() }

            VStack(alignment: .leading, spacing: 19) {
//                Text("Messages")
//                    .foregroundColor(.customText1)
//                    .font(.bold(size: 35))
//                    .leftAligned()
//                    .padding(.leading, 6)
//                    .withDefaultPadding(padding: .horizontal)
//
//                if channelsLoader.isLoading {
//                    CustomSpinner(text: "Updating messages", animate: true)
//                        .padding(.top, 5)
//                        .withDefaultPadding(padding: .horizontal)
//                }
                
                VerticalListView(bottomPadding: Styles.tabScreenBottomPadding, spacing: 0) {
                    Text("Messages")
                        .tabTitle()
                        .padding(.bottom, 19)
                    
                    if channelsLoader.isLoading {
                        CustomSpinner(text: "Updating messages", animate: true)
                    }

                    ForEach(channels) { (channel: Channel) in
                        if let userId = userId {
                            ChannelListItem(channel: channel, userId: userId) {
                                navigationDestination += .chat(channel)
                            } didTapUser: {
                                if let messagePartner = channel.messagePartner(userId: userId) {
                                    navigationDestination += .profile(.init(user: messagePartner))
                                }
                            }

                        }
                    }
                }
            }
            .onAppear {
                if isFirstLoad {
                    loadChannels()
                    isFirstLoad = false
                }
            }
            .onDisappear {
                cancelListener?()
            }
            .alert(isPresented: presentErrorAlert) {
                let title = error?.0 ?? ""
                let description = error?.1 ?? ""
                return Alert(title: Text(title), message: Text(description), dismissButton: Alert.Button.cancel(Text("Okay")))
            }
        }
    }
    
    private func loadChannels() {
        let loader = channelsLoader.getLoader()
        store.send(.main(action: .getChannelsListener(cancel: { cancel in
            self.cancelListener = cancel
        }, update: { result in
            switch result {
            case let .failure(error):
                self.error = (error.title, error.message)
            case let .success(channels):
                self.channels = channels
            }
            loader(.success(()))
        })))
    }
}

extension ChatView {
    enum NavigationDestination {
        case chat(Channel), profile(ProfileData), empty
    }

    struct Destination: View {
        var store: DerivedGlobalStore
        @Binding var navigationDestination: Navigation<NavigationDestination>

        var body: some View {
            switch navigationDestination.destination {
            case let .chat(channel):
                ChatDetailView(channel: channel)
            case let .profile(profile):
                ProfileView(profileData: profile) { navigationDestination.hide() }
            case .empty:
                EmptyView()
            }
        }
    }
}
