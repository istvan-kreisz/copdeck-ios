//
//  ProfileView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @State var profileData: ProfileData
    @State private var selectedInventoryItemId: String?
    @State private var selectedStackId: String?

    @State private var selectedStack: Stack?

    var shouldDismiss: () -> Void

    var joinedDate: String {
        guard let joined = profileData.user.created else { return "" }
        let joinedDate = Date(timeIntervalSince1970: joined / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"

        return dateFormatter.string(from: joinedDate)
    }

    func stackItems(in stack: Stack) -> [InventoryItem] {
        stack.inventoryItems(allInventoryItems: profileData.inventoryItems, filters: .default, searchText: "")
    }

    var body: some View {
        Group {
            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }

            ForEach(profileData.inventoryItems) { (inventoryItem: InventoryItem) in
                NavigationLink(destination: SharedInventoryItemView(user: profileData.user,
                                                                    inventoryItem: inventoryItem,
                                                                    requestInfo: store.state.requestInfo) { selectedInventoryItemId = nil },
                               tag: inventoryItem.id,
                               selection: $selectedInventoryItemId) { EmptyView() }
            }

            ForEach(profileData.stacks) { (stack: Stack) in
                NavigationLink(destination: SharedStackDetailView(user: profileData.user,
                                                                  stack: stack,
                                                                  inventoryItems: stackItems(in: stack),
                                                                  requestInfo: store.state.requestInfo) { selectedStackId = nil },
                               tag: stack.id,
                               selection: $selectedStackId) { EmptyView() }
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
                    .padding(.top, 24)
                    .padding(.bottom, 12)
                    .centeredHorizontally()
                    .listRow()

                ForEach(profileData.stacks) { (stack: Stack) in
                    SharedStackSummaryView(selectedInventoryItemId: $selectedInventoryItemId,
                                           selectedStackId: $selectedStackId,
                                           stack: stack,
                                           inventoryItems: stackItems(in: stack),
                                           requestInfo: store.state.requestInfo,
                                           profileInfo: (profileData.user.name ?? "", profileData.user.imageURL))
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 8)
                        .listRow()
                }
            }
        }
        .navigationbarHidden()
        .onAppear {
            store.send(.main(action: .getUserProfile(userId: profileData.user.id)))
        }
        .onChange(of: store.state.selectedUserProfile) { profile in
            guard let profile = profile else { return }
            self.profileData = profile
        }
    }
}
