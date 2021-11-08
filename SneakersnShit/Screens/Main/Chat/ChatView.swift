//
//  ChatView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/30/21.
//

import SwiftUI

struct ChatView: View {
    @State var isFirstLoad = true
    @State var channels: [Channel] = []
    @StateObject private var channelsLoader = Loader()

    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)

    @State var cancelListener: (() -> Void)?
    @State private var error: (String, String)? = nil

    @Binding var lastMessageChannelId: String?

    var userId: String? {
        AppStore.default.state.user?.id
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

            NavigationLink(destination: Destination(navigationDestination: $navigationDestination).navigationbarHidden(), isActive: showDetail) { EmptyView() }

            VerticalListView(bottomPadding: Styles.tabScreenBottomPadding, spacing: 0) {
                Text("Messages")
                    .tabTitle()
                    .padding(.bottom, 19)

                if channelsLoader.isLoading {
                    CustomSpinner(text: "Loading messages", animate: true)
                }

                if !channels.isEmpty {
                    ForEach(channels) { (channel: Channel) in
                        if let userId = userId {
                            ChannelListItem(channel: channel, userId: userId) {
                                navigationDestination += .chat(channel: channel, userId: userId)
                            } didTapUser: {
                                if let messagePartner = channel.messagePartner(userId: userId) {
                                    navigationDestination += .profile(.init(user: messagePartner))
                                }
                            }
                        }
                    }
                } else {
                    if !channelsLoader.isLoading {
                        Text("No messages here!")
                            .font(.bold(size: 14))
                            .foregroundColor(.customText2)
                            .padding(.top, 21)
                            .centeredHorizontally()
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
        .onChange(of: lastMessageChannelId) { lastMessageChannelId in
            if let userId = userId, let channel = channels.first(where: { $0.id == lastMessageChannelId }) {
                navigationDestination += .chat(channel: channel, userId: userId)
                self.lastMessageChannelId = nil
            }
        }
        .onChange(of: DerivedGlobalStore.default.globalState.chatUpdates) { chatUpdates in
            updateChannels(channels: channels, chatUpdateInfo: chatUpdates)
        }
    }

    private func loadChannels(isFirstLoad: Bool) {
        var loader: ((Result<Void, AppError>) -> Void)?
        if isFirstLoad {
            loader = channelsLoader.getLoader()
        }
        AppStore.default.send(.main(action: .getChannelsListener(cancel: { cancel in
            self.cancelListener = cancel
        }, update: { result in
            switch result {
            case let .failure(error):
                self.error = (error.title, error.message)
            case let .success(channels):
                self.updateChannels(channels: channels, chatUpdateInfo: DerivedGlobalStore.default.globalState.chatUpdates)

                if let userId = userId, let channel = channels.first(where: { $0.id == lastMessageChannelId }) {
                    navigationDestination += .chat(channel: channel, userId: userId)
                    self.lastMessageChannelId = nil
                }
            }
            loader?(.success(()))
        })))
    }

    private func updateChannels(channels: [Channel], chatUpdateInfo: ChatUpdateInfo) {
        self.channels = channels.sortedByDate().map { channel in
            var updatedChannel = channel
            updatedChannel.updateInfo = chatUpdateInfo.updateInfo[channel.id]
            return updatedChannel
        }
    }
}

extension ChatView {
    enum NavigationDestination {
        case chat(channel: Channel, userId: String), profile(ProfileData), empty
    }

    struct Destination: View {
        @Binding var navigationDestination: Navigation<NavigationDestination>

        var body: some View {
            switch navigationDestination.destination {
            case let .chat(channel, userId):
                MessagesView(channel: channel, userId: userId)
            case let .profile(profile):
                ProfileView(profileData: profile) { navigationDestination.hide() }
            case .empty:
                EmptyView()
            }
        }
    }
}
