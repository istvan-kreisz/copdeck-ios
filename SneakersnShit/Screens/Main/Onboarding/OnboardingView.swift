//
//  ContentView.swift
//  Onboarding Quality Weather
//
//  Created by Rinalds Domanovs on 16/04/2021.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentTab = 0

    var body: some View {
        TabView(selection: $currentTab) {
            OnboardingViewOne()
                .tag(0)
            OnboardingViewTwo()
                .tag(1)
            OnboardingViewThree()
                .tag(3)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}
