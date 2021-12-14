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
        shippingFee = .init(fee: 30, currency: EUR)
    case "Luxembourg":
        shippingFee = .init(fee: 5, currency: EUR)
    case "Bulgaria",
         "Czech Republic",
         "Croatia",
         "Denmark",
         "Hungary",
         "Ireland",
         "Latvia",
         "Portugal",
         "Romania",
         "Slovakia",
         "Slovenia",
         "Spain",
         "Sweden":
        shippingFee = .init(fee: 10, currency: EUR)
    case "Estonia",
         "Finland",
         "Greece",
         "Liechtenstein",
         "Lithuania",
         "Republic of Cyprus":
        shippingFee = .init(fee: 15, currency: EUR)
    case "US (Alaska, Hawaii)",
         "US (mainland)":
        shippingFee = .init(fee: 0, currency: USD)
    case "Malaysia",
         "China",
         "Philippines",
         "Singapore",
         "Taiwan":
        shippingFee = .init(fee: 10, currency: USD)
    case "Indonesia",
         "Thailand",
         "Vietnam":
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

//
// const stockxBuyerPrice = (
//    price: Double,
//    currencyCode: CurrencyCode,
//    sellerInfo: SellerInfo,
//    exchangeRates?: ExchangeRates
// ): Double => {
//    let paymentProcessingFee = price * 0.03
//    const paymentProcessingFeeInUSD = convert(
//        paymentProcessingFee,
//        currencyCode,
//        "USD",
//        false,
//        exchangeRates
//    )
//    if (paymentProcessingFeeInUSD < 3) {
//        paymentProcessingFee = convert(3, "USD", currencyCode, false, exchangeRates)
//    } else if (paymentProcessingFeeInUSD > 59.95) {
//        paymentProcessingFee = convert(59.95, "USD", currencyCode, false, exchangeRates)
//    }
//    let shippingFee: { fee: Double; currency: CurrencyInternal } = { fee: 30, currency: USD }
//    switch (sellerInfo.countryName) {
//        case "Austria":
//        case "Belgium":
//        case "Bulgaria":
//        case "Czech Republic":
//        case "Denmark":
//        case "Estonia":
//        case "Finland":
//        case "France":
//        case "Germany":
//        case "Greece":
//        case "Hungary":
//        case "Ireland":
//        case "Italy":
//        case "Lithuania":
//        case "Luxembourg":
//        case "Netherlands":
//        case "Poland":
//        case "Portugal":
//        case "Romania":
//        case "Slovakia":
//        case "Slovenia":
//        case "Spain":
//        case "Sweden":
//            shippingFee = { fee: 15, currency: EUR }
//            break
//        case "Croatia":
//        case "Iceland":
//        case "Liechtenstein":
//        case "Malta":
//        case "Republic of Cyprus":
//            shippingFee = { fee: 25, currency: EUR }
//            break
//        case "Switzerland":
//            shippingFee = { fee: 20, currency: CHF }
//            break
//        case "UK":
//            shippingFee = { fee: 13.5, currency: GBP }
//            break
//        case "US (Alaska, Hawaii)":
//            shippingFee = { fee: 25, currency: USD }
//            break
//        case "US (mainland)":
//            shippingFee = { fee: 13.95, currency: USD }
//            break
//        case "China":
//        case "Singapore":
//        case "South Korea":
//        case "Taiwan":
//            shippingFee = { fee: 18, currency: USD }
//            break
//        case "Latvia":
//        case "Norway":
//            shippingFee = { fee: 30, currency: EUR }
//            break
//    }
//    const totalWithoutTaxes =
//        price +
//        paymentProcessingFee +
//        convert(shippingFee.fee, shippingFee.currency.code, currencyCode, false, exchangeRates)
//    const total = totalWithoutTaxes * (1 + sellerInfo.stockx.taxes / 100)
//    return Math.round(total)
// }
//
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
                         exchangeRates: ExchangeRates?) -> Double {
    let sellerFeeInEUR = Currency.convert(from: currencyCode, to: .eur,
                                          exchangeRates: exchangeRates) * 0.1 + 10
    let sellerFeeInTargetCurrency = Currency.convert(from: .eur, to: currencyCode,
                                                     exchangeRates: exchangeRates) *
        sellerFeeInEUR
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

//
// const calculatePrice = (
//    storeId: StoreId,
//    currencyCode: CurrencyCode,
//    inventoryItem: StoreInventoryItem,
//    sellerInfo: SellerInfo,
//    exchangeRates?: ExchangeRates
// ): StoreInventoryItem => {
//    switch (storeId) {
//        case "stockx":
//            if (inventoryItem.lowestAsk) {
//                inventoryItem.lowestAskWithSellerFees = stockxSellerPrice(
//                    inventoryItem.lowestAsk,
//                    currencyCode,
//                    sellerInfo,
//                    exchangeRates
//                )
//                inventoryItem.lowestAskWithBuyerFees = stockxBuyerPrice(
//                    inventoryItem.lowestAsk,
//                    currencyCode,
//                    sellerInfo,
//                    exchangeRates
//                )
//            }
//            if (inventoryItem.highestBid) {
//                inventoryItem.highestBidWithSellerFees = stockxSellerPrice(
//                    inventoryItem.highestBid,
//                    currencyCode,
//                    sellerInfo,
//                    exchangeRates
//                )
//                inventoryItem.highestBidWithBuyerFees = stockxBuyerPrice(
//                    inventoryItem.highestBid,
//                    currencyCode,
//                    sellerInfo,
//                    exchangeRates
//                )
//            }
//            break
//        case "klekt":
//            if (inventoryItem.lowestAsk) {
//                inventoryItem.lowestAskWithSellerFees = klektSellerPrice(inventoryItem.lowestAsk)
//                inventoryItem.lowestAskWithBuyerFees = klektBuyerPrice(
//                    inventoryItem.lowestAsk,
//                    currencyCode,
//                    sellerInfo
//                )
//            }
//            if (inventoryItem.highestBid) {
//                inventoryItem.highestBidWithSellerFees = klektSellerPrice(inventoryItem.highestBid)
//                inventoryItem.highestBidWithBuyerFees = klektBuyerPrice(
//                    inventoryItem.highestBid,
//                    currencyCode,
//                    sellerInfo
//                )
//            }
//            break
//        case "goat":
//            if (inventoryItem.lowestAsk) {
//                inventoryItem.lowestAskWithSellerFees = goatSellerPrice(
//                    inventoryItem.lowestAsk,
//                    currencyCode,
//                    sellerInfo,
//                    exchangeRates
//                )
//                inventoryItem.lowestAskWithBuyerFees = goatBuyerPrice(
//                    inventoryItem.lowestAsk,
//                    currencyCode,
//                    sellerInfo,
//                    exchangeRates
//                )
//            }
//            if (inventoryItem.highestBid) {
//                inventoryItem.highestBidWithSellerFees = goatSellerPrice(
//                    inventoryItem.highestBid,
//                    currencyCode,
//                    sellerInfo,
//                    exchangeRates
//                )
//                inventoryItem.highestBidWithBuyerFees = goatBuyerPrice(
//                    inventoryItem.highestBid,
//                    currencyCode,
//                    sellerInfo,
//                    exchangeRates
//                )
//            }
//            break
//        case "restocks":
//            if (inventoryItem.lowestAsk) {
//                inventoryItem.lowestAskWithSellerFees = restocksSellerPrice(
//                    inventoryItem.lowestAsk,
//                    currencyCode,
//                    sellerInfo,
//                    exchangeRates
//                )
//                inventoryItem.lowestAskWithBuyerFees = restocksBuyerPrice(
//                    inventoryItem.lowestAsk,
//                    currencyCode,
//                    sellerInfo,
//                    exchangeRates
//                )
//            }
//            // if (inventoryItem.highestBid) {
//            //     inventoryItem.highestBidWithSellerFees = restocksSellerPrice(
//            //         inventoryItem.highestBid,
//            //         currencyCode,
//            //         sellerInfo,
//            //         exchangeRates
//            //     )
//            //     inventoryItem.highestBidWithBuyerFees = restocksBuyerPrice(
//            //         inventoryItem.highestBid,
//            //         currencyCode,
//            //         sellerInfo,
//            //         exchangeRates
//            //     )
//            // }
//            break
//    }
//    return inventoryItem
// }
//
// const calculatePrices = (
//    item: Item,
//    apiConfig: APIConfig,
//    requestId: string
// ): RequestResult<Item> => {
//    item.storePrices = item.storePrices.map((prices) => {
//        const calculatedPrices = prices
//        calculatedPrices.inventory = calculatedPrices.inventory.map((inventoryItem) =>
//            apiConfig.feeCalculation
//                ? calculatePrice(
//                        calculatedPrices.store.id,
//                        apiConfig.currency.code,
//                        inventoryItem,
//                        apiConfig.feeCalculation,
//                        apiConfig.exchangeRates
//                  )
//                : inventoryItem
//        )
//        return calculatedPrices
//    })
//    return wrapResult(item, requestId)
// }
//
// export { calculatePrices }
//
