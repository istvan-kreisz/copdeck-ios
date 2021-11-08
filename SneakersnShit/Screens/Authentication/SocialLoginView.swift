//
//  SocialLoginView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/1/21.
//

import SwiftUI

struct SocialLoginView: View {
    @Binding var referralCode: String
    
    private var refCode: String? {
        referralCode.isEmpty ? nil : referralCode
    }

    var body: some View {
        HStack(spacing: 10) {
            SignInButton(imageName: "apple",
                         text: "Sign in with Apple",
                         imageColor: .customWhite,
                         backgroundColor: .customBlack,
                         action: { AppStore.default.send(.authentication(action: .signInWithApple(referralCode: refCode))) },
                         initBlock: {})
            SignInButton(imageName: "google",
                         text: "Sign in with Google",
                         imageColor: nil,
                         backgroundColor: .customWhite,
                         action: { AppStore.default.send(.authentication(action: .signInWithGoogle(referralCode: refCode))) },
                         initBlock: {})
//            SignInButton(imageName: "facebook",
//                         text: "Sign in with Facebook",
//                         imageColor: nil,
//                         backgroundColor: Color(r: 66, g: 103, b: 178),
//                         action: { store.send(.authentication(action: .signInWithFacebook(referralCode: refCode))) },
//                         initBlock: {})
            Spacer()
        }
    }
}
