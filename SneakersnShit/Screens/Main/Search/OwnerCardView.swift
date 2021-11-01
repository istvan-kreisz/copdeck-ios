//
//  OwnerCardView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/2/21.
//

import SwiftUI

struct OwnerCardView: View {
    private static let profileImageSize: CGFloat = 38

    let user: User
    let didTapMessage: (Result<(Channel, String), AppError>) -> Void

    var body: some View {
        VStack(spacing: 9) {
            Text("Owner")
                .font(.bold(size: 12))
                .foregroundColor(.customText2)
                .leftAligned()

            HStack {
                ImageView(source: .url(user.imageURL),
                          size: Self.profileImageSize,
                          aspectRatio: 1.0,
                          flipImage: false,
                          showPlaceholder: true,
                          resizingMode: .aspectFill)
                    .frame(width: Self.profileImageSize, height: Self.profileImageSize)
                    .cornerRadius(Self.profileImageSize / 2)
                VStack(alignment: .leading, spacing: 3) {
                    Text(user.name ?? "")
                        .font(.bold(size: 14))
                        .foregroundColor(.customText1)

                    Button {
                        if let userId = DerivedGlobalStore.default.globalState.user?.id {
                            AppStore.default.send(.main(action: .getOrCreateChannel(userIds: [user.id, userId], completion: { result in
                                switch result {
                                case let .failure(error):
                                    didTapMessage(.failure(error))
                                case let .success(channel):
                                    didTapMessage(.success((channel, userId)))
                                }
                            })))
                        }
                    } label: {
                        HStack {
                            Text("Message \(user.name ?? "owner")")
                                .lineLimit(1)
                                .font(.bold(size: 13))
                                .foregroundColor(.customText2)
                                .layoutPriority(2)
                            ZStack {
                                Circle()
                                    .fill(Color.customAccent1.opacity(0.2))
                                    .frame(width: 16, height: 16)
                                Image(systemName: "chevron.right")
                                    .font(.bold(size: 7))
                                    .foregroundColor(Color.customAccent1)
                            }.frame(width: 16, height: 16)
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .asCard()
        .withDefaultPadding(padding: .horizontal)
        .padding(.vertical, 6)
    }
}
