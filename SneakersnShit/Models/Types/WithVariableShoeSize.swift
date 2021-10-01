//
//  WithVariableShoeSize.swift
//  CopDeck
//
//  Created by István Kreisz on 10/1/21.
//

import Foundation

func convertSize(from fromSize: ShoeSize, to toSize: ShoeSize, size: String) -> String {
    // htttps://stockx.com/news/mens-sneakers-sizing-chart/
    // eu, uk, us
    guard fromSize != toSize else { return size }
    let indexes: [ShoeSize: Int] = [.EU: 0, .UK: 1, .US: 2]
    let conversionChart = [[32, 13, 1],
                           [33, 14, 1.5],
                           [33, 1, 2],
                           [34, 1.5, 2.5],
                           [34, 2, 3],
                           [35.5, 3, 3.5],
                           [36, 3.5, 4],
                           [36.5, 4, 4.5],
                           [37.5, 4.5, 5],
                           [38, 5, 5.5],
                           [38.5, 5.5, 6],
                           [39, 6, 6.5],
                           [40, 6, 7],
                           [40.5, 6.5, 7.5],
                           [41, 7, 8],
                           [42, 7.5, 8.5],
                           [42.5, 8, 9],
                           [43, 8.5, 9.5],
                           [44, 9, 10],
                           [44.5, 9.5, 10.5],
                           [45, 10, 11],
                           [45.5, 10.5, 11.5],
                           [46, 11, 12],
                           [47, 11.5, 12.5],
                           [47.5, 12, 13],
                           [48, 12.5, 13.5],
                           [48.5, 13, 14],
                           [49.5, 14, 15],
                           [50.5, 15, 16],
                           [51.5, 16, 17],
                           [52.5, 17, 18]]

    guard let fromIndex = indexes[fromSize], let toIndex = indexes[toSize] else { return "" }

    guard let row = conversionChart.first(where: { row in
        size.number.map { $0 == row[fromIndex] } ?? false
    })
    else { return "" }

    let sizeNum = row[toIndex]
    return "\(toSize.rawValue) \(sizeNum)"
}

enum ShoeSize: String, Codable, Equatable, CaseIterable {
    case EU, UK, US
}

protocol WithVariableShoeSize {
    var usSize: String { get set }
}

extension WithVariableShoeSize {
    var size: String {
        get { convertSize(from: .US, to: AppStore.default.state.settings.shoeSize, size: usSize) }
        set { self.usSize = convertSize(from: AppStore.default.state.settings.shoeSize, to: .US, size: newValue) }
    }
}
