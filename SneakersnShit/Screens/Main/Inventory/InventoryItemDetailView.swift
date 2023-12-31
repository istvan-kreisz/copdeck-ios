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
    let isInSharedStack: Bool
    let sortedSizes: [ItemType: [String]]
    let sizesConverted: [ItemType: [String]]

    var shouldDismiss: () -> Void

    @State var name: String
    @State var styleId: String
    @State var notes: String

    @State var showItemDetails = false
    @State var showPhotoSelector = false

    @State var didLoadPhotos = false
    @State var photoURLs: [URL] = []
    @State var shownImageURL: URL?

    @State var alert: (String, String)? = nil
    @State var showAddNewTagPopup = false
    @State var updateSignal = 0

    @State var tags: [Tag]

    var photoURLsChunked: [(Int, [URL])] {
        Array(photoURLs.chunked(into: 3).enumerated())
    }

    var imageSize: CGFloat {
        (UIScreen.screenWidth - (Styles.horizontalPadding * 4.0) - (Styles.horizontalMargin * 2.0)) / 3
    }

    init(inventoryItem: InventoryItem, importSummaryMode: Bool = false, isInSharedStack: Bool, shouldDismiss: @escaping () -> Void) {
        self._inventoryItem = State(initialValue: inventoryItem)
        self.importSummaryMode = importSummaryMode
        self.isInSharedStack = isInSharedStack
        self.shouldDismiss = shouldDismiss

        self._name = State(initialValue: inventoryItem.name)
        self._styleId = State(initialValue: inventoryItem.styleId)
        self._notes = State(initialValue: inventoryItem.notes ?? "")
        self._tags = State(initialValue: Tag.defaultTags + (AppStore.default.state.user?.tags ?? []))

        let sortedSizes = inventoryItem.sortedSizes
        self.sortedSizes = sortedSizes
        var sizesConverted = sortedSizes
        sizesConverted[.shoe] = sizesConverted[.shoe]?.asSizes(of: inventoryItem)
        self.sizesConverted = sizesConverted
    }

    var body: some View {
        let showPopup = Binding<Bool>(get: { alert != nil }, set: { new in alert = new ? alert : nil })
        VStack {
            if !importSummaryMode {
                NavigationLink(destination: inventoryItem.itemId.map { (itemId: String) in
                    ItemDetailView(item: nil,
                                   itemId: itemId,
                                   styleId: inventoryItem.styleId,
                                   favoritedItemIds: store.state.favoritedItems.map(\.id)) {
                        showItemDetails = false
                    }
                    .environmentObject(DerivedGlobalStore.default)
                },
                isActive: $showItemDetails) { EmptyView() }
            }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 20) {
                    ItemImageViewWithNavBar(itemId: inventoryItem.itemId ?? "",
                                            source: imageSource(for: inventoryItem),
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

                        TextFieldRounded(title: "name",
                                         placeHolder: "name",
                                         style: .white,
                                         text: $name,
                                         addClearButton: true)
                            .padding(.top, 15)
                        if inventoryItem.isShoe {
                            TextFieldRounded(title: "styleid",
                                             placeHolder: "styleid",
                                             style: .white,
                                             text: $styleId,
                                             width: 200,
                                             addClearButton: true)
                                .leftAligned()
                        }

                        NewItemCard(inventoryItem: $inventoryItem,
                                    tags: $tags,
                                    updateSignal: $updateSignal,
                                    purchasePrice: inventoryItem.purchasePrice,
                                    currency: store.state.currency,
                                    style: NewItemCard.Style.noBackground,
                                    sortedSizes: sortedSizes,
                                    sizesConverted: sizesConverted,
                                    showCopDeckPrice: true,
                                    highlightCopDeckPrice: isInSharedStack,
                                    addQuantitySelector: false,
                                    onCopDeckPriceTooltipTapped: {
                                        alert = ("CopDeck price",
                                                 "When you share your stack on the CopDeck feed or via a link, this the price that will show up next to your item.")
                                    }, didTapAddTag: {
                                        showAddNewTagPopup = true
                                    }, didTapDeleteTag: { tag in
                                        AppStore.default.send(.main(action: .deleteTag(tag: tag)))
                                        self.tags.removeAll(where: { $0.id == tag.id })
                                    })

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
                                    EmptyStateButton(title: "Your haven't added any photos",
                                                     buttonTitle: "Start adding photos",
                                                     style: .regular,
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

                        TextFieldRounded(title: "notes",
                                         placeHolder: "add any notes here",
                                         style: .white,
                                         text: $notes,
                                         addClearButton: true)
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
        .withPopup {
            if showAddNewTagPopup {
                NewTagPopup(isShowing: $showAddNewTagPopup) { name, color in
                    let newTag = Tag(name: name, color: color)
                    store.send(.main(action: .addNewTag(tag: newTag)))
                    self.tags.append(newTag)
                }
            } else {
                Popup<EmptyView>(isShowing: showPopup,
                                 title: alert.map { $0.0 } ?? "",
                                 subtitle: alert.map { $0.1 } ?? "",
                                 firstAction: .init(name: "Okay", tapped: { alert = nil }),
                                 secondAction: nil)
            }
        }
        .withImageViewer(shownImageURL: $shownImageURL)
        .hideKeyboardOnScroll()
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
        updateSignal += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let updatedInventoryItem = inventoryItem.copy(withName: name, styleId: styleId, notes: notes)
            store.send(.main(action: .updateInventoryItem(inventoryItem: updatedInventoryItem)))
            shouldDismiss()
        }
    }
}
