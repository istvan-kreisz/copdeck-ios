//
//  FeedView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/28/21.
//

import SwiftUI
import Combine

struct FeedView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 19) {
                Text("Feed")
                    .foregroundColor(.customText1)
                    .font(.bold(size: 35))
                    .leftAligned()
                    .padding(.leading, 6)
                    .padding(.horizontal, 28)
                Spacer()
            }
            VStack(spacing: 20) {
                Text("Coming soon...")
                    .foregroundColor(.customText1)
                    .font(.regular(size: 20))

                Button {
                    guard let url = URL(string: "https://copdeck.com/") else { return }
                    UIApplication.shared.open(url)
                } label: {
                    Text("Visit our website to learn more")
                        .font(.bold(size: 15))
                        .foregroundColor(.customBlue)
                        .underline()
                }
            }
            .centeredVertically()
            .centeredHorizontally()
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            FeedView()
                .environmentObject(AppStore.default)
        }
    }
}
