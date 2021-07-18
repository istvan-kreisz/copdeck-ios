//
//  NavigationBar.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/18/21.
//

import SwiftUI

struct NavigationBar: View {
    @Environment(\.presentationMode) var presentationMode

    let title: String
    let isBackButtonVisible: Bool

    var body: some View {
        HStack {
            if isBackButtonVisible {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                        ZStack {
                            Circle()
                                .fill(Color.customBlack)
                                .frame(width: 38, height: 38, alignment: .center)
                            Image(systemName: "chevron.left")
                                .font(.bold(size: 14))
                                .foregroundColor(.white)
                        }
                }
            }
            Spacer()
            Text(title)
                .font(.bold(size: 45))
                .foregroundColor(.customText1)
                .padding(.leading, isBackButtonVisible ? -38 : 0)
                .frame(maxWidth: UIScreen.screenWidth - 180 + (isBackButtonVisible ? 0 : 130))
                .lineLimit(1)
                .background(Capsule().fill(Color.customAccent1))
            Spacer()
        }
        .withDefaultPadding(padding: [.leading, .trailing])
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(title: "yo", isBackButtonVisible: true)
    }
}
