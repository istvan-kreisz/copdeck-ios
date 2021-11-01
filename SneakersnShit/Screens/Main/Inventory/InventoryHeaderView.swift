//
//  InventoryHeaderView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/30/21.
//

import SwiftUI

struct TextBox {
    let title: String
    let text: String
}

struct InventoryHeaderView: View {
    let userId: String
    @Binding var settingsPresented: Bool
    @Binding var showImagePicker: Bool
    @Binding var showSellerStats: Bool
    @Binding var profileImageURL: URL?
    @Binding var username: String
    @Binding var facebookURL: String?

    var textBox1: TextBox
    var textBox2: TextBox
    var isOwnProfile: Bool = true
    let isContentLocked: Bool
    var updateUsername: (() -> Void)?
    var linkFacebookProfile: (() -> Void)?
    var showChannel: ((Result<(Channel, String), AppError>) -> Void)?

    let facebookLogoSize: CGFloat = 18

    private func facebookAccountButton() -> some View {
        Button {
            if let linkFacebookProfile = linkFacebookProfile, isOwnProfile {
                linkFacebookProfile()
            } else if let facebookURL = facebookURL {
                if let url = URL(string: facebookURL) {
                    UIApplication.shared.open(url)
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text(facebookURL != nil ? "View facebook account" : "Link your facebook account")
                    .font(.medium(size: 14))
                    .foregroundColor(.customText2)
                    .underline()
                Image("facebook")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(.customWhite)
                    .scaledToFit()
                    .frame(width: facebookLogoSize * 0.6, height: facebookLogoSize * 0.6)
                    .centeredVertically()
                    .frame(width: facebookLogoSize, height: facebookLogoSize)
                    .background(Color(r: 66, g: 103, b: 178))
                    .cornerRadius(facebookLogoSize / 2)
            }
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            if isOwnProfile {
                HStack {
                    Text("Inventory")
                        .tabTitle()
                    Spacer()
                    Button(action: {
                        settingsPresented = true
                    }, label: {
                        ZStack {
                            Circle().stroke(Color.customAccent1, lineWidth: 2)
                                .frame(width: 38, height: 38)
                            Image("cog")
                                .renderingMode(.template)
                                .frame(height: 17)
                                .foregroundColor(.customBlack)
                        }
                    })
                }
            }

            VStack(spacing: 10) {
                ProfileImageView(showImagePicker: $showImagePicker, profileImageURL: $profileImageURL, isEditable: isOwnProfile)
                if let updateUsername = updateUsername {
                    VStack(alignment: .center, spacing: 5) {
                        TextFieldUnderlined(text: $username,
                                            placeHolder: "username",
                                            color: .customText1,
                                            dismissKeyboardOnReturn: false,
                                            icon: nil,
                                            keyboardType: .default,
                                            isSecureField: false,
                                            textAlignment: TextAlignment.center,
                                            trailingPadding: 0,
                                            addLeadingPadding: false,
                                            height: nil,
                                            onFinishedEditing: updateUsername)
                            .frame(width: 150)

                        if linkFacebookProfile != nil, isOwnProfile {
                            facebookAccountButton()
                        }

                        AccessoryButton(title: "See seller stats",
                                        color: .customAccent1,
                                        textColor: .customText1,
                                        width: 155,
                                        imageName: "chevron.right",
                                        buttonPosition: .right,
                                        isContentLocked: isContentLocked,
                                        tapped: { showSellerStats = true })
                            .padding(.top, 15)
                    }
                } else {
                    VStack(alignment: .center, spacing: 5) {
                        Text(username)
                            .foregroundColor(.customText1)
                            .font(.bold(size: 22))

                        if facebookURL != nil {
                            facebookAccountButton()
                        }

                        if let showChannel = showChannel {
                            AccessoryButton(title: "Message \(username.isEmpty ? "owner" : username)",
                                            color: .customAccent1,
                                            textColor: .customText1,
                                            width: 155,
                                            imageName: "chevron.right",
                                            buttonPosition: .right,
                                            isContentLocked: isContentLocked,
                                            tapped: {
                                                guard let ownUserId = DerivedGlobalStore.default.globalState.user?.id else { return }
                                                AppStore.default
                                                    .send(.main(action: .getOrCreateChannel(userIds: [userId, ownUserId], completion: { result in
                                                        switch result {
                                                        case let .failure(error):
                                                            showChannel(.failure(error))
                                                        case let .success(channel):
                                                            showChannel(.success((channel, userId)))
                                                        }
                                                    })))

                                            })
                                .padding(.top, 15)
                        }
                    }
                }

                HStack(alignment: .bottom) {
                    VStack(spacing: 2) {
                        Text(textBox1.text)
                            .font(.bold(size: 20))
                            .foregroundColor(.customText1)
                            .lockedContent(style: .hideOriginal, lockSize: 20, lockEnabled: updateUsername != nil)
                        Text(textBox1.title)
                            .font(.regular(size: 15))
                            .foregroundColor(.customText2)
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text(textBox2.text)
                            .font(.bold(size: 20))
                            .foregroundColor(.customText1)
                            .lockedContent(style: .hideOriginal, lockSize: 20, lockEnabled: updateUsername != nil)
                        Text(textBox2.title)
                            .font(.regular(size: 15))
                            .foregroundColor(.customText2)
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding(.bottom, 18)
        .buttonStyle(PlainButtonStyle())
        .listRow(backgroundColor: .customWhite)
    }
}
