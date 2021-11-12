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
    let user: User
    @Binding var settingsPresented: Bool
    @Binding var addNewInventoryItemPresented: Bool
    @Binding var showImagePicker: Bool
    @Binding var showSellerStats: Bool
    @Binding var profileImageURL: URL?
    @Binding var username: String
    @Binding var countryIcon: String
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
                HStack(spacing: 10) {
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
                    
                    Button(action: {
                        addNewInventoryItemPresented = true
                    }, label: {
                        ZStack {
                            Circle().fill(Color.customBlue)
                                .frame(width: 38, height: 38)
                            Image("plus")
                                .renderingMode(.template)
                                .frame(height: 15)
                                .foregroundColor(.customWhite)
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
                        Text("\(username) \(countryIcon)" + ((DebugSettings.shared.isAdmin && user.notificationsEnabled == true) ? " *" : ""))
                            .foregroundColor(.customText1)
                            .font(.bold(size: 22))

                        if facebookURL != nil {
                            facebookAccountButton()
                        }

                        if let showChannel = showChannel, user.id != DerivedGlobalStore.default.globalState.user?.id {
                            AccessoryButton(title: "Message \(username.isEmpty ? "user" : username)",
                                            color: .customAccent1,
                                            textColor: .customText1,
                                            width: 155,
                                            imageName: "chevron.right",
                                            buttonPosition: .right,
                                            isContentLocked: isContentLocked,
                                            tapped: {
                                                guard let ownUser = DerivedGlobalStore.default.globalState.user else { return }
                                                AppStore.default
                                                    .send(.main(action: .getOrCreateChannel(users: [user, ownUser], completion: { result in
                                                        switch result {
                                                        case let .failure(error):
                                                            showChannel(.failure(error))
                                                        case let .success(channel):
                                                            showChannel(.success((channel, ownUser.id)))
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
