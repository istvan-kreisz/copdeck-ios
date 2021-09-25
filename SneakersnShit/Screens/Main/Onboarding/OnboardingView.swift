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
                .scaleEffect(isAnimating ? 1 : 0.9)

            Spacer()

            Text(titleText)
                .font(.title2)
                .bold()
                .foregroundColor(.customText1)

            Text(subtitleText)
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
                .foregroundColor(.customText2)

            NextButton(text: buttonText,
                       size: .init(width: 260, height: 60),
                       color: .customBlack,
                       tapped: buttonTapped)

            Spacer(minLength: 30)
        }
        .onAppear(perform: {
            isAnimating = false
            withAnimation(.easeOut(duration: 0.5)) {
                self.isAnimating = true
            }
        })
    }
}
