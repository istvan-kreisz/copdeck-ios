//
//  UserListItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import SwiftUI

struct ProfileListItem: View {
    var profileData: ProfileData
    @Binding var selectedProfile: ProfileData?

    var body: some View {
        VerticalListItemWithAccessoryView1(title: profileData.user.name ?? "",
                                           imageURL: .init(url: profileData.user.imageURL?.absoluteString ?? "", store: nil),
                                           flipImage: false,
                                           requestInfo: [],
                                           isEditing: .constant(false),
                                           isSelected: false,
                                           ribbonText: nil,
                                           resizingMode: .aspectFill,
                                           accessoryView: EmptyView()) {
                selectedProfile = profileData
        }
    }
}
