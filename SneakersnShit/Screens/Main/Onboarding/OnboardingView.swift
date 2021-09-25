//
//  OnboardingView.swift
//  Onboarding Quality Weather
//
//  Created by Rinalds Domanovs on 16/04/2021.
//

import SwiftUI

struct OnboardingView: View {
    let imageName: String
    let titleText: String
    let subtitleText: String
    var buttonText: String = "Next"
    let buttonTapped: () -> Void
    @State private var isAnimating: Bool = false

    var body: some View {
        VStack(spacing: 20.0) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: UIScreen.isSmallScreen ? 350 : 480)
                .scaleEffect(isAnimating ? 1 : 0.9)

            Spacer()

            Text(titleText)
                .font(.bold(size: 24))
                .foregroundColor(.customText1)

            Text(subtitleText)
                .font(.medium(size: 18))
                .multilineTextAlignment(.center)
                .foregroundColor(.customText2)

            NextButton(text: buttonText,
                       size: .init(width: 260, height: 60),
                       color: .customBlack,
                       tapped: buttonTapped)
                .padding(.bottom, 55)
                .padding(.top, 10)
        }
        .withDefaultPadding(padding: .horizontal)
        .onAppear(perform: {
            isAnimating = false
            withAnimation(.easeOut(duration: 0.5)) {
                self.isAnimating = true
            }
        })
    }
}
