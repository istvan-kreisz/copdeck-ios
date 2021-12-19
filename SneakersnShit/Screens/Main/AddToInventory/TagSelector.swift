//
//  TagSelector.swift
//  CopDeck
//
//  Created by István Kreisz on 12/6/21.
//

import SwiftUI

struct TagSelector: View {
    static let padding: CGFloat = 3

    let style: NewItemCard.Style
    @Binding var tags: [Tag]
    @Binding var selectedTags: [Tag]
    let didTapAddTag: () -> Void
    let didTapDeleteTag: (Tag) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("tags")
                .font(.regular(size: 12))
                .foregroundColor(style == .card ? .customText2 : .customText1)
                .padding(.leading, 5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Color.clear.frame(width: 2)
                    ForEach(tags) { tag in
                        let isSelected = Binding<Bool>(get: { selectedTags.contains { $0.id == tag.id } },
                                                       set: { newValue in
                                                           if newValue {
                                                               if !selectedTags.contains(where: { $0.id == tag.id }) {
                                                                   selectedTags.append(tag)
                                                               }
                                                           } else {
                                                               selectedTags = selectedTags.filter { $0.id != tag.id }
                                                           }
                                                       })
                        TagView(title: tag.name, color: tag.uiColor, isSelected: isSelected) { didTapDeleteTag(tag) }
                    }

                    AccessoryButton(title: "new tag",
                                    shouldCapitalizeTitle: false,
                                    color: .customAccent1,
                                    textColor: .customText1,
                                    height: TagView.height,
                                    width: 80,
                                    accessoryViewSize: 16,
                                    imageName: "plus",
                                    buttonPosition: .right,
                                    isContentLocked: false,
                                    tapped: didTapAddTag)
                    Color.clear.frame(width: 2)
                }
                .padding(.vertical, Self.padding)
            }
        }
    }
}
