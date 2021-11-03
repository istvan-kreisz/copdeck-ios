//
//  CountrySelector.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/27/21.
//

import SwiftUI

struct CountrySelector: View {
    @State private var settings: CopDeckSettings
    @State private var countries: [String] = []

    init(settings: CopDeckSettings) {
        self._settings = State(initialValue: settings)
        self._countries = State(initialValue: [settings.feeCalculation.country.name])
    }

    var body: some View {
        ListSelector(title: "Select your country",
                     buttonTitle: "Select country",
                     enableMultipleSelection: false,
                     popBackOnSelect: false,
                     options: Country.allCases.map { $0.name }.sorted(),
                     selectedOptions: $countries,
                     buttonTapped: selectCountryTapped)
    }

    private func selectCountryTapped() {
        if let countryName = self.countries.first {
            settings.feeCalculation.country = Country.allCases.first(where: { $0.name == countryName }) ?? .US
            AppStore.default.send(.main(action: .updateSettings(settings: settings)))
        }
    }
}
