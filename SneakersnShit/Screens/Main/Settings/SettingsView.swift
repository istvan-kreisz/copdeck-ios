//
//  SettingsView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI
import Combine

struct SettingsView: View {
    enum IncludeOption: String, CaseIterable {
        case include = "Include"
        case dontInclude = "Don't include"

        static func from(_ include: Bool?) -> IncludeOption {
            include == true ? .include : .dontInclude
        }

        var asBool: Bool {
            self == .include
        }
    }

    @EnvironmentObject var store: DerivedGlobalStore
    @State private var settings: CopDeckSettings
    
    @State private var error: (String, String)? = nil

    // general
    @State private var currency: String
    @State private var stores: [String]
    @State private var country: String
    @State private var bestPricePriceType: String
    @State private var bestPriceFeeType: String
    @State private var preferredShoeSize: String

    // stockx
    @State private var stockxSellerFee: String
    @State private var stockxBuyersTaxes: String
    // goat
    @State private var goatCommissionFee: String
    @State private var goatCashOutFee: String
    @State private var goatBuyersTaxes: String
    // klekt
    @State private var klektBuyersTaxes: String

    @Binding private var isPresented: Bool

    init(settings: CopDeckSettings, isPresented: Binding<Bool>) {
        self._settings = State(initialValue: settings)

        // general
        self._currency = State(initialValue: settings.currency.symbol.rawValue)
        self._stores = State(initialValue: settings.displayedStores.compactMap { Store.store(withId: $0)?.name.rawValue })
        self._country = State(initialValue: settings.feeCalculation.country.name)
        self._bestPricePriceType = State(initialValue: settings.bestPricePriceType.rawValue.capitalized)
        self._bestPriceFeeType = State(initialValue: settings.bestPriceFeeType.rawValue.capitalized)
        self._preferredShoeSize = State(initialValue: settings.preferredShoeSize ?? "")

        // stockx
        self._stockxSellerFee = State(initialValue: (settings.feeCalculation.stockx?.sellerFee)?.rounded(toPlaces: 1) ?? "")
        self._stockxBuyersTaxes = State(initialValue: (settings.feeCalculation.stockx?.taxes)?.rounded(toPlaces: 1) ?? "")
        // goat
        self._goatCommissionFee = State(initialValue: (settings.feeCalculation.goat?.commissionPercentage ?? .low)?.rawValue.rounded(toPlaces: 1) ?? "")
        self._goatCashOutFee = State(initialValue: IncludeOption.from(settings.feeCalculation.goat?.cashOutFee).rawValue)
        self._goatBuyersTaxes = State(initialValue: (settings.feeCalculation.goat?.taxes)?.rounded(toPlaces: 1) ?? "")
        // klekt
        self._klektBuyersTaxes = State(initialValue: (settings.feeCalculation.klekt?.taxes)?.rounded(toPlaces: 1) ?? "")

        self._isPresented = isPresented
    }

    // general
    private func selectCurrency() {
        if let currency = Currency.currrency(withSymbol: currency), settings.currency != currency {
            settings.currency = currency
        }
    }

    private func selectStores() {
        settings.displayedStores = stores.compactMap { Store.store(withName: $0)?.id }
    }

    private func selectCountry() {
        if let country = Country.allCases.first(where: { $0.name == country }),
           settings.feeCalculation.country != country {
            settings.feeCalculation.country = country
        }
    }

    private func selectBestPricePriceType() {
        if let priceType = PriceType.allCases.first(where: { $0.rawValue == bestPricePriceType }),
           settings.bestPricePriceType != priceType {
            settings.bestPricePriceType = priceType
        }
    }

    private func selectBestPriceFeeType() {
        if let feeType = FeeType.allCases.first(where: { $0.rawValue == bestPriceFeeType }),
           settings.bestPriceFeeType != feeType {
            settings.bestPriceFeeType = feeType
        }
    }

    private func selectPreferredShoeSize() {
        if settings.preferredShoeSize != preferredShoeSize {
            settings.preferredShoeSize = preferredShoeSize
        }
    }

    // stockx
    private func selectStockxSellerFee() {
        if let newValue = Double(stockxSellerFee) {
            if newValue <= 100, newValue >= 0, settings.feeCalculation.stockx?.sellerFee != newValue {
                settings.feeCalculation.stockx?.sellerFee = newValue
            }
        } else {
            if settings.feeCalculation.stockx?.sellerFee != 0 {
                settings.feeCalculation.stockx?.sellerFee = 0
            }
        }
    }

    private func selectStockxBuyersTaxes() {
        if let newValue = Double(stockxBuyersTaxes) {
            if newValue <= 100, newValue >= 0, settings.feeCalculation.stockx?.taxes != newValue {
                settings.feeCalculation.stockx?.taxes = newValue
            }
        } else {
            if settings.feeCalculation.stockx?.taxes != 0 {
                settings.feeCalculation.stockx?.taxes = 0
            }
        }
    }

    // goat
    private func selectGoatCommissionFees() {
        if let fee = CopDeckSettings.FeeCalculation.Goat.CommissionPercentage.allCases
            .first(where: { goatCommissionFee.contains("\($0.rawValue.rounded(toPlaces: 0))") }),
            settings.feeCalculation.goat?.commissionPercentage != fee {
            settings.feeCalculation.goat?.commissionPercentage = fee
        }
    }

    private func selectGoatCashOutFee() {
        if let newValue = IncludeOption(rawValue: goatCashOutFee)?.asBool,
           settings.feeCalculation.goat?.cashOutFee != newValue {
            settings.feeCalculation.goat?.cashOutFee = newValue
        }
    }

    private func selectGoatBuyersTaxes() {
        if let newValue = Double(goatBuyersTaxes) {
            if newValue <= 100, newValue >= 0, settings.feeCalculation.goat?.taxes != newValue {
                settings.feeCalculation.goat?.taxes = newValue
            }
        } else {
            if settings.feeCalculation.goat?.taxes != 0 {
                settings.feeCalculation.goat?.taxes = 0
            }
        }
    }

    // klekt
    private func selectKlektBuyersTaxes() {
        if let newValue = Double(klektBuyersTaxes) {
            if newValue <= 100, newValue >= 0, settings.feeCalculation.klekt?.taxes != newValue {
                settings.feeCalculation.klekt?.taxes = newValue
            }
        } else {
            if settings.feeCalculation.klekt?.taxes != 0 {
                settings.feeCalculation.klekt?.taxes = 0
            }
        }
    }

    var body: some View {
        NavigationView {
            let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })
            VStack(spacing: 20) {
                Form {
                    HStack {
                        Text("Settings")
                            .foregroundColor(.customText1)
                            .font(.bold(size: 35))
                            .withDefaultPadding(padding: [.top])
                        Spacer()
                        Button(action: {
                            isPresented = false
                        }, label: {
                            Text("Done")
                                .font(.bold(size: 18))
                                .foregroundColor(.customBlue)
                        })
                            .buttonStyle(StaticButtonStyle())
                            .padding(.leading, -10)
                    }
                    .buttonStyle(StaticButtonStyle())

                    Section(header: Text("General")) {
                        ListSelectorMenu(title: "Currency",
                                         selectorScreenTitle: "Select currency",
                                         buttonTitle: "Select currency",
                                         options: ALLCURRENCIES.map { (currency: Currency) in currency.symbol.rawValue },
                                         selectedOption: $currency,
                                         buttonTapped: selectCurrency)

                        ListSelectorMenu(title: "Show prices on",
                                         selectorScreenTitle: "Select sites",
                                         buttonTitle: "Select sites",
                                         options: ALLSTORES.map { (store: Store) in store.name.rawValue },
                                         selectedOptions: $stores,
                                         buttonTapped: selectStores)

                        ListSelectorMenu(title: "Country",
                                         selectorScreenTitle: "Select your country",
                                         buttonTitle: "Select country",
                                         options: Country.allCases.map { (country: Country) in country.name }.sorted(),
                                         selectedOption: $country,
                                         buttonTapped: selectCountry)

                        ListSelectorMenu(title: "Best price type",
                                         selectorScreenTitle: "Best price type",
                                         buttonTitle: "Select option",
                                         options: PriceType.allCases.map { (priceType: PriceType) in priceType.rawValue.capitalized },
                                         selectedOption: $bestPricePriceType,
                                         buttonTapped: selectBestPricePriceType)

                        ListSelectorMenu(title: "Best price fees",
                                         selectorScreenTitle: "Best price fees",
                                         buttonTitle: "Select option",
                                         options: FeeType.allCases.map { (feeType: FeeType) in feeType.rawValue.capitalized },
                                         selectedOption: $bestPriceFeeType,
                                         buttonTapped: selectBestPriceFeeType)

                        ListSelectorMenu(title: "Preferred shoe size",
                                         selectorScreenTitle: "Preferred shoe size",
                                         buttonTitle: "Select size",
                                         options: ALLSHOESIZES.reversed(),
                                         selectedOption: $preferredShoeSize,
                                         buttonTapped: selectPreferredShoeSize)
                    }

                    Section(header: Text("StockX")) {
                        HStack {
                            Text("StockX seller fee (%)")
                                .layoutPriority(2)
                            TextField("0%", text: $stockxSellerFee, onEditingChanged: { isActive in
                                if !isActive {
                                    selectStockxSellerFee()
                                }
                            })
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }

                        HStack {
                            Text("StockX buyer's taxes (%)")
                                .layoutPriority(2)
                            TextField("0%", text: $stockxBuyersTaxes, onEditingChanged: { isActive in
                                if !isActive {
                                    selectStockxBuyersTaxes()
                                }
                            })
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }

                    Section(header: Text("GOAT")) {
                        ListSelectorMenu(title: "Commission fee (%)",
                                         selectorScreenTitle: "Commission fee (%)",
                                         buttonTitle: "Select fee",
                                         options: CopDeckSettings.FeeCalculation.Goat.CommissionPercentage.allCases
                                             .map { (commissionFee: CopDeckSettings.FeeCalculation.Goat.CommissionPercentage) in
                                                 commissionFee.rawValue.rounded(toPlaces: 1)
                                             },
                                         selectedOption: $goatCommissionFee,
                                         buttonTapped: selectGoatCommissionFees)

                        ListSelectorMenu(title: "Cashout fee (%)",
                                         selectorScreenTitle: "Cashout fee (%)",
                                         buttonTitle: "Select option",
                                         options: IncludeOption.allCases.map(\.rawValue),
                                         selectedOption: $goatCashOutFee,
                                         buttonTapped: selectGoatCashOutFee)

                        HStack {
                            Text("GOAT buyer's taxes (%)")
                                .layoutPriority(2)
                            TextField("0%", text: $goatBuyersTaxes, onEditingChanged: { isActive in
                                if !isActive {
                                    selectGoatBuyersTaxes()
                                }
                            })
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }

                    Section(header: Text("Klekt")) {
                        HStack {
                            Text("Klekt buyer's taxes (%)")
                                .layoutPriority(2)
                            TextField("0%", text: $klektBuyersTaxes, onEditingChanged: { isActive in
                                if !isActive {
                                    selectKlektBuyersTaxes()
                                }
                            })
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }

                    #warning("enable")
                    if DebugSettings.shared.isAdmin {
                        Section(header: Text("Membership")) {
                            NavigationLink(destination: PromoCodeView()) {
                                Text("Apply referral code")
                                    .leftAligned()
                            }
                        }
                    }

                    Section(header: Text("Spreadsheet import")) {
                        NavigationLink(destination: SpreadsheetImportView()) {
                            Text("Import your inventory")
                                .leftAligned()
                        }
                    }

                    if DebugSettings.shared.isAdmin {
                        Section(header: Text("ADMIN")) {
                            if DebugSettings.shared.isSuperAdmin {
                                NavigationLink(destination: SpreadsheetImportAdminView()) {
                                    Text("Spreadsheet import requests")
                                        .leftAligned()
                                }
                            }
                            NavigationLink(destination: AffiliateLinksView()) {
                                Text("Affilate links")
                                    .leftAligned()
                            }
                        }
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
                .hideKeyboardOnScroll()
                .navigationbarHidden()
                .onChange(of: settings) { value in
                    store.send(.main(action: .updateSettings(settings: value)))
                }
                .onChange(of: store.globalState.error) { error in
                    if let title = error?.title, let message = error?.message {
                        self.error = (title, message)
                    }
                }
                .alert(isPresented: presentErrorAlert) {
                    Alert(title: Text(error?.0 ?? "Ooops"), message: Text(error?.1 ?? "Unknown Error"), dismissButton: .default(Text("OK")))
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
