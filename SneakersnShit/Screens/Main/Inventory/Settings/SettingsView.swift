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

    @State var isNotificationEnabled = false
    @State var yo = "first"
    @State var sleepgoal = 7

    init() {
        self._settings = State(initialValue: .default)
    }

    var body: some View {
        NavigationView {
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

                Section(header: Text("Country")) {
                    let country = Binding<String>(get: { settings.feeCalculation.country.name },
                                                  set: { new in
                                                      if let country = Country.allCases.first(where: { $0.name == new }) {
                                                          settings.feeCalculation.country = country
                                                      }
                                                  })
                    Picker(selection: country, label: Text("Choose your country")) {
                        ForEach(Country.allCases.map { $0.name }, id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section(header: Text("StockX")) {
                    let sellerLevel = Binding<String>(get: {
                                                          (settings.feeCalculation.stockx?.sellerLevel.rawValue).map { "Level \($0)" } ?? ""
                                                      },
                                                      set: { new in
                                                          if let level = CopDeckSettings.FeeCalculation.StockX.SellerLevel.allCases
                                                              .first(where: { new.contains("\($0.rawValue)") }) {
                                                              settings.feeCalculation.stockx?.sellerLevel = level
                                                          }
                                                      })

                    Picker(selection: sellerLevel, label: Text("Your StockX seller level")) {
                        ForEach(CopDeckSettings.FeeCalculation.StockX.SellerLevel.allCases.map { "Level \($0)" }, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    
                }
            }
            .navigationBarTitle(Text("Settings"))
            .onChange(of: settings) { value in
                print("------------------")
                print(value)
                print("------------------")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            SettingsView()
                .environmentObject(AppStore.default)
        }
    }
}
