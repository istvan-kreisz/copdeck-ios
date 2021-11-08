//
//  VerticalItemListView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/10/21.
//

import SwiftUI
import Combine

struct VerticalItemListView: View {
    @Binding var items: [Item]
    @Binding var selectedItem: Item?
    @Binding var isLoading: Bool

    let title: String?
    let resultsLabelText: String?
    let bottomPadding: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 19) {
                if let title = title {
                    Text(title)
                        .foregroundColor(.customText1)
                        .font(.bold(size: 35))
                        .leftAligned()
                        .padding(.leading, 6)
                        .withDefaultPadding(padding: .horizontal)
                }
                if isLoading {
                    CustomSpinner(text: "Loading...", animate: true)
                        .padding(.horizontal, 22)
                        .padding(.top, 5)
                }
                if let resultCount = items.count, let resultsLabelText = resultsLabelText {
                    Text("\(resultCount) \(resultsLabelText)")
                        .font(.bold(size: 12))
                        .leftAligned()
                        .padding(.horizontal, 28)
                }
            }

            VerticalListView(bottomPadding: bottomPadding) {
                ForEach(items) { (item: Item) in
                    VerticalListItemWithoutAccessoryView(itemId: item.id,
                                                         title: item.name ?? "",
                                                         source: imageSource(for: item),
                                                         flipImage: item.imageURL?.store?.id == .klekt,
                                                         isEditing: .constant(false),
                                                         isSelected: false,
                                                         onTapped: { selectedItem = item })
                }
            }
            .padding(.top, 5)
        }
    }
}
