//
//  SettingsView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @State private var settings: CopDeckSettings
    @State private var selectedStores: [String] = []
    @State private var countries: [String] = []

    @Binding private var isPresented: Bool

    init(settings: CopDeckSettings, isPresented: Binding<Bool>) {
        self._settings = State(initialValue: settings)
        self._selectedStores = State(initialValue: settings.displayedStores.compactMap { Store.store(withId: $0)?.name.rawValue })
        self._isPresented = isPresented
        self._countries = State(initialValue: [settings.feeCalculation.country.name])
    }

    private func selectCountryTapped() {
        if let countryName = self.countries.first,
           let country = Country.allCases.first(where: { $0.name == countryName }),
           settings.feeCalculation.country != country {
            settings.feeCalculation.country = country
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Settings")
                        .foregroundColor(.customText1)
                        .font(.bold(size: 35))
                        .padding(.leading, 12)
                        .leftAligned()
                    Spacer()
                }
                Form {
                    Section(header: Text("Currency")) {
                        let currency = Binding<String>(get: { settings.currency.symbol.rawValue },
                                                       set: { new in
                                                           if let symbol = Currency.CurrencySymbol(rawValue: new),
                                                              let currency = ALLCURRENCIES.first(where: { $0.symbol == symbol }) {
                                                               settings.currency = currency
                                                           }
                                                       })

                        Picker(selection: currency, label: Text("Choose your currency")) {
                            ForEach(ALLCURRENCIES.map { $0.symbol.rawValue }, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    Section(header: Text("Show prices from")) {
                        ListSelectorMenu(title: "Enabled stores",
                                         selectorScreenTitle: "Select sites to display",
                                         buttonTitle: "Select sites",
                                         enableMultipleSelection: true,
                                         options: ALLSTORES.map { $0.name.rawValue },
                                         selectedOptions: $selectedStores) {
                                settings.displayedStores = selectedStores.compactMap { Store.store(withName: $0)?.id }
                        }
                    }

                    Section(header: Text("Country")) {
                        ListSelectorMenu(title: "Country",
                                         selectorScreenTitle: "Select your country",
                                         buttonTitle: "Select country",
                                         enableMultipleSelection: false,
                                         options: Country.allCases.map { $0.name },
                                         selectedOptions: $countries,
                                         buttonTapped: selectCountryTapped)
                    }

                    Section(header: Text("StockX seller level")) {
                        let sellerLevel = Binding<String>(get: {
                                                              (settings.feeCalculation.stockx?.sellerLevel.rawValue).map { "Level \($0)" } ?? ""
                                                          },
                                                          set: { new in
                                                              if let level = CopDeckSettings.FeeCalculation.StockX.SellerLevel.allCases
                                                                  .first(where: { new.contains("\($0.rawValue)") }) {
                                                                  settings.feeCalculation.stockx?.sellerLevel = level
                                                              }
                                                          })

                        Picker(selection: sellerLevel, label: Text("StockX seller level")) {
                            ForEach(CopDeckSettings.FeeCalculation.StockX.SellerLevel.allCases.map { "Level \($0.rawValue)" }, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    if settings.feeCalculation.stockx?.sellerLevel == .level4 || settings.feeCalculation.stockx?.sellerLevel == .level5 {
                        Section(header: Text("StockX successful ship bonus (-1%)")) {
                            let shipBonus =
                                Binding<String>(get: { (settings.feeCalculation.stockx?.successfulShipBonus == true) ? "Include" : "Don't include" },
                                                set: { new in settings.feeCalculation.stockx?.successfulShipBonus = new == "Include" })

                            Picker(selection: shipBonus, label: Text("StockX successful ship bonus (-1%)")) {
                                ForEach(["Include", "Don't include"], id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        Section(header: Text("StockX quick ship bonus (-1%)")) {
                            let shipBonus = Binding<String>(get: { (settings.feeCalculation.stockx?.quickShipBonus == true) ? "Include" : "Don't include" },
                                                            set: { new in settings.feeCalculation.stockx?.quickShipBonus = new == "Include" })

                            Picker(selection: shipBonus, label: Text("StockX quick ship bonus (-1%)")) {
                                ForEach(["Include", "Don't include"], id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }

                    if settings.feeCalculation.country == .US || settings.feeCalculation.country == .USE {
                        Section(header: Text("StockX buyer's taxes (%)")) {
                            let taxes = Binding<String>(get: { (settings.feeCalculation.stockx?.taxes).asString },
                                                        set: { new in
                                                            if let taxes = Double(new) {
                                                                settings.feeCalculation.stockx?.taxes = taxes
                                                            }
                                                        })
                            TextField("0%", text: taxes)
                                .keyboardType(.numberPad)
                        }
                    }

                    Section(header: Text("GOAT commission fees")) {
                        let commissionFees = Binding<String>(get: {
                                                                 (settings.feeCalculation.goat?.commissionPercentage.rawValue).map { "\($0)%" } ?? ""
                                                             },
                                                             set: { new in
                                                                 if let fees = CopDeckSettings.FeeCalculation.Goat.CommissionPercentage.allCases
                                                                     .first(where: { new.contains("\($0.rawValue)") }) {
                                                                     settings.feeCalculation.goat?.commissionPercentage = fees
                                                                 }
                                                             })

                        Picker(selection: commissionFees, label: Text("GOAT commission fees")) {
                            ForEach(CopDeckSettings.FeeCalculation.Goat.CommissionPercentage.allCases.map { "\($0.rawValue)%" }, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    Section(header: Text("GOAT include cash-out fee (2.9%)")) {
                        let cashoutFee = Binding<String>(get: { settings.feeCalculation.goat?.cashOutFee == true ? "Include" : "Don't include" },
                                                         set: { new in settings.feeCalculation.goat?.cashOutFee = new == "Include" ? true : false })
                        Picker(selection: cashoutFee, label: Text("GOAT include cash-out fee (2.9%)")) {
                            ForEach(["Include", "Don't include"], id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    Section(header: Text("GOAT additional fees (%)")) {
                        let taxes = Binding<String>(get: { (settings.feeCalculation.goat?.taxes).asString },
                                                    set: { new in
                                                        if let taxes = Double(new) {
                                                            settings.feeCalculation.goat?.taxes = taxes
                                                        }
                                                    })
                        TextField("0%", text: taxes)
                            .keyboardType(.numberPad)
                    }

                    VStack(alignment: .center, spacing: 30) {
                        Button(action: {
                            store.send(.authentication(action: .signOut))
                        }, label: {
                            Text("Sign Out")
                                .font(.bold(size: 18))
                                .foregroundColor(.customRed)
                        })


                        Button(action: {
                            isPresented = false
                        }, label: {
                            Text("Done")
                                .font(.bold(size: 18))
                                .foregroundColor(.customBlue)
                        })
                    }
                }
            }
            .navigationbarHidden()
            .withDefaultPadding(padding: [.top])
            .onChange(of: settings) { value in
                store.send(.main(action: .updateSettings(settings: value)))
            }
        }
        .preferredColorScheme(.light)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            SettingsView(settings: .default, isPresented: .constant(true))
                .environmentObject(AppStore.default)
        }
    }
}
