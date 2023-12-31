//
//  RootOnboardingView.swift
//  Onboarding Quality Weather
//
//  Created by Rinalds Domanovs on 16/04/2021.
//

import SwiftUI

struct RootOnboardingView: View {
    @AppStorage(UserDefaults.Keys.needsAppOnboarding.rawValue) private var needsAppOnboarding: Bool = true
    @State private var currentTab = 0

    private func nextTapped() {
        if currentTab == 8 {
            needsAppOnboarding = false
        } else {
            currentTab += 1
        }
    }

    var body: some View {
        TabView(selection: $currentTab) {
            OnboardingView(imageName: "onboarding-feed",
                           titleText: "Welcome to CopDeck!",
                           subtitleText: "CopDeck helps you manage & share your reselling inventory and compare prices on different reselling sites.",
                           buttonTapped: nextTapped)
                .tag(0)
            OnboardingView(imageName: "onboarding-search",
                           titleText: "Search sneakers & collectibles",
                           subtitleText: "Use the search tab to find the sneakers, apparels, collectibles you're looking for.",
                           buttonTapped: nextTapped)
                .tag(1)
            OnboardingView(imageName: "onboarding-prices",
                           titleText: "Compare prices",
                           subtitleText: "Tap on an item to see how much it goes for on reselling sites like StockX, GOAT, Klekt and Restocks.",
                           buttonTapped: nextTapped)
                .tag(2)
            OnboardingView(imageName: "onboarding-inventory",
                           titleText: "Track your inventory",
                           subtitleText: "Use our advanced inventory manager to track all your owned & sold kicks. Our algorithm automatically shows you the best price for all your pairs based on market data.",
                           buttonTapped: nextTapped)
                .tag(3)
            OnboardingView(imageName: "onboarding-share",
                           titleText: "Share your sneaks",
                           subtitleText: "Share your inventory on our in-app feed. Or generate a link to easily share with anyone, even if they don't have the CopDeck app.",
                           buttonTapped: nextTapped)
                .tag(4)
            OnboardingView(imageName: "onboarding-feed",
                           titleText: "Browse the CopDeck feed",
                           subtitleText: "Use our in-app feed to see what other users have on stock, or use it to share your own collections.",
                           buttonTapped: nextTapped)
                .tag(5)
            OnboardingView(imageName: "onboarding-profile",
                           titleText: "Follow other sneakerheads",
                           subtitleText: "See what other people are up to in the reselling game by checking out their CopDeck profiles.",
                           buttonTapped: nextTapped)
                .tag(6)
            OnboardingView(imageName: "onboarding-import",
                           titleText: "Spreadsheet import",
                           subtitleText: "Import your reseller spreadsheet with just a single click.",
                           buttonTapped: nextTapped)
                .tag(7)
            OnboardingView(imageName: "onboarding-chat",
                           titleText: "Chat & Enable notifications",
                           subtitleText: "Chat with other CopDeck users using our built-in chat. Enable notifications to make sure you don't miss anything.",
                           buttonText: "Enable notifications",
                           secondaryButtonText: "Not now",
                           buttonTapped: {
                               AppStore.default.environment.pushNotificationService.requestPermissionsIfNotAsked(completion: nextTapped)
                           },
                           secondaryButtonTapped: nextTapped)
                .tag(8)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}
