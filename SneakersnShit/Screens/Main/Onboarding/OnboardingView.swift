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
    var secondaryButtonText: String?
    let buttonTapped: () -> Void
    var secondaryButtonTapped: (() -> Void)?
    
    var imageHeight: CGFloat {
        UIScreen.isSmallScreen ? 350 : 450
    }

    var buttonWidth: CGFloat {
        UIScreen.isSmallScreen ? 260 : 280
    }
    
    var buttonHeight: CGFloat {
        UIScreen.isSmallScreen ? 48 : 53
    }
    
    var buttonFontSize: CGFloat {
        UIScreen.isSmallScreen ? 15 : 16
    }

    @State private var isAnimating: Bool = false

    var body: some View {
        VStack(spacing: 20.0) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: imageHeight)
                .scaleEffect(isAnimating ? 1 : 0.9)
                .layoutPriority(1)

            Spacer()
                .layoutPriority(0)

            Text(titleText)
                .font(.bold(size: 24))
                .foregroundColor(.customText1)
                .layoutPriority(1)

            Text(subtitleText)
                .font(.medium(size: 18))
                .multilineTextAlignment(.center)
                .foregroundColor(.customText2)
                .layoutPriority(1)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 15) {
                NextButton(text: buttonText,
                           size: .init(width: buttonWidth, height: buttonHeight),
                           color: .customBlack,
                           tapped: buttonTapped)

                if let secondaryButtonText = secondaryButtonText, let secondaryButtonTapped = secondaryButtonTapped {
                    RoundedButton<EmptyView>(text: secondaryButtonText,
                                             width: buttonWidth,
                                             height: buttonHeight,
                                             color: .clear,
                                             borderColor: .customBlack,
                                             textColor: .customBlack,
                                             accessoryView: nil,
                                             tapped: secondaryButtonTapped)
                }
            }
            .padding(.bottom, 55)
            .padding(.top, 10)
            .layoutPriority(1)
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
