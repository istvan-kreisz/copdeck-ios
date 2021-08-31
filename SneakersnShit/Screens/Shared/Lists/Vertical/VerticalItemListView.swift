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
    var requestInfo: [ScraperRequestInfo]

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
                    VerticalListItemWithoutAccessoryView(title: item.name ?? "",
                                                         imageURL: item.imageURL,
                                                         flipImage: item.imageURL?.store.id == .klekt,
                                                         requestInfo: requestInfo,
                                                         isEditing: .constant(false),
                                                         isSelected: false) { selectedItem = item }
                }
            }
            .padding(.top, 5)
        }
    }
}

struct VerticalItemListView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            VerticalItemListView(items: .constant([.sample, .sample]),
                                 selectedItem: .constant(.sample),
                                 isLoading: .constant(false),
                                 title: "title",
                                 resultsLabelText: nil,
                                 bottomPadding: 130,
                                 requestInfo: [])
        }
    }
}
