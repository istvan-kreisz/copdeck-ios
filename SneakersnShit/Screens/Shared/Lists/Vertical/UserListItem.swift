//
//  UserListItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import SwiftUI

struct UserListItem: View {
    var user: User
    @Binding var selectedUser: User?

    var body: some View {
        VerticalListItemWithAccessoryView1(title: user.name ?? "",
                                           imageURL: .init(url: user.imageURL?.absoluteString ?? "", store: nil),
                                           flipImage: false,
                                           requestInfo: [],
                                           isEditing: .constant(false),
                                           isSelected: false,
                                           ribbonText: nil,
                                           resizingMode: .aspectFill,
                                           accessoryView: EmptyView()) {
                selectedUser = user
        }
    }
}
