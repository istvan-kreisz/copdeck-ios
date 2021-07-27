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

    init(settings: CopDeckSettings) {
        self._settings = State(initialValue: settings)
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

                Section(header: Text("StockX additional fees (%)")) {
                    let taxes = Binding<String>(get: { (settings.feeCalculation.stockx?.taxes).asString },
                                                set: { new in
                                                    if let taxes = Double(new) {
                                                        settings.feeCalculation.stockx?.taxes = taxes
                                                    }
                                                })
                    TextField("0%", text: taxes)
                        .keyboardType(.numberPad)
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
                    let cashoutFee = Binding<String>(get: { settings.feeCalculation.goat?.cashOutFee == .regular ? "Include" : "Don't include" },
                                                     set: { new in
                                                         if new == "Include" {
                                                             settings.feeCalculation.goat?.cashOutFee = .regular
                                                         } else {
                                                             settings.feeCalculation.goat?.cashOutFee = CopDeckSettings.FeeCalculation.Goat.CashoutFee.none
                                                         }
                                                     })

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

                Button(action: {
                    store.send(.authentication(action: .signOut))
                }, label: {
                    Text("Sign Out")
                        .font(.bold(size: 18))
                        .foregroundColor(.customRed)
                })
                .centeredHorizontally()
            }
            .navigationBarTitle(Text("Settings"))
            .onChange(of: settings) { value in
                store.send(.main(action: .updateSettings(settings: value)))
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            SettingsView(settings: .default)
                .environmentObject(AppStore.default)
        }
    }
}
