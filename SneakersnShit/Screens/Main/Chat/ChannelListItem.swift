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
    
    var body: some View {
        if let user = channel.users.first(where: { $0.id != userId }) {
            HStack {
                ImageView(source: .url(user.imageURL),
                          size: Self.profileImageSize,
                          aspectRatio: 1.0,
                          flipImage: false,
                          showPlaceholder: true,
                          resizingMode: .aspectFill)
                    .frame(width: Self.profileImageSize, height: Self.profileImageSize)
                    .cornerRadius(Self.profileImageSize / 2)
                    .layoutPriority(2)
                VStack(alignment: .leading, spacing: 5) {
                    Text(user.name ?? "anonymus")
                        .font(.bold(size: 14))
                        .foregroundColor(.customText1)
                    Text(channel.lastMessage?.content ?? "")
                        .font(.regular(size: 14))
                        .foregroundColor(.customText2)
                }
                .layoutPriority(2)
                Spacer()
                
            }
        }
    }
}
