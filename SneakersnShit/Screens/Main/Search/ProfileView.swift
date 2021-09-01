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

    @State private var selectedStack: Stack?

    var shouldDismiss: () -> Void

    var joinedDate: String {
        guard let joined = profileData.user.created else { return "" }
        let joinedDate = Date(timeIntervalSince1970: joined)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"

        return dateFormatter.string(from: joinedDate)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
//            let stackTitles = Binding<[String]>(get: { stacks.map { (stack: Stack) in stack.name } }, set: { _ in })

            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }
            NavigationBar(title: nil, isBackButtonVisible: true, style: .dark, shouldDismiss: shouldDismiss)
                .withDefaultPadding(padding: .horizontal)

//            ForEach(inventoryItems) { (inventoryItem: InventoryItem) in
//                NavigationLink(destination: InventoryItemDetailView(inventoryItem: inventoryItem) { selectedInventoryItemId = nil },
//                               tag: inventoryItem.id,
//                               selection: $selectedInventoryItemId) { EmptyView() }
//            }
//            NavigationLink(destination: editedStack.map { editedStack in
//                StackDetail(stack: .constant(editedStack),
//                            inventoryItems: $store.state.inventoryItems,
//                            bestPrices: $bestPrices,
//                            showView: showEditedStack,
//                            filters: filters,
//                            linkURL: editedStack.linkURL(userId: store.state.user?.id ?? ""),
//                            requestInfo: store.state.requestInfo,
//                            saveChanges: { updatedStackItems in
//                                var updatedStack = editedStack
//                                updatedStack.items = updatedStackItems
//                                store.send(.main(action: .updateStack(stack: updatedStack)))
//                            })
//            },
//            isActive: showEditedStack) { EmptyView() }

            VerticalListView(bottomPadding: 0, spacing: 0, addListRowStyling: false) {
                InventoryHeaderView(settingsPresented: .constant(false),
                                    showImagePicker: .constant(false),
                                    profileImageURL: .constant(profileData.user.imageURL),
                                    username: .constant(profileData.user.name ?? ""),
                                    textBox1: .init(title: "Joined", text: joinedDate),
                                    textBox2: .init(title: "Shared Stacks", text: "\(profileData.stacks.count)"),
                                    showHeader: false)

//                if let stack = stacks[safe: selectedStackIndex] {
//                    let isSelected = Binding<Bool>(get: { stack.id == selectedStack?.id }, set: { _ in })
//
//                    StackView(stack: stack,
//                              searchText: $searchText,
//                              filters: filters,
//                              inventoryItems: $store.state.inventoryItems,
//                              selectedInventoryItemId: $selectedInventoryItemId,
//                              isEditing: $isEditing,
//                              showFilters: $showFilters,
//                              selectedInventoryItems: $selectedInventoryItems,
//                              isSelected: isSelected,
//                              bestPrices: $bestPrices,
//                              requestInfo: store.state.requestInfo,
//                              didTapEditStack: stack.id == "all" ? nil : {
//                                  editedStack = stack
//                              }, didTapShareStack: stack.id == "all" ? nil : {
//                                  sharedStack = stack
//                              })
//                        .padding(.top, 5)
//                        .listRow()
//                }
                Color.clear.padding(.bottom, 130)
                    .listRow()
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
//        .withSnackBar(text: "Link Copied", shouldShow: $showSnackBar)
//        .withPopup {
//            CopyLinkPopup(isShowing: showCopyLink,
//                          title: "Share stack",
//                          subtitle: "Share this link with anyone to show them what's in your stack. The link opens a webpage so whoever you share it with doesn't need to have the app downloaded.",
//                          linkURL: sharedStack?.linkURL(userId: store.state.user?.id ?? "") ?? "",
//                          actionTitle: "Copy Link") { link in
//                    if var updatedStack = sharedStack {
//                        UIPasteboard.general.string = link
//                        showSnackBar = true
//                        updatedStack.isSharedViaLink = true
//                        store.send(.main(action: .updateStack(stack: updatedStack)))
//                    }
//            }
//        }
    }
}
