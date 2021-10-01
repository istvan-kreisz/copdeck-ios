//
//  SocialLoginView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/1/21.
//

import SwiftUI

struct SocialLoginView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        HStack(spacing: 10) {
            SignInButton(imageName: "apple",
                         text: "Sign in with Apple",
                         imageColor: .customWhite,
                         backgroundColor: .customBlack,
                         action: { store.send(.authentication(action: .signInWithApple)) },
                         initBlock: {})
            SignInButton(imageName: "google",
                         text: "Sign in with Google",
                         imageColor: nil,
                         backgroundColor: .customWhite,
                         action: { store.send(.authentication(action: .signInWithGoogle)) },
                         initBlock: {})
            SignInButton(imageName: "facebook",
                         text: "Sign in with Facebook",
                         imageColor: nil,
                         backgroundColor: Color(r: 66, g: 103, b: 178),
                         action: { store.send(.authentication(action: .signInWithFacebook)) },
                         initBlock: {})
            Spacer()
        }
    }
}
