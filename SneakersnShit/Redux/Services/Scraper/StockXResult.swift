//
//  StockXResult.swift
//  SneakersnShit
//
//  Created by István Kreisz on 2/15/21.
//

import Foundation

struct StockXResult: Codable {
    let offers: Offers
}

// MARK: - Offers

struct Offers: Codable {
    let type: String
    let lowPrice: Int
    let highPrice: Int
    let priceCurrency: PriceCurrency
    let url: String
    let availability: String
    let offers: [Offer]

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case lowPrice, highPrice, priceCurrency, url, availability, offers
    }
}

// MARK: - Offer

struct Offer: Codable {
    let type: TypeEnum
    let availability: String
    let sku: String
    let price: Int
    let offerDescription: String
    let priceCurrency: PriceCurrency

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case availability, sku, price
        case offerDescription = "description"
        case priceCurrency
    }
}

enum PriceCurrency: String, Codable {
    case usd = "USD"
}

enum TypeEnum: String, Codable {
    case offer = "Offer"
}
