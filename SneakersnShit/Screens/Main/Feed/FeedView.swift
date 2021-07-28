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
        VStack(alignment: .leading, spacing: 19) {
            Text("Feed")
                .foregroundColor(.customText1)
                .font(.bold(size: 35))
                .leftAligned()
                .padding(.leading, 6)
                .padding(.horizontal, 28)
            Spacer()
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
