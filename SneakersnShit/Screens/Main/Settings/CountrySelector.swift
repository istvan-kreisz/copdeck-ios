//
//  CountrySelector.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/27/21.
//

import SwiftUI

struct CountrySelector: View {
    @EnvironmentObject var store: AppStore
    @State private var settings: CopDeckSettings

    init(settings: CopDeckSettings) {
        self._settings = State(initialValue: settings)
    }

    var body: some View {
        VStack {
            Text("Select your country")
                .foregroundColor(.customText1)
                .font(.bold(size: 35))
                .leftAligned()
                .padding(.leading, 6)
                .padding(.horizontal, 28)
                .withDefaultPadding(padding: .top)

            List {
                ForEach(Country.allCases.map { (c: Country) -> String in c.name }, id: \.self) { name in
                    Button(action: {
                        settings.feeCalculation.country = Country.allCases.first(where: { $0.name == name }) ?? .US
                    }) {
                            HStack {
                                Text(name)
                                Spacer()
                                if settings.feeCalculation.country.name == name {
                                    ZStack {
                                        Circle()
                                            .fill(Color.customBlue)
                                            .frame(width: 25, height: 25)
                                        Image(systemName: "checkmark")
                                            .font(.bold(size: 12))
                                            .foregroundColor(.customWhite)
                                    }
                                }
                            }
                    }
                }
                Color.clear.padding(.bottom, 137)
            }
        }
        .withFloatingButton(button: NextButton(text: "Select country",
                                               size: .init(width: 260, height: 60),
                                               color: .customBlack,
                                               tapped: selectCountryTapped)
                .centeredHorizontally()
                .padding(.top, 20))
        .hideKeyboardOnScroll()
    }

    private func selectCountryTapped() {
        store.send(.main(action: .updateSettings(settings: settings)))
    }
}

struct CountrySelector_Previews: PreviewProvider {
    static var previews: some View {
        return
            MainContainerView()
                .environmentObject(AppStore.default)
    }
}
