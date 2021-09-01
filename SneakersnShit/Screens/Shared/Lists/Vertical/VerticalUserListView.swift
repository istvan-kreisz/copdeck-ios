//
//  VerticalUserListView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import SwiftUI
import Combine

struct VerticalUserListView: View {
    @Binding var users: [User]
    @Binding var selectedUser: User?
    @Binding var isLoading: Bool

    let bottomPadding: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isLoading {
                CustomSpinner(text: "Loading...", animate: true)
                    .padding(.horizontal, 22)
                    .padding(.top, 5)
            }

            VerticalListView(bottomPadding: bottomPadding) {
                ForEach(users) { (user: User) in
                    UserListItem(user: user, selectedUser: $selectedUser)
                }
            }
            .padding(.top, 5)
        }
    }
}
