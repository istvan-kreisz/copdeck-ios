////
////  SharedInventoryItemView.swift
////  SneakersnShit
////
////  Created by István Kreisz on 9/2/21.
////
//
//import SwiftUI
//import Combine
//
//struct SharedInventoryItemView: View {
//    private static let profileImageSize: CGFloat = 38
//
//    let profileData: ProfileData
//    let stack: Stack
//    let inventoryItems: [InventoryItem]
//    let requestInfo: [ScraperRequestInfo]
//
//    let shouldDismiss: () -> Void
//
//    @State var selectedInventoryItemId: String?
//
//    var body: some View {
//        Group {
////            ForEach(inventoryItems) { (inventoryItem: InventoryItem) in
////                NavigationLink(destination: InventoryItemDetailView(inventoryItem: inventoryItem) { selectedInventoryItemId = nil },
////                               tag: inventoryItem.id,
////                               selection: $selectedInventoryItemId) { EmptyView() }
////            }
//
//            VerticalListView(bottomPadding: 30, spacing: 2, addHorizontalPadding: false) {
//                NavigationBar(title: stack.name, isBackButtonVisible: true, style: .dark, shouldDismiss: shouldDismiss)
//                    .withDefaultPadding(padding: .horizontal)
//
//                VStack(spacing: 9) {
//                    Text("Owner")
//                        .font(.bold(size: 12))
//                        .foregroundColor(.customText2)
//                        .leftAligned()
//
//                    HStack {
//                        ImageView(withRequest: profileData.user.imageURL,
//                                  size: Self.profileImageSize,
//                                  aspectRatio: 1.0,
//                                  flipImage: false,
//                                  showPlaceholder: true,
//                                  resizingMode: .aspectFill)
//                            .frame(width: Self.profileImageSize, height: Self.profileImageSize)
//                            .cornerRadius(Self.profileImageSize / 2)
//                        VStack(alignment: .leading) {
//                            Text(profileData.user.name ?? "")
//                                .font(.bold(size: 14))
//                                .foregroundColor(.customText1)
////                            Text(publishedDate)
////                                .font(.regular(size: 12))
////                                .foregroundColor(.customText2)
//                        }
//                        Spacer()
//                    }
//                }
//                .asCard()
//                .withDefaultPadding(padding: .horizontal)
//                .padding(.vertical, 10)
//
//                if let caption = stack.caption {
//                    HStack {
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text("notes")
//                                .font(.regular(size: 12))
//                                .foregroundColor(.customText2)
//                            Text(caption)
//                                .font(.regular(size: 14))
//                                .foregroundColor(.customText1)
//                        }
//                        Spacer()
//                    }
//                    .asCard()
//                    .withDefaultPadding(padding: .horizontal)
//                    .padding(.vertical, 10)
//                }
//
//                ForEach(inventoryItems) { (inventoryItem: InventoryItem) in
//                    InventoryListItem(inventoryItem: inventoryItem,
//                                      bestPrice: .init(price: 212, currencyCode: .usd),
//                                      selectedInventoryItemId: $selectedInventoryItemId,
//                                      isSelected: false,
//                                      isEditing: .constant(false),
//                                      requestInfo: store.state.requestInfo) {}
//                }
//                .padding(.vertical, 6)
//                .withDefaultPadding(padding: .horizontal)
//            }
//            .buttonStyle(PlainButtonStyle())
//        }
//        .edgesIgnoringSafeArea(.bottom)
//        .frame(maxWidth: UIScreen.main.bounds.width)
//        .withDefaultPadding(padding: .top)
//        .withBackgroundColor()
//        .navigationbarHidden()
//    }
//}
