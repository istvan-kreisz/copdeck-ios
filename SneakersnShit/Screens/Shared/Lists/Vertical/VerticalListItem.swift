//
//  ListItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI
import NukeUI

enum VerticalListItemSelectionStyle {
    case checkmark
    case highlight
}

struct VerticalListItem<V1: View, V2: View>: View {
    let itemId: String
    var title: String
    let source: ImageViewSourceType
    var flipImage = false
    var requestInfo: [ScraperRequestInfo]

    @Binding var isEditing: Bool
    var isSelected: Bool
    var selectionStyle: VerticalListItemSelectionStyle = .checkmark
    var ribbonText: String? = nil
    @State var animate = false
    var resizingMode: ImageResizingMode = .aspectFit
    var addShadow: Bool = true

    var accessoryView1: V1? = nil
    var accessoryView2: V2? = nil
    var onTapped: () -> Void
    var onSelectorTapped: (() -> Void)? = nil

    static var cornerRadius: CGFloat { 12 }

    var body: some View {
        ZStack {
            if selectionStyle == .checkmark {
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
            }

            HStack(alignment: .center, spacing: 10) {
                ItemImageView(itemId: itemId,
                              source: source,
                              requestInfo: requestInfo,
                              size: 62,
                              aspectRatio: nil,
                              flipImage: flipImage,
                              resizingMode: resizingMode)
                    .cornerRadius(8)

                VStack(spacing: 3) {
                    Text(title)
                        .foregroundColor(.customText1)
                        .font(.bold(size: 14))
                        .leftAligned()
                        .layoutPriority(2)
                    if let accessoryView = accessoryView1 {
                        accessoryView
                            .layoutPriority(2)
                    } else {
                        Spacer()
                            .layoutPriority(0)
                    }
                }
                if let accessoryView = accessoryView2 {
                    Spacer()
                    accessoryView
                }
            }

            .overlay(ZStack {
                Rectangle()
                    .fill(Color.customRed)
                    .frame(width: 120, height: 18)
                Text(ribbonText ?? "")
                    .foregroundColor(.customWhite)
                    .font(.bold(size: 12))
            }
            .rotationEffect(.degrees(-45))
            .position(x: 12, y: 12)
            .opacity(ribbonText != nil ? 1.0 : 0))
            .padding(12)
            .frame(height: 86)
            .background(selectionStyle == .checkmark || !isSelected ? Color.customWhite : Color.customBlue.opacity(0.07))
            .cornerRadius(Self.cornerRadius)
            .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius)
                .stroke(selectionStyle == .highlight && isSelected ? Color.customBlue : Color.clear, lineWidth: 2))
            .if(addShadow) { $0.withDefaultShadow() }
            .onTapGesture(perform: onTapped)
            .offset(isEditing ? CGSize(width: -48, height: 0) : CGSize.zero)
            .animation(.spring(), value: isEditing)
        }
        .frame(height: 86)
    }
}

struct VerticalListItemWithAccessoryView1<V: View>: View {
    let itemId: String
    var title: String
    let source: ImageViewSourceType
    var flipImage = false
    var requestInfo: [ScraperRequestInfo]

    @Binding var isEditing: Bool
    var isSelected: Bool
    var selectionStyle: VerticalListItemSelectionStyle = .checkmark
    var ribbonText: String? = nil
    @State var animate = false

    var resizingMode: ImageResizingMode = .aspectFit
    var accessoryView: V? = nil
    var onTapped: () -> Void
    var onSelectorTapped: (() -> Void)? = nil

    var body: some View {
        VerticalListItem<V, EmptyView>(itemId: itemId,
                                       title: title,
                                       source: source,
                                       flipImage: flipImage,
                                       requestInfo: requestInfo,
                                       isEditing: $isEditing,
                                       isSelected: isSelected,
                                       selectionStyle: selectionStyle,
                                       ribbonText: ribbonText,
                                       animate: animate,
                                       resizingMode: resizingMode,
                                       accessoryView1: accessoryView,
                                       accessoryView2: nil,
                                       onTapped: onTapped,
                                       onSelectorTapped: onSelectorTapped)
    }
}

struct VerticalListItemWithoutAccessoryView: View {
    let itemId: String
    var title: String
    let source: ImageViewSourceType
    var flipImage = false
    var requestInfo: [ScraperRequestInfo]

    @Binding var isEditing: Bool
    var isSelected: Bool
    var selectionStyle: VerticalListItemSelectionStyle = .checkmark
    var ribbonText: String? = nil
    @State var animate = false

    var resizingMode: ImageResizingMode = .aspectFit

    var onTapped: () -> Void
    var onSelectorTapped: (() -> Void)? = nil

    var body: some View {
        VerticalListItem<EmptyView, EmptyView>(itemId: itemId,
                                               title: title,
                                               source: source,
                                               flipImage: flipImage,
                                               requestInfo: requestInfo,
                                               isEditing: $isEditing,
                                               isSelected: isSelected,
                                               selectionStyle: selectionStyle,
                                               ribbonText: ribbonText,
                                               animate: animate,
                                               resizingMode: resizingMode,
                                               onTapped: onTapped,
                                               onSelectorTapped: onSelectorTapped)
    }
}
