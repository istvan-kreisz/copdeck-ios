//
//  RootOnboardingView.swift
//  Onboarding Quality Weather
//
//  Created by Rinalds Domanovs on 16/04/2021.
//

import SwiftUI

struct RootOnboardingView: View {
    @State private var currentTab = 0

    private func nextTapped() {
        currentTab += 1
    }

    var body: some View {
        TabView(selection: $currentTab) {
            OnboardingView(imageName: "onboarding-share",
                           titleText: "share bitches",
                           subtitleText: "la la la la la la la la la la la la la la la la la la",
                           buttonTapped: nextTapped)
                .tag(0)
            OnboardingView(imageName: "onboarding-share",
                           titleText: "share bitches",
                           subtitleText: "la la la la la la la la la la la la la la la la la la",
                           buttonTapped: nextTapped)
                .tag(1)
            OnboardingView(imageName: "onboarding-share",
                           titleText: "share bitches",
                           subtitleText: "la la la la la la la la la la la la la la la la la la",
                           buttonTapped: nextTapped)
                .tag(3)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}
