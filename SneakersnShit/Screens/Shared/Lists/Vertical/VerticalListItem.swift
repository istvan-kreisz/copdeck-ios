//
//  ListItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct VerticalListItem<V: View>: View {
    var title: String
    var imageURL: ImageURL?
    var flipImage = false
    var requestInfo: [ScraperRequestInfo]

    @Binding var isEditing: Bool
    var isSelected: Bool
    @State var animate = false

    var accessoryView: V? = nil
    var onTapped: () -> Void
    var onSelectorTapped: (() -> Void)? = nil

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.customBlue : Color.customAccent2)
                    .frame(width: 28, height: 28)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.bold(size: 13))
                        .foregroundColor(.customWhite)
                }
            }
            .rightAligned()
            .onTapGesture { onSelectorTapped?() }

            HStack(alignment: .center, spacing: 10) {
                ItemImageView(withImageURL: imageURL,
                              requestInfo: requestInfo,
                              size: 62,
                              aspectRatio: nil,
                              flipImage: flipImage)
                    .cornerRadius(8)

                VStack(spacing: 3) {
                    Text(title)
                        .foregroundColor(.customText1)
                        .font(.bold(size: 14))
                        .leftAligned()
                        .layoutPriority(2)
                    if let accessoryView = accessoryView {
                        Spacer()
                            .layoutPriority(0)
                        accessoryView
                            .layoutPriority(2)
                    } else {
                        Spacer()
                            .layoutPriority(0)
                    }
                }
            }
            .padding(12)
            .frame(height: 86)
            .background(Color.customWhite)
            .cornerRadius(12)
            .withDefaultShadow()
            .onTapGesture(perform: onTapped)
            .offset(isEditing ? CGSize(width: -48, height: 0) : CGSize.zero)
            .animation(.spring(), value: isEditing)
        }
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        return VerticalListItem<EmptyView>(title: "yooo",
                                   imageURL: nil,
                                   requestInfo: AppStore.default.state.requestInfo,
                                   isEditing: .constant(false),
                                   isSelected: false,
                                   onTapped: {})
    }
}
