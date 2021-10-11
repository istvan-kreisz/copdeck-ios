//
//  InventoryItemDetailView.swift
//  CopDeck
//
//  Created by István Kreisz on 3/30/21.
//

import SwiftUI

struct InventoryItemDetailView: View {
    @EnvironmentObject var store: AppStore
    @State var inventoryItem: InventoryItem
    let importSummaryMode: Bool
    var shouldDismiss: () -> Void

    @State var name: String
    @State var styleId: String
    @State var notes: String

    @State var showItemDetails = false
    @State var showPhotoSelector = false

    @State var didLoadPhotos = false
    @State var photoURLs: [URL] = []
    @State var shownImageURL: URL?

    var photoURLsChunked: [(Int, [URL])] {
        Array(photoURLs.chunked(into: 3).enumerated())
    }

    var imageSize: CGFloat {
        (UIScreen.screenWidth - (Styles.horizontalPadding * 4.0) - (Styles.horizontalMargin * 2.0)) / 3
    }

    var imageDownloadHeaders: [String: String] {
        if let imageURLStoreId = inventoryItem.imageURL?.store?.id, let requestInfo = store.state.requestInfo(for: imageURLStoreId) {
            return requestInfo.imageDownloadHeaders
        } else {
            return [:]
        }
    }

    init(inventoryItem: InventoryItem, importSummaryMode: Bool = false, shouldDismiss: @escaping () -> Void) {
        self._inventoryItem = State(initialValue: inventoryItem)
        self.importSummaryMode = importSummaryMode
        self.shouldDismiss = shouldDismiss

        self._name = State(initialValue: inventoryItem.name)
        self._styleId = State(initialValue: inventoryItem.itemId ?? "")
        self._notes = State(initialValue: inventoryItem.notes ?? "")
    }

    var body: some View {
        VStack {
            NavigationLink(destination: inventoryItem.itemId.map { (itemId: String) in
                ItemDetailView(item: nil,
                               itemId: itemId,
                               favoritedItemIds: store.state.favoritedItems.map(\.id)) {
                    showItemDetails = false
                }
            },
            isActive: $showItemDetails) { EmptyView() }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 20) {
                    ItemImageViewWithNavBar(itemId: inventoryItem.itemId ?? "",
                                            source: imageSource(for: inventoryItem),
                                            requestInfo: [],
                                            shouldDismiss: shouldDismiss,
                                            flipImage: inventoryItem.imageURL?.store?.id == .klekt)

                    VStack(alignment: .center, spacing: 8) {
                        Text("Edit Item")
                            .font(.bold(size: 30))
                            .foregroundColor(.customText1)
                            .padding(.bottom, 8)

                        if inventoryItem.itemId != nil && !importSummaryMode {
                            AccessoryButton(title: "View Prices",
                                            color: .customAccent1,
                                            textColor: .customText1,
                                            width: 125,
                                            imageName: "chevron.right",
                                            buttonPosition: .right,
                                            tapped: { showItemDetails = true })
                        }

                        HStack(spacing: 10) {
                            TextFieldRounded(title: "name",
                                             placeHolder: "name",
                                             style: .white,
                                             text: $name)
                            TextFieldRounded(title: "styleid (optional)",
                                             placeHolder: "styleid",
                                             style: .white,
                                             text: $styleId,
                                             width: 100)
                        }
                        .padding(.top, 15)

                        NewItemCard(inventoryItem: $inventoryItem,
                                    purchasePrice: inventoryItem.purchasePrice,
                                    currency: Currency(code: .usd, symbol: .usd),
                                    style: NewItemCard.Style.noBackground,
                                    sizes: inventoryItem.item?.sortedSizes ?? ShoeSize.ALLSHOESIZESUS,
                                    showCopDeckPrice: true)

                        VStack(alignment: .leading, spacing: 9) {
                            Text("Photos:".uppercased())
                                .font(.bold(size: 12))
                                .foregroundColor(.customText2)
                                .leftAligned()

                            ForEach(photoURLsChunked, id: \.0) { (index: Int, urls: [URL]) in
                                HStack(spacing: Styles.verticalPadding) {
                                    ForEach(urls, id: \.absoluteString) { (url: URL) in
                                        ZStack {
                                            ImageView(source: .url(url),
                                                      size: imageSize,
                                                      aspectRatio: 1.0,
                                                      flipImage: false,
                                                      showPlaceholder: true,
                                                      background: Color.customAccent1.opacity(0.07))
                                                .frame(width: imageSize, height: imageSize)
                                                .cornerRadius(4)
                                                .onTapGesture { shownImageURL = url }
                                            DeleteButton(style: .fill) {
                                                deletePhoto(at: url)
                                            }
                                            .topAligned()
                                            .rightAligned()
                                            .padding(.top, 5)
                                            .padding(.trailing, 5)
                                        }
                                        .frame(width: imageSize, height: imageSize)
                                    }
                                    if urls.count < 3 {
                                        Spacer()
                                    }
                                }
                                .padding(.vertical, 6)
                            }

                            if didLoadPhotos {
                                if photoURLs.isEmpty {
                                    EmptyStateButton(title: "Your haven't added any photos", buttonTitle: "Start adding photos", style: .regular,
                                                     showPlusIcon: false) {
                                        showPhotoSelector = true
                                    }
                                    .padding(.top, 20)
                                    .padding(.bottom, 30)
                                } else if photoURLs.count < InventoryItem.maxPhotoCount {
                                    AccessoryButton(title: "Add Photos",
                                                    color: .customBlue,
                                                    textColor: .customBlue,
                                                    width: 140,
                                                    imageName: "plus",
                                                    tapped: { showPhotoSelector = true })
                                        .leftAligned()
                                        .padding(.top, 5)
                                } else {
                                    Text("Max photos limit (\(InventoryItem.maxPhotoCount)) reached")
                                        .font(.semiBold(size: 12))
                                        .foregroundColor(.customRed)
                                }
                            }
                        }
                        .asCard()
                        .padding(.top, 15)

                        TextFieldRounded(title: "notes (optional)",
                                         placeHolder: "add any notes here",
                                         style: .white,
                                         text: $notes)
                            .padding(.top, 11)

                        if !importSummaryMode {
                            HStack(spacing: 10) {
                                RoundedButton<EmptyView>(text: "Delete item",
                                                         width: 180,
                                                         height: 60,
                                                         maxSize: CGSize(width: (UIScreen.screenWidth - Styles.horizontalMargin * 2 - 10) / 2,
                                                                         height: UIScreen.isSmallScreen ? 50 : 60),
                                                         fontSize: UIScreen.isSmallScreen ? 14 : 16,
                                                         color: .clear,
                                                         borderColor: .customRed,
                                                         textColor: .customRed,
                                                         accessoryView: nil,
                                                         tapped: { deleteInventoryItem() })

                                RoundedButton<EmptyView>(text: "Save changes",
                                                         width: 180,
                                                         height: 60,
                                                         maxSize: CGSize(width: (UIScreen.screenWidth - Styles.horizontalMargin * 2 - 10) / 2,
                                                                         height: UIScreen.isSmallScreen ? 50 : 60),
                                                         fontSize: UIScreen.isSmallScreen ? 14 : 16,
                                                         color: .customBlack,
                                                         accessoryView: nil,
                                                         tapped: { updateInventoryItem() })
                            }
                            .padding(.top, 40)
                        }
                    }
                    .padding(.horizontal, Styles.horizontalMargin)
                    .padding(.top, 14)
                    .padding(.bottom, 20)
                    .background(Color.customBackground
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all))
                }
            }
            .sheet(isPresented: $showPhotoSelector) {
                ImagePickerView(showPicker: $showPhotoSelector, selectionLimit: InventoryItem.maxPhotoCount - photoURLs.count) { (images: [UIImage]) in
                    store.send(.main(action: .uploadInventoryItemImages(inventoryItem: inventoryItem, images: images, completion: { _ in
                        loadPhotos()
                    })))
                }
            }
            .onAppear {
                loadPhotos()
            }
        }
        .withImageViewer(shownImageURL: $shownImageURL)
        .navigationbarHidden()
    }

    private func loadPhotos() {
        guard let userId = store.state.user?.id else { return }
        store.send(.main(action: .getInventoryItemImages(userId: userId, inventoryItem: inventoryItem, completion: { urls in
            if !didLoadPhotos {
                didLoadPhotos = true
            }
            photoURLs = urls
        })))
    }

    private func deletePhoto(at url: URL) {
        photoURLs.removeAll(where: { $0 == url })
        store.send(.main(action: .deleteInventoryItemImage(imageURL: url) { _ in }))
    }

    private func deleteInventoryItem() {
        store.send(.main(action: .removeFromInventory(inventoryItems: [inventoryItem])))
        shouldDismiss()
    }

    private func updateInventoryItem() {
        let updatedInventoryItem = inventoryItem.copy(withName: name, itemId: styleId, notes: notes)
        store.send(.main(action: .updateInventoryItem(inventoryItem: updatedInventoryItem)))
        shouldDismiss()
    }
}

struct InventoryItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return InventoryItemDetailView(inventoryItem: .init(fromItem: .sample)) {}
    }
}
