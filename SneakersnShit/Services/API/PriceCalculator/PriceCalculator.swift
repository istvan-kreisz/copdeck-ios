//
//  PriceCalculator.swift
//  CopDeck
//
//  Created by István Kreisz on 12/13/21.
//

import Foundation

fileprivate struct ShippingFee {
    let fee: Double
    let currency: Currency
}

func stockxSellerPrice(price: Double,
                       currencyCode: Currency.CurrencyCode,
                       feeCalculation: CopDeckSettings.FeeCalculation,
                       exchangeRates: ExchangeRates?) -> Double {
    let transactionFeePercentage = feeCalculation.stockx?.sellerFee ?? 0
    // min transaction fee
    let fees: [Currency.CurrencyCode: Double] = [.usd: 9, .eur: 7, .gbp: 7]
    let minTransactionFee = fees[currencyCode] ?? 0

    let transactionFee = max((price * transactionFeePercentage) / 100, minTransactionFee)
    let paymentProcessingFee = price * 0.03

    var shippingFee: ShippingFee = .init(fee: 30, currency: USD)
    switch feeCalculation.country.name {
    case "Austria",
         "Belgium",
         "France",
         "Italy",
         "Poland",
         "Germany",
         "Netherlands",
         "UK",
         "South Korea":
        shippingFee = .init(fee: 0, currency: EUR)
    case "Luxembourg",
         "Croatia",
         "Denmark",
         "Latvia",
         "Portugal",
         "Romania",
         "Slovakia",
         "Slovenia",
         "Spain",
         "Lithuania",
         "Estonia",
         "Czech Republic":
        shippingFee = .init(fee: 5, currency: EUR)
    case "Bulgaria",
         "Hungary",
         "Ireland",
         "Sweden":
        shippingFee = .init(fee: 10, currency: EUR)
    case "Finland",
         "Greece",
         "Republic of Cyprus":
        shippingFee = .init(fee: 15, currency: EUR)
    case "US (Alaska, Hawaii)",
         "US (mainland)":
        shippingFee = .init(fee: 0, currency: USD)
    case "Malaysia",
         "Taiwan":
        shippingFee = .init(fee: 5, currency: USD)
    case "China",
         "Indonesia",
         "Thailand",
         "Philippines":
        shippingFee = .init(fee: 10, currency: USD)
    case "Singapore":
        shippingFee = .init(fee: 14, currency: USD)
    case "Vietnam":
        shippingFee = .init(fee: 20, currency: USD)
    case "Iceland",
         "Norway",
         "Malta":
        shippingFee = .init(fee: 25, currency: USD)
    case "Switzerland":
        shippingFee = .init(fee: 20, currency: CHF)
    default:
        break
    }
    if currencyCode == .gbp {
        shippingFee = .init(fee: 0, currency: GBP)
    }
    let shippingFeeConverted = Currency.convert(from: shippingFee.currency.code, to: currencyCode, exchangeRates: exchangeRates) * shippingFee.fee
    return round(price - transactionFee - paymentProcessingFee - shippingFeeConverted)
}

func stockxBuyerPrice(price: Double,
                      currencyCode: Currency.CurrencyCode,
                      feeCalculation: CopDeckSettings.FeeCalculation,
                      exchangeRates: ExchangeRates?) -> Double {
    var paymentProcessingFee = price * 0.03
    let paymentProcessingFeeInUSD = Currency.convert(from: currencyCode, to: .usd, exchangeRates: exchangeRates) * paymentProcessingFee
    if paymentProcessingFeeInUSD < 3.0 {
        paymentProcessingFee = Currency.convert(from: .usd, to: currencyCode, exchangeRates: exchangeRates) * 3.0
    } else if paymentProcessingFeeInUSD > 59.95 {
        paymentProcessingFee = Currency.convert(from: .usd, to: currencyCode, exchangeRates: exchangeRates) * 59.95
    }
    var shippingFee: ShippingFee = .init(fee: 30, currency: USD)
    switch feeCalculation.country.name {
    case "Austria",
         "Belgium",
         "Bulgaria",
         "Czech Republic",
         "Denmark",
         "Estonia",
         "Finland",
         "France",
         "Germany",
         "Greece",
         "Hungary",
         "Ireland",
         "Italy",
         "Lithuania",
         "Luxembourg",
         "Netherlands",
         "Poland",
         "Portugal",
         "Romania",
         "Slovakia",
         "Slovenia",
         "Spain",
         "Sweden":
        shippingFee = .init(fee: 15, currency: EUR)
    case "Croatia",
         "Iceland",
         "Liechtenstein",
         "Malta",
         "Republic of Cyprus":
        shippingFee = .init(fee: 25, currency: EUR)
    case "Switzerland":
        shippingFee = .init(fee: 20, currency: CHF)
    case "UK":
        shippingFee = .init(fee: 13.5, currency: GBP)
    case "US (Alaska, Hawaii)":
        shippingFee = .init(fee: 25, currency: USD)
    case "US (mainland)":
        shippingFee = .init(fee: 13.95, currency: USD)
    case "China",
         "Singapore",
         "South Korea",
         "Taiwan":
        shippingFee = .init(fee: 18, currency: USD)
    case "Latvia",
         "Norway":
        shippingFee = .init(fee: 30, currency: EUR)
    default:
        break
    }
    let shippingFeeConverted = Currency.convert(from: shippingFee.currency.code, to: currencyCode, exchangeRates: exchangeRates) * shippingFee.fee
    let totalWithoutTaxes = price + paymentProcessingFee + shippingFeeConverted
    let total = totalWithoutTaxes * (1 + (feeCalculation.stockx?.taxes ?? 0) / 100)
    return round(total)
}

func klektSellerPrice(price: Double) -> Double {
    round(price / 1.17)
}

func klektBuyerPrice(price: Double,
                     currencyCode: Currency.CurrencyCode,
                     feeCalculation: CopDeckSettings.FeeCalculation) -> Double {
    struct FeeGroup {
        let eur: Double
        let gbp: Double
        let usd: Double
    }

    let group1 = FeeGroup(eur: 18, gbp: 15, usd: 20)
    let group2 = FeeGroup(eur: 12, gbp: 11, usd: 14)
    let group3 = FeeGroup(eur: 7, gbp: 6, usd: 8)
    let group4 = FeeGroup(eur: 11, gbp: 10, usd: 13)
    let group5 = FeeGroup(eur: 20, gbp: 17, usd: 23)
    let group6 = FeeGroup(eur: 28, gbp: 24, usd: 32)
    let group7 = FeeGroup(eur: 25, gbp: 22, usd: 29)
    let group8 = FeeGroup(eur: 20, gbp: 17, usd: 23)
    let group9 = FeeGroup(eur: 35, gbp: 30, usd: 40)
    let group10 = FeeGroup(eur: 13, gbp: 11, usd: 15)
    let shippingFees: [(String, FeeGroup)] = [("Austria", group1),
                                              ("Belgium", group1),
                                              ("Bulgaria", group1),
                                              ("Croatia", group8),
                                              ("Republic of Cyprus", group1),
                                              ("Czech Republic", group1),
                                              ("Denmark", group1),
                                              ("Estonia", group1),
                                              ("Finland", group1),
                                              ("France", group2),
                                              ("Germany", group2),
                                              ("Greece", group8),
                                              ("Hungary", group1),
                                              ("Iceland", group1),
                                              ("Ireland", group1),
                                              ("Italy", group10),
                                              ("Latvia", group1),
                                              ("Liechtenstein", group1),
                                              ("Lithuania", group1),
                                              ("Luxembourg", group1),
                                              ("Malta", group9),
                                              ("Netherlands", group3),
                                              ("Norway", group1),
                                              ("Poland", group1),
                                              ("Portugal", group1),
                                              ("Romania", group1),
                                              ("Slovakia", group1),
                                              ("Slovenia", group1),
                                              ("Spain", group1),
                                              ("Sweden", group1),
                                              ("Switzerland", group1),
                                              ("UK", group4),
                                              ("US (mainland)", group5),
                                              ("US (Alaska, Hawaii)", group5),
                                              ("Indonesia", group6),
                                              ("Malaysia", group6),
                                              ("Philippines", group6),
                                              ("Singapore", group6),
                                              ("Thailand", group6),
                                              ("China", group6),
                                              ("South Korea", group6),
                                              ("Taiwan", group7),
                                              ("Vietnam", group6)]
    var fee = 0.0
    if let shippingFee = shippingFees.first(where: { $0.0 == feeCalculation.country.name }) {
        switch currencyCode {
        case .eur:
            fee = shippingFee.1.eur
        case .gbp:
            fee = shippingFee.1.gbp
        case .usd:
            fee = shippingFee.1.usd
        default:
            break
        }
    }
    let totalWithoutTaxes = price + fee
    let total = totalWithoutTaxes * (1 + (feeCalculation.klekt?.taxes ?? 0) / 100)
    return round(total)
}

func goatSellerPrice(price: Double,
                     currencyCode: Currency.CurrencyCode,
                     feeCalculation: CopDeckSettings.FeeCalculation,
                     exchangeRates: ExchangeRates?) -> Double {
    struct FeeGroup {
        let countries: [String]
        let fee: Double
    }

    var sellerFee = 30.0
    let groups: [FeeGroup] =
        [.init(countries: ["US (mainland)", "US (Alaska, Hawaii)", "Germany", "UK"], fee: 5),
         .init(countries: ["Austria", "Belgium", "France",
                           "Netherlands"],
               fee: 6),
         .init(countries: ["Bulgaria",
                           "Croatia",
                           "Republic of Cyprus",
                           "Czech Republic",
                           "Estonia",
                           "Greece",
                           "Hungary",
                           "Latvia",
                           "Lithuania",
                           "Malta",
                           "Romania",
                           "Slovakia",
                           "Slovenia"],
               fee: 24),
         .init(countries: ["China"], fee: 25),
         .init(countries: ["Denmark", "Ireland", "Italy", "Luxembourg",
                           "Poland", "Portugal", "Spain"],
               fee: 12),
         .init(countries: ["Finland", "Malaysia", "Philippines",
                           "Singapore"],
               fee: 20),
         .init(countries: ["Sweden"], fee: 10)]
    sellerFee = groups
        .first(where: { group in group.countries.contains(feeCalculation.country.name) })?
        .fee ?? sellerFee

    switch feeCalculation.country.name {
    case "UK",
         "US (mainland)",
         "US (Alaska, Hawaii)",
         "Germany":
        sellerFee = 5
    case "Austria",
         "Belgium":
        sellerFee = 6
    case "Sweden",
         "Netherlands":
        sellerFee = 10
    case "Ireland",
         "Luxembourg",
         "France":
        sellerFee = 12
    case "Italy",
         "Finland",
         "Portugal",
         "Spain",
         "Denmark",
         "Malaysia",
         "Philippines",
         "Singapore":
        sellerFee = 20
    case "Bulgaria":
        sellerFee = 24
    case "China":
        sellerFee = 25
    default:
        break
    }
    sellerFee = Currency
        .convert(from: .usd, to: currencyCode, exchangeRates: exchangeRates) * sellerFee
    let commissionFee =
        (price * (feeCalculation.goat?.commissionPercentage.rawValue ?? 0.0)) / 100
    let totalSellingFee = sellerFee + commissionFee
    let sellerPrice = price - totalSellingFee
    let cashoutFee = sellerPrice * (feeCalculation.goat?.cashOutFeeAmount ?? 0.0)
    let totalCashoutValue = sellerPrice - cashoutFee

    return round(totalCashoutValue)
}

func goatBuyerPrice(price: Double,
                    currencyCode: Currency.CurrencyCode,
                    feeCalculation: CopDeckSettings.FeeCalculation,
                    exchangeRates: ExchangeRates?) -> Double {
    var shippingFee: ShippingFee = .init(fee: 40, currency: USD)
    if feeCalculation.country.name == "US (mainland)" {
        shippingFee = .init(fee: 12, currency: USD)
    } else if feeCalculation.country.name == "US (Alaska, Hawaii)" {
        shippingFee = .init(fee: 15, currency: USD)
    } else if feeCalculation.country.name == "UK" {
        shippingFee = .init(fee: 13, currency: GBP)
    } else if feeCalculation.country.name == "China" {
        shippingFee = .init(fee: 25, currency: USD)
    }
    let shippingFeeConverted = Currency.convert(from: shippingFee.currency.code,
                                                to: currencyCode,
                                                exchangeRates: exchangeRates) * shippingFee
        .fee
    let priceWithShippingFee = price + shippingFeeConverted
    let vat = (priceWithShippingFee * (feeCalculation.goat?.taxes ?? 0)) / 100

    return round(priceWithShippingFee + vat)
}

func restocksSellerPrice(price: Double,
                         currencyCode: Currency.CurrencyCode,
                         feeCalculation: CopDeckSettings.FeeCalculation,
                         exchangeRates: ExchangeRates?,
                         restocksPriceType: Item.StorePrice.StoreInventoryItem.RestocksPriceType) -> Double {
    let multiplier = restocksPriceType == .regular ? 0.1 : 0.05
    let sellerFeeInEUR = Currency.convert(from: currencyCode, to: .eur, exchangeRates: exchangeRates) * price * multiplier + 10
    let sellerFeeInTargetCurrency = Currency.convert(from: .eur, to: currencyCode, exchangeRates: exchangeRates) * sellerFeeInEUR
    return round(price - sellerFeeInTargetCurrency)
}

func restocksBuyerPrice(price: Double,
                        currencyCode: Currency.CurrencyCode,
                        feeCalculation: CopDeckSettings.FeeCalculation,
                        exchangeRates: ExchangeRates?) -> Double? {
    let fees: [Double] = [15, 10, 10]
    var fee: Double = fees[0]
    switch currencyCode {
    case .usd:
        fee = fees[0]
    case .eur:
        fee = fees[1]
    case .gbp:
        fee = fees[2]
    default:
        fee = fees[0]
    }
    let notSupportedCountries: [String] = ["Iceland",
                                           "Indonesia",
                                           "Malaysia",
                                           "Philippines",
                                           "South Korea",
                                           "Taiwan",
                                           "Thailand",
                                           "Vietnam"]
    let isNotSupportedCountry = notSupportedCountries
        .contains(where: { feeCalculation.country.name == $0 })
    return isNotSupportedCountry ? nil : price + fee
}

func calculatePrice(storeId: StoreId,
                    currencyCode: Currency.CurrencyCode,
                    inventoryItem: Item.StorePrice.StoreInventoryItem,
                    feeCalculation: CopDeckSettings.FeeCalculation,
                    exchangeRates: ExchangeRates?) -> Item.StorePrice.StoreInventoryItem {
    var updatedInventoryItem = inventoryItem
    switch storeId {
    case .stockx:
        if let lowestAsk = inventoryItem.lowestAsk {
            updatedInventoryItem.lowestAskWithSellerFees = stockxSellerPrice(price: lowestAsk,
                                                                             currencyCode: currencyCode,
                                                                             feeCalculation: feeCalculation,
                                                                             exchangeRates: exchangeRates)
            updatedInventoryItem.lowestAskWithBuyerFees = stockxBuyerPrice(price: lowestAsk,
                                                                           currencyCode: currencyCode,
                                                                           feeCalculation: feeCalculation,
                                                                           exchangeRates: exchangeRates)
        }
        if let highestBid = inventoryItem.highestBid {
            updatedInventoryItem.highestBidWithSellerFees = stockxSellerPrice(price: highestBid,
                                                                              currencyCode: currencyCode,
                                                                              feeCalculation: feeCalculation,
                                                                              exchangeRates: exchangeRates)
            updatedInventoryItem.highestBidWithBuyerFees = stockxBuyerPrice(price: highestBid,
                                                                            currencyCode: currencyCode,
                                                                            feeCalculation: feeCalculation,
                                                                            exchangeRates: exchangeRates)
        }
    case .klekt:
        if let lowestAsk = inventoryItem.lowestAsk {
            updatedInventoryItem.lowestAskWithSellerFees = klektSellerPrice(price: lowestAsk)
            updatedInventoryItem.lowestAskWithBuyerFees = klektBuyerPrice(price: lowestAsk,
                                                                          currencyCode: currencyCode,
                                                                          feeCalculation: feeCalculation)
        }
        if let highestBid = inventoryItem.highestBid {
            updatedInventoryItem.highestBidWithSellerFees = klektSellerPrice(price: highestBid)
            updatedInventoryItem.highestBidWithBuyerFees = klektBuyerPrice(price: highestBid,
                                                                           currencyCode: currencyCode,
                                                                           feeCalculation: feeCalculation)
        }
    case .goat:
        if let lowestAsk = inventoryItem.lowestAsk {
            updatedInventoryItem.lowestAskWithSellerFees = goatSellerPrice(price: lowestAsk,
                                                                           currencyCode: currencyCode,
                                                                           feeCalculation: feeCalculation,
                                                                           exchangeRates: exchangeRates)
            updatedInventoryItem.lowestAskWithBuyerFees = goatBuyerPrice(price: lowestAsk,
                                                                         currencyCode: currencyCode,
                                                                         feeCalculation: feeCalculation,
                                                                         exchangeRates: exchangeRates)
        }
        if let highestBid = inventoryItem.highestBid {
            updatedInventoryItem.highestBidWithSellerFees = goatSellerPrice(price: highestBid,
                                                                            currencyCode: currencyCode,
                                                                            feeCalculation: feeCalculation,
                                                                            exchangeRates: exchangeRates)
            updatedInventoryItem.highestBidWithBuyerFees = goatBuyerPrice(price: highestBid,
                                                                          currencyCode: currencyCode,
                                                                          feeCalculation: feeCalculation,
                                                                          exchangeRates: exchangeRates)
        }
    case .restocks:
        if let lowestAsk = inventoryItem.lowestAsk {
            updatedInventoryItem.lowestAskWithSellerFees = restocksSellerPrice(price: lowestAsk,
                                                                               currencyCode: currencyCode,
                                                                               feeCalculation: feeCalculation,
                                                                               exchangeRates: exchangeRates,
                                                                               restocksPriceType: inventoryItem.restocksPriceType ?? .regular)
            updatedInventoryItem.lowestAskWithBuyerFees = restocksBuyerPrice(price: lowestAsk,
                                                                             currencyCode: currencyCode,
                                                                             feeCalculation: feeCalculation,
                                                                             exchangeRates: exchangeRates)
        }
    }
    return updatedInventoryItem
}

func withCalculatedPrices(inventoryItem: InventoryItem) -> InventoryItem {
    var updatedInventoryItem = inventoryItem
    guard var updatedInventoryItemItemFields = inventoryItem.itemFields else { return inventoryItem }
    updatedInventoryItemItemFields.storePrices = updatedInventoryItemItemFields.storePrices.map { prices -> Item.StorePrice in
        var calculatedPrices = prices
        calculatedPrices.inventory = calculatedPrices.inventory.map { storeInventoryItem in
            calculatePrice(storeId: calculatedPrices.store.id,
                           currencyCode: AppStore.default.state.currency.code,
                           inventoryItem: storeInventoryItem,
                           feeCalculation: AppStore.default.state.settings.feeCalculation,
                           exchangeRates: AppStore.default.state.exchangeRates)
        }
        return calculatedPrices
    }
    updatedInventoryItem.itemFields = updatedInventoryItemItemFields
    return updatedInventoryItem
}

func withCalculatedPrices(item: Item) -> Item {
    var updatedItem = item
    updatedItem.storePrices = item.storePrices.map { prices -> Item.StorePrice in
        var calculatedPrices = prices
        calculatedPrices.inventory = calculatedPrices.inventory.map { storeInventoryItem in
            calculatePrice(storeId: calculatedPrices.store.id,
                           currencyCode: AppStore.default.state.currency.code,
                           inventoryItem: storeInventoryItem,
                           feeCalculation: AppStore.default.state.settings.feeCalculation,
                           exchangeRates: AppStore.default.state.exchangeRates)
        }
        return calculatedPrices
    }
    return updatedItem
}
