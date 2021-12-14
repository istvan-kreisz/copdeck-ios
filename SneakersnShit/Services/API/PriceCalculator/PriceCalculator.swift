//
//  PriceCalculator.swift
//  CopDeck
//
//  Created by István Kreisz on 12/13/21.
//

import Foundation

func stockxSellerPrice(price: Double,
                       currencyCode: Currency.CurrencyCode,
                       feeCalculation: CopDeckSettings.FeeCalculation,
                       exchangeRates: ExchangeRates?) -> Double {
    struct ShippingFee {
        let fee: Double
        let currency: Currency
    }
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
//    price: number,
//    currencyCode: CurrencyCode,
//    sellerInfo: SellerInfo,
//    exchangeRates?: ExchangeRates
// ): number => {
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
//    let shippingFee: { fee: number; currency: CurrencyInternal } = { fee: 30, currency: USD }
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

//
// const klektBuyerPrice = (
//    price: number,
//    currencyCode: CurrencyCode,
//    sellerInfo: SellerInfo
// ): number => {
//    const group1: [number, number, number] = [18, 15, 20]
//    const group2: [number, number, number] = [12, 11, 14]
//    const group3: [number, number, number] = [7, 6, 8]
//    const group4: [number, number, number] = [11, 10, 13]
//    const group5: [number, number, number] = [20, 17, 23]
//    const group6: [number, number, number] = [28, 24, 32]
//    const group7: [number, number, number] = [25, 22, 29]
//    const group8: [number, number, number] = [20, 17, 23]
//    const group9: [number, number, number] = [35, 30, 40]
//    const group10: [number, number, number] = [13, 11, 15]
//    const shippingFees: [CountryName, number, number, number][] = [
//        ["Austria", ...group1], //
//        ["Belgium", ...group1], //
//        ["Bulgaria", ...group1], //
//        ["Croatia", ...group8], //
//        ["Republic of Cyprus", ...group1], //
//        ["Czech Republic", ...group1], //
//        ["Denmark", ...group1], //
//        ["Estonia", ...group1], //
//        ["Finland", ...group1], //
//        ["France", ...group2], //
//        ["Germany", ...group2], //
//        ["Greece", ...group8], //
//        ["Hungary", ...group1], //
//        ["Iceland", ...group1], //
//        ["Ireland", ...group1], //
//        ["Italy", ...group10], //
//        ["Latvia", ...group1], //
//        ["Liechtenstein", ...group1], //
//        ["Lithuania", ...group1], //
//        ["Luxembourg", ...group1], //
//        ["Malta", ...group9], //
//        ["Netherlands", ...group3], //
//        ["Norway", ...group1], //
//        ["Poland", ...group1], //
//        ["Portugal", ...group1], //
//        ["Romania", ...group1], //
//        ["Slovakia", ...group1], //
//        ["Slovenia", ...group1], //
//        ["Spain", ...group1], //
//        ["Sweden", ...group1], //
//        ["Switzerland", ...group1], //
//        ["UK", ...group4], //
//        ["US (mainland)", ...group5], //
//        ["US (Alaska, Hawaii)", ...group5], //
//        ["Indonesia", ...group6], //
//        ["Malaysia", ...group6], //
//        ["Philippines", ...group6], //
//        ["Singapore", ...group6], //
//        ["Thailand", ...group6], //
//        ["China", ...group6], //
//        ["South Korea", ...group6], //
//        ["Taiwan", ...group7],
//        ["Vietnam", ...group6], //
//    ]
//    const shippingFee = shippingFees.find((fees) => fees[0] === sellerInfo.countryName)
//    let fee = 0
//    if (shippingFee) {
//        switch (currencyCode) {
//            case "EUR":
//                fee = shippingFee[1]
//                break
//            case "GBP":
//                fee = shippingFee[2]
//                break
//            case "USD":
//                fee = shippingFee[3]
//                break
//            default:
//                break
//        }
//    }
//    const totalWithoutTaxes = price + fee
//    const total = totalWithoutTaxes * (1 + sellerInfo.klekt.taxes / 100)
//    return Math.round(total)
// }
//
// const goatSellerPrice = (
//    price: number,
//    currencyCode: CurrencyCode,
//    sellerInfo: SellerInfo,
//    exchangeRates?: ExchangeRates
// ): number => {
//    let sellerFee = 30
//    let groups: { countries: CountryName[]; fee: number }[] = [
//        {
//            countries: ["US (mainland)", "US (Alaska, Hawaii)", "Germany", "UK"],
//            fee: 5,
//        },
//        { countries: ["Austria", "Belgium", "France", "Netherlands"], fee: 6 },
//        {
//            countries: [
//                "Bulgaria",
//                "Croatia",
//                "Republic of Cyprus",
//                "Czech Republic",
//                "Estonia",
//                "Greece",
//                "Hungary",
//                "Latvia",
//                "Lithuania",
//                "Malta",
//                "Romania",
//                "Slovakia",
//                "Slovenia",
//            ],
//            fee: 24,
//        },
//        {
//            countries: ["China"],
//            fee: 25,
//        },
//        {
//            countries: ["Denmark", "Ireland", "Italy", "Luxembourg", "Poland", "Portugal", "Spain"],
//            fee: 12,
//        },
//        {
//            countries: ["Finland", "Malaysia", "Philippines", "Singapore"],
//            fee: 20,
//        },
//        {
//            countries: ["Sweden"],
//            fee: 10,
//        },
//    ]
//    const fee = groups.find((group) =>
//        group.countries
//            .map((country) => {
//                let c: string = country
//                return c
//            })
//            .includes(sellerInfo.countryName)
//    )?.fee
//    if (fee) {
//        sellerFee = fee
//    }
//
//    switch (sellerInfo.countryName) {
//        case "UK":
//        case "US (mainland)":
//        case "US (Alaska, Hawaii)":
//        case "Germany":
//            sellerFee = 5
//            break
//        case "Austria":
//        case "Belgium":
//            sellerFee = 6
//            break
//        case "Sweden":
//        case "Netherlands":
//            sellerFee = 10
//            break
//        case "Ireland":
//        case "Luxembourg":
//        case "France":
//            sellerFee = 12
//            break
//        case "Italy":
//        case "Finland":
//        case "Portugal":
//        case "Spain":
//        case "Denmark":
//        case "Malaysia":
//        case "Philippines":
//        case "Singapore":
//            sellerFee = 20
//        case "Bulgaria":
//            sellerFee = 24
//        case "China":
//            sellerFee = 25
//            break
//        default:
//            break
//    }
//    sellerFee = convert(sellerFee, "USD", currencyCode, false, exchangeRates)
//    const commissionFee = (price * sellerInfo.goat.commissionPercentage) / 100
//    const totalSellingFee = sellerFee + commissionFee
//    const sellerPrice = price - totalSellingFee
//    const cashoutFee = sellerPrice * sellerInfo.goat.cashOutFee
//    const totalCashoutValue = sellerPrice - cashoutFee
//
//    return Math.round(totalCashoutValue)
// }
//
// const goatBuyerPrice = (
//    price: number,
//    currencyCode: CurrencyCode,
//    sellerInfo: SellerInfo,
//    exchangeRates?: ExchangeRates
// ): number => {
//    let shippingFee: { fee: number; currency: CurrencyInternal } = { fee: 40, currency: USD }
//    if (sellerInfo.countryName === "US (mainland)") {
//        shippingFee = { fee: 12, currency: USD }
//    } else if (sellerInfo.countryName === "US (Alaska, Hawaii)") {
//        shippingFee = { fee: 15, currency: USD }
//    } else if (sellerInfo.countryName === "UK") {
//        shippingFee = { fee: 13, currency: GBP }
//    } else if (sellerInfo.countryName === "China") {
//        shippingFee = { fee: 25, currency: USD }
//    }
//    const shipping = convert(
//        shippingFee.fee,
//        shippingFee.currency.code,
//        currencyCode,
//        false,
//        exchangeRates
//    )
//    const priceWithShipping = price + shipping
//    let vat = (priceWithShipping * sellerInfo.goat.taxes) / 100
//
//    return Math.round(priceWithShipping + vat)
// }
//
func restocksSellerPrice(price: Double,
                         currencyCode: Currency.CurrencyCode,
                         feeCalculation: CopDeckSettings.FeeCalculation,
                         exchangeRates: ExchangeRates?) -> Double {
    let sellerFeeInEUR = Currency.convert(from: currencyCode, to: .eur, exchangeRates: exchangeRates) * 0.1 + 10
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
    let isNotSupportedCountry = notSupportedCountries.contains(where: { feeCalculation.country.name == $0 })
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
