//
//  WithVariableShoeSize.swift
//  CopDeck
//
//  Created by István Kreisz on 10/1/21.
//

import Foundation

enum BrandId: String, Codable, Equatable {
    case adidas
    case jordan
    case nike
    case newbalance
    case asics
    case diadora
    case converse
    case puma
    case vans
    case balenciaga
    case burberry
    case chanel
    case commonprojects
    case dior
    case gucci
    case louisvuitton
    case prada
    case reebok
    case saintlaurent
    case saucony
    case versace
    case underarmour
}

struct Brand: Codable, Equatable, Hashable {
    let id: BrandId
    let stockx: String
    let goat: String
    let klekt: String
}

let ADIDAS = Brand(id: .adidas, stockx: "adidas", goat: "adidas", klekt: "Adidas")
let JORDAN = Brand(id: .nike, stockx: "Jordan", goat: "Air Jordan", klekt: "Air Jordan")
let NIKE = Brand(id: .nike, stockx: "Nike", goat: "Nike", klekt: "Nike")
let NEWBALANCE = Brand(id: .newbalance, stockx: "New Balance", goat: "New Balance", klekt: "New Balance")
let ASICS = Brand(id: .asics, stockx: "ASICS", goat: "ASICS", klekt: "Asics")
let DIADORA = Brand(id: .diadora, stockx: "Diadora", goat: "Diadora", klekt: "Diadora")
let CONVERSE = Brand(id: .converse, stockx: "Converse", goat: "Converse", klekt: "Converse")
let PUMA = Brand(id: .puma, stockx: "Puma", goat: "Puma", klekt: "Puma")
let SAUCONY = Brand(id: .saucony, stockx: "Saucony", goat: "Saucony", klekt: "Saucony")
let UNDERARMOUR = Brand(id: .underarmour, stockx: "Under Armour", goat: "Under Armour", klekt: "Under Armour")
let VANS = Brand(id: .vans, stockx: "Vans", goat: "Vans", klekt: "Vans")
let BALENCIAGA = Brand(id: .balenciaga, stockx: "Balenciaga", goat: "Balenciaga", klekt: "Balenciaga")
let BURBERRY = Brand(id: .burberry, stockx: "Burberry", goat: "Burberry", klekt: "Burberry")
let CHANEL = Brand(id: .chanel, stockx: "Chanel", goat: "Chanel", klekt: "Chanel")
let COMMONPROJECTS = Brand(id: .commonprojects, stockx: "Common Projects", goat: "Common Projects", klekt: "Common Projects")
let DIOR = Brand(id: .dior, stockx: "Dior", goat: "Dior", klekt: "Dior")
let GUCCI = Brand(id: .gucci, stockx: "Gucci", goat: "Gucci", klekt: "Gucci")
let LOUISVUITTON = Brand(id: .louisvuitton, stockx: "Louis Vuitton", goat: "Louis Vuitton", klekt: "Louis Vuitton")
let PRADA = Brand(id: .prada, stockx: "Prada", goat: "Prada", klekt: "Prada")
let REEBOK = Brand(id: .reebok, stockx: "Reebok", goat: "Reebok", klekt: "Reebok")
let SAINTLAURENT = Brand(id: .saintlaurent, stockx: "Saint Laurent", goat: "Saint Laurent", klekt: "Saint Laurent")
let VERSACE = Brand(id: .versace, stockx: "Versace", goat: "Versace", klekt: "Versace")

let ALLBRANDS: [Brand] = [ADIDAS,
                          JORDAN,
                          NIKE,
                          NEWBALANCE,
                          ASICS,
                          DIADORA,
                          CONVERSE,
                          PUMA,
                          SAUCONY,
                          UNDERARMOUR,
                          VANS,
                          BALENCIAGA,
                          BURBERRY,
                          CHANEL,
                          COMMONPROJECTS,
                          DIOR,
                          GUCCI,
                          LOUISVUITTON,
                          PRADA,
                          REEBOK,
                          SAINTLAURENT,
                          VERSACE]

func getBrand(storeInfoArray: [Item.StoreInfo]) -> Brand? {
    for storeInfo in storeInfoArray {
        let store = storeInfo.store.id
        if store == .restocks || storeInfo.brand.isEmpty { continue }
        if let brand = ALLBRANDS.first(where: { brand in
            switch store {
            case .stockx:
                return brand.stockx == storeInfo.brand
            case .goat:
                return brand.goat == storeInfo.brand
            case .klekt:
                return brand.klekt == storeInfo.brand
            case .restocks:
                return false
            }
        }) {
            return brand
        }
    }
    return nil
}

enum Gender: String, Codable, Equatable {
    case Men, Women, Kids
}

func getGender(storeInfoArray: [Item.StoreInfo]) -> Gender {
    for storeInfo in storeInfoArray.filter({ $0.store.id == .stockx || $0.store.id == .goat }) {
        return storeInfo.gender ?? .Men
    }
    for storeInfo in storeInfoArray.filter({ $0.store.id == .klekt || $0.store.id == .restocks }) {
        let lowercasedName = storeInfo.name.lowercased()
        if lowercasedName.contains("(kids)") || lowercasedName.contains("(gs)") || lowercasedName.contains("(infant)") {
            return .Kids
        } else if lowercasedName.contains("women") {
            return .Women
        } else {
            return .Men
        }
    }
    return .Men
}

let sizeCharts: [SizeConversion] = {
    if let path = Bundle.main.path(forResource: "sizes", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return try JSONDecoder().decode([SizeConversion].self, from: data)
        } catch {
            return []
        }
    } else {
        return []
    }
}()

let conversionChart = [["32", "13", "1"],
                       ["33", "14", "1.5"],
                       ["33", "1", "2"],
                       ["34", "1.5", "2.5"],
                       ["34", "2", "3"],
                       ["35½", "3", "3.5"],
                       ["36", "3.5", "4"],
                       ["36½", "4", "4.5"],
                       ["37½", "4.5", "5"],
                       ["38", "5", "5.5"],
                       ["38½", "5.5", "6"],
                       ["39", "6", "6.5"],
                       ["40", "6", "7"],
                       ["40½", "6.5", "7.5"],
                       ["41", "7", "8"],
                       ["42", "7.5", "8.5"],
                       ["42½", "8", "9"],
                       ["43", "8.5", "9.5"],
                       ["44", "9", "10"],
                       ["44½", "9.5", "10.5"],
                       ["45", "10", "11"],
                       ["45½", "10.5", "11.5"],
                       ["46", "11", "12"],
                       ["47", "11.5", "12.5"],
                       ["47½", "12", "13"],
                       ["48", "12.5", "13.5"],
                       ["48½", "13", "14"],
                       ["49½", "14", "15"],
                       ["50½", "15", "16"],
                       ["51½", "16", "17"],
                       ["52½", "17", "18"]]

let conversionChartWomen = [["35.5", "2.5", "5"],
                            ["36", "3", "5.5"],
                            ["36.5", "3.5", "6"],
                            ["37.5", "4", "6.5"],
                            ["38", "4.5", "7"],
                            ["38.5", "5", "7.5"],
                            ["39", "5.5", "8"],
                            ["40", "6", "8.5"],
                            ["40.5", "6.5", "9"],
                            ["41", "7", "9.5"],
                            ["42", "7.5", "10"],
                            ["42.5", "8", "10.5"],
                            ["43", "8.5", "11"],
                            ["44", "9", "11.5"],
                            ["44.5", "9.5", "12"]]

func convertSizes(from fromSize: ShoeSize,
                  to toSize: ShoeSize,
                  sizes: [String],
                  gender: Gender?,
                  brand: Brand?) -> [String] {
    var sizesNormalized = sizes.map {
        $0
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "US", with: "")
    }

    guard fromSize != toSize else { return sizesNormalized }

    if fromSize == .EU {
        sizesNormalized = sizes.map {
            $0
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "US", with: "")
                .replacingOccurrences(of: "1/2", with: "½")
                .replacingOccurrences(of: "1/3", with: "⅓")
                .replacingOccurrences(of: "2/3", with: "⅔")
                .replacingOccurrences(of: ".5", with: "½")
        }
    }

    var sizesConverted: [String] = []

    if let brand = brand, let gender = gender {
        var charts: [SizeConversion.Sizes.Sizetables.Chart] = []
        if let conversionCharts = sizeCharts.first(where: { $0.brandId == brand.id })?.sizes.sizetables {
            switch gender {
            case .Men:
                charts = [conversionCharts.men, conversionCharts.unisex ?? []].flatMap { $0 }
            case .Women:
                charts = [conversionCharts.women, conversionCharts.unisex ?? []].flatMap { $0 }
            case .Kids:
                charts = conversionCharts.kids ?? []
            }
        }
        sizesNormalized.forEach { sizeNormalized in
            for chart in charts {
                if let row = chart.values.first(where: { val in
                    switch fromSize {
                    case .EU:
                        return val.eur == sizeNormalized
                    case .UK:
                        return val.uk == sizeNormalized
                    case .US:
                        return val.us == sizeNormalized
                    }
                }) {
                    switch toSize {
                    case .EU:
                        sizesConverted.append(row.eur)
                    case .UK:
                        sizesConverted.append(row.uk)
                    case .US:
                        sizesConverted.append(row.us)
                    }
                }
            }
        }
    }
    if sizesConverted.count == sizes.count {
        return sizesConverted
    } else {
        sizesConverted = []
        let indexes: [ShoeSize: Int] = [.EU: 0, .UK: 1, .US: 2]

        guard let fromIndex = indexes[fromSize], let toIndex = indexes[toSize] else { return sizesNormalized }

        let chart = gender == .Women ? conversionChartWomen : conversionChart
        sizesNormalized.forEach { sizeNormalized in
            guard let row = chart.first(where: { sizeNormalized == $0[fromIndex] }) else {
                sizesConverted.append("")
                return
            }

            sizesConverted.append(row[toIndex])
        }
        return sizesConverted
    }
}

func convertSize(from fromSize: ShoeSize,
                 to toSize: ShoeSize,
                 size: String,
                 gender: Gender?,
                 brand: Brand?) -> String {
    convertSizes(from: fromSize, to: toSize, sizes: [size], gender: gender, brand: brand).first ?? ""
}

enum ApparelSize: String, Codable, Equatable, CaseIterable {
    case XXS, XS, S, M, L, XL, XXL, XXXL
}

enum ShoeSize: String, Codable, Equatable, CaseIterable {
    case EU, UK, US

    static let ALLSHOESIZESUS = (6 ... 36)
        .reversed()
        .filter { $0 > 26 ? $0.isMultiple(of: 2) : true }
        .map { "US \((Double($0) * 0.5).rounded(toPlaces: $0 % 2 == 1 ? 1 : 0))" }

    static var ALLSHOESIZESCONVERTED: [String] {
        convertSizes(from: .US, to: AppStore.default.state.settings.shoeSize, sizes: ALLSHOESIZESUS, gender: .Men, brand: nil).uniqued()
    }
}
