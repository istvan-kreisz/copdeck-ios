//
//  ProfilePhotoSelectorView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/28/21.
//

import SwiftUI

struct ProfilePhotoSelectorView: View {
    private static let profileImageSize: CGFloat = 108

    @Binding var showImagePicker: Bool
    @Binding var profileImageURL: URL?

    var body: some View {
        ZStack {
            Color.customAccent1.frame(width: Self.profileImageSize, height: Self.profileImageSize)

            if let profileImageURL = profileImageURL {
                ImageView(withRequest: profileImageURL,
                          size: Self.profileImageSize,
                          aspectRatio: 1.0,
                          flipImage: false,
                          showPlaceholder: true,
                          resizingMode: .aspectFill)
                    .frame(width: Self.profileImageSize, height: Self.profileImageSize)
            } else {
                Image("profileLarge")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Self.profileImageSize * 0.35)
                    .foregroundColor(Color.customWhite)
            }
            Button(action: {
                showImagePicker = true
            }, label: {
                ZStack {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: Self.profileImageSize, height: Self.profileImageSize / 2)
                        ZStack {
                            Rectangle()
                                .fill(Color.customBlack.opacity(0.2))
                                .frame(width: Self.profileImageSize, height: Self.profileImageSize / 2)
                            Text("Select photo")
                                .font(.bold(size: 12))
                                .foregroundColor(.customWhite)
                                .padding(.bottom, 5)
                        }
                        .frame(width: Self.profileImageSize, height: Self.profileImageSize / 2)
                    }
                    .frame(width: Self.profileImageSize, height: Self.profileImageSize)
                }
            })
        }
        .frame(width: Self.profileImageSize, height: Self.profileImageSize)
        .cornerRadius(Self.profileImageSize / 2)
    }
}
