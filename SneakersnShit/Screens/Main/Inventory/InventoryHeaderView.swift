//
//  InventoryHeaderView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/30/21.
//

import SwiftUI

struct InventoryHeaderView: View {
    @Binding var settingsPresented: Bool
    @Binding var showImagePicker: Bool
    @Binding var profileImageURL: URL?
    @Binding var username: String

    var inventoryValue: PriceWithCurrency?
    var inventoryItemsCount: Int
    var updateUsername: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
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

            VStack(spacing: 15) {
                ProfilePhotoSelectorView(showImagePicker: $showImagePicker, profileImageURL: $profileImageURL)
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

                HStack {
                    VStack(spacing: 2) {
                        Text(inventoryValue?.asString ?? "-")
                            .font(.bold(size: 20))
                            .foregroundColor(.customText1)
                        Text("Inventory Value")
                            .font(.regular(size: 15))
                            .foregroundColor(.customText2)
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("\(inventoryItemsCount)")
                            .font(.bold(size: 20))
                            .foregroundColor(.customText1)
                        Text("Inventory Size")
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
