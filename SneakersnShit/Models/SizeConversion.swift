//
//  SizeConversion.swift
//  CopDeck
//
//  Created by István Kreisz on 10/10/21.
//

import Foundation

// MARK: - WelcomeElement

struct SizeConversion: Codable {
    struct Sizes: Codable {
        struct ManufacturerDetails: Codable {
            let name: String
        }

        struct Sizetables: Codable {
            struct Chart: Codable {
                enum Kind: String, Codable {
                    case kids, men, unisex, women
                }

                struct Value: Codable {
                    let eur: String
                    let us: String
                    let uk: String

                    enum CodingKeys: String, CodingKey {
                        case eur = "EUR"
                        case us = "US"
                        case uk = "UK"
                    }
                }

                let kind: Kind
                let values: [Value]
            }

            let women: [Chart]
            let unisex: [Chart]?
            let kids: [Chart]?
            let men: [Chart]
        }

        let manufacturerDetails: ManufacturerDetails
        let sizetables: Sizetables
    }

    let sizes: Sizes
    let brandId: BrandId
}
