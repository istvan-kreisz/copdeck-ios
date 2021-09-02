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
    @Binding var settingsPresented: Bool
    @Binding var showImagePicker: Bool
    @Binding var profileImageURL: URL?
    @Binding var username: String

    var textBox1: TextBox
    var textBox2: TextBox
    var isOwnProfile: Bool = true
    var updateUsername: (() -> Void)?

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            if isOwnProfile {
                HStack {
                    Text("Inventory")
                        .foregroundColor(.customText1)
                        .font(.bold(size: 35))
                        .leftAligned()
                        .padding(.leading, 6)
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

            VStack(spacing: 15) {
                ProfileImageView(showImagePicker: $showImagePicker, profileImageURL: $profileImageURL, isEditable: isOwnProfile)
                if let updateUsername = updateUsername {
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
                                        onFinishedEditing: updateUsername)
                        .frame(width: 150)
                } else {
                    Text(username)
                        .foregroundColor(.customText1)
                        .font(.bold(size: 22))
                }

                HStack {
                    VStack(spacing: 2) {
                        Text(textBox1.text)
                            .font(.bold(size: 20))
                            .foregroundColor(.customText1)
                        Text(textBox1.title)
                            .font(.regular(size: 15))
                            .foregroundColor(.customText2)
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text(textBox2.text)
                            .font(.bold(size: 20))
                            .foregroundColor(.customText1)
                        Text(textBox2.title)
                            .font(.regular(size: 15))
                            .foregroundColor(.customText2)
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding(.bottom, 22)
        .buttonStyle(PlainButtonStyle())
        .listRow(backgroundColor: .customWhite)
    }
}
