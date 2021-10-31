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
        guard case let .chat(channel, _) = navigationDestination.destination else { return nil }
        return channel
    }

    var selectedUser: ProfileData? {
        guard case let .profile(profile) = navigationDestination.destination else { return nil }
        return profile
    }

    var body: some View {
        Group {
            let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })
            let showDetail = Binding<Bool>(get: { navigationDestination.show },
                                           set: { show in show ? navigationDestination.display() : navigationDestination.hide() })

            NavigationLink(destination: Destination(store: store,
                                                    navigationDestination: $navigationDestination).navigationbarHidden(),
                           isActive: showDetail) { EmptyView() }

            VStack(alignment: .leading, spacing: 19) {
                VerticalListView(bottomPadding: Styles.tabScreenBottomPadding, spacing: 0) {
                    Text("Messages")
                        .tabTitle()
                        .padding(.bottom, 19)
                    
                    if channelsLoader.isLoading {
                        CustomSpinner(text: "Loading messages", animate: true)
                    }

                    ForEach(channels) { (channel: Channel) in
                        if let userId = userId {
                            ChannelListItem(channel: channel, userId: userId) {
                                navigationDestination += .chat(channel, userId)
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
                loadChannels(isFirstLoad: isFirstLoad)
                if isFirstLoad {
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
    
    private func loadChannels(isFirstLoad: Bool) {
        var loader: ((Result<Void, AppError>) -> Void)?
        if isFirstLoad {
            loader = channelsLoader.getLoader()
        }
        store.send(.main(action: .getChannelsListener(cancel: { cancel in
            self.cancelListener = cancel
        }, update: { result in
            switch result {
            case let .failure(error):
                self.error = (error.title, error.message)
            case let .success(channels):
                self.channels = channels
            }
            loader?(.success(()))
        })))
    }
}

extension ChatView {
    enum NavigationDestination {
        case chat(Channel, String), profile(ProfileData), empty
    }

    struct Destination: View {
        var store: DerivedGlobalStore
        @Binding var navigationDestination: Navigation<NavigationDestination>

        var body: some View {
            switch navigationDestination.destination {
            case let .chat(channel, userId):
                MessagesView(channel: channel, userId: userId, store: store)
            case let .profile(profile):
                ProfileView(profileData: profile) { navigationDestination.hide() }
            case .empty:
                EmptyView()
            }
        }
    }
}
