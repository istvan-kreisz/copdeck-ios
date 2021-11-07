//
//  ChannelListItem.swift
//  CopDeck
//
//  Created by István Kreisz on 10/30/21.
//

import SwiftUI

struct ChannelListItem: View {
    static let profileImageSize: CGFloat = 58

    let channel: Channel
    let userId: String
    let didTapChannel: () -> Void
    let didTapUser: () -> Void

    var lastMessageContent: String {
        if let lastMessage = channel.updateInfo?.lastMessage {
            if lastMessage.userId == userId {
                return "Me: \(lastMessage.content)"
            } else {
                return "\(channel.messagePartner(userId: userId)?.name ?? "Anonymus"): \(lastMessage.content)"
            }
        } else {
            return ""
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ImageView(source: .url(channel.messagePartner(userId: userId)?.imageURL),
                      size: Self.profileImageSize,
                      aspectRatio: 1.0,
                      flipImage: false,
                      showPlaceholder: true,
                      resizingMode: .aspectFill)
                .frame(width: Self.profileImageSize, height: Self.profileImageSize)
                .cornerRadius(Self.profileImageSize / 2)
                .layoutPriority(2)
                .onTapGesture(perform: didTapUser)
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Spacer()
                    Text(channel.messagePartner(userId: userId)?.name ?? "Anonymus")
                        .font(.extraBold(size: 17))
                        .foregroundColor(.customText1)
                        .layoutPriority(2)
                    Text(lastMessageContent)
                        .font(channel.hasUnreadMessages(userId: userId) ? .semiBold(size: 14) : .regular(size: 14))
                        .foregroundColor(channel.hasUnreadMessages(userId: userId) ? .customText1 : .customText2)
                        .layoutPriority(2)
                    Spacer()
                }
                .layoutPriority(2)
                Spacer()
                if channel.hasUnreadMessages(userId: userId) {
                    Circle().fill(Color.customRed.opacity(0.3))
                        .frame(width: 20, height: 20)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: didTapChannel)
        }
        .frame(height: Self.profileImageSize)
    }
}
