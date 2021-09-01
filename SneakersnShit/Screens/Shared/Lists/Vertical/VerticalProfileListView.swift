//
//  VerticalUserListView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import SwiftUI
import Combine

struct VerticalProfileListView: View {
    @Binding var profiles: [ProfileData]
    @Binding var selectedProfile: ProfileData?
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
                ForEach(profiles) { (profileData: ProfileData) in
                    ProfileListItem(profileData: profileData, selectedProfile: $selectedProfile)
                }
            }
            .padding(.top, 5)
        }
    }
}
