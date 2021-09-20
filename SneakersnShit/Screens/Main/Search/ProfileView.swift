//
//  ProfileView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)

    @State var profileData: ProfileData
    @State private var isFirstLoad = true

    @StateObject private var loader = Loader()

    var shouldDismiss: () -> Void

    var joinedDate: String {
        guard let joined = profileData.user.created else { return "" }
        let joinedDate = Date(timeIntervalSince1970: joined / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"

        return dateFormatter.string(from: joinedDate)
    }

    var selectedInventoryItem: InventoryItem? {
        guard case let .inventoryItem(inventoryItem) = navigationDestination.destination else { return nil }
        return inventoryItem
    }

    var selectedStack: Stack? {
        guard case let .stack(stack) = navigationDestination.destination else { return nil }
        return stack
    }

    func stackItems(in stack: Stack) -> [InventoryItem] {
        stack.inventoryItems(allInventoryItems: profileData.inventoryItems, filters: .default, searchText: "")
    }

    var body: some View {
        Group {
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
                                                           if let stack = stack {
                                                               navigationDestination += .stack(stack)
                                                           } else {
                                                               navigationDestination.hide()
                                                           }
                                                       })

            NavigationLink(destination: Destination(requestInfo: store.globalState.requestInfo,
                                                    navigationDestination: $navigationDestination,
                                                    profileData: profileData).navigationbarHidden()) {
                    EmptyView()
            }

            VerticalListView(bottomPadding: 0, spacing: 0, listRowStyling: .none) {
                NavigationBar(title: nil, isBackButtonVisible: true, style: .dark, shouldDismiss: shouldDismiss)
                    .listRow(backgroundColor: .customWhite)
                    .buttonStyle(PlainButtonStyle())

                InventoryHeaderView(settingsPresented: .constant(false),
                                    showImagePicker: .constant(false),
                                    profileImageURL: .constant(profileData.user.imageURL),
                                    username: .constant(profileData.user.name ?? ""),
                                    textBox1: .init(title: "Joined", text: joinedDate),
                                    textBox2: .init(title: "Shared Stacks", text: "\(profileData.stacks.count)"),
                                    isOwnProfile: false)

                Text(profileData.user.name.map { "\($0)'s Stacks" } ?? "Stacks")
                    .font(.bold(size: 25))
                    .foregroundColor(.customText1)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                    .centeredHorizontally()
                    .listRow()

                if loader.isLoading {
                    CustomSpinner(text: "Loading stacks...", animate: true)
                        .padding(.top, 21)
                        .listRow()
                }

                ForEach(profileData.stacks) { (stack: Stack) in
                    SharedStackSummaryView(selectedInventoryItem: selectedInventoryItemBinding,
                                           selectedStack: selectedStackBinding,
                                           stack: stack,
                                           inventoryItems: stackItems(in: stack),
                                           requestInfo: store.globalState.requestInfo,
                                           profileInfo: (profileData.user.name ?? "", profileData.user.imageURL))
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 4)
                        .listRow()
                }
            }
            .navigationbarHidden()
            .onAppear {
                if isFirstLoad {
                    store.send(.main(action: .getUserProfile(userId: profileData.user.id) { profileData in
                        updateProfile(newProfile: profileData)
                    }), completed: loader.getLoader())
                    isFirstLoad = false
                }
            }
        }
    }

    private func updateProfile(newProfile: ProfileData?) {
        guard let newProfile = newProfile, newProfile.id == profileData.id else { return }
        self.profileData = newProfile
    }
}

extension ProfileView {
    enum NavigationDestination {
        case inventoryItem(InventoryItem), stack(Stack), empty
    }

    struct Destination: View {
        let requestInfo: [ScraperRequestInfo]
        @Binding var navigationDestination: Navigation<NavigationDestination>
        var profileData: ProfileData

        func stackItems(in stack: Stack) -> [InventoryItem] {
            stack.inventoryItems(allInventoryItems: profileData.inventoryItems, filters: .default, searchText: "")
        }

        var body: some View {
            switch navigationDestination.destination {
            case let .inventoryItem(inventoryItem):
                SharedInventoryItemView(user: profileData.user,
                                        inventoryItem: inventoryItem,
                                        requestInfo: requestInfo) { navigationDestination.hide() }
            case let .stack(stack):
                SharedStackDetailView(user: profileData.user,
                                      stack: stack,
                                      inventoryItems: stackItems(in: stack),
                                      requestInfo: requestInfo) { navigationDestination.hide() }
            case .empty:
                EmptyView()
            }
        }
    }
}
