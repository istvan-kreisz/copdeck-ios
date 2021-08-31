//
//  ModelWithDate.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/24/21.
//

import Foundation

enum DateType {
    case created, updated
}

enum DateSortOrder {
    case ascending, descending
}

protocol ModelWithDate {
    var created: Double? { get }
    var updated: Double? { get }
}

extension Sequence where Element: ModelWithDate {
    func sortedByDate(dateType: DateType = .created, sortOrder: DateSortOrder = .ascending) -> [Element] {
        sorted { first, second in
            if let date1 = dateType == .created ? first.created : first.updated,
               let date2 = dateType == .created ? second.created : second.updated {
                if sortOrder == .ascending {
                    return date1 < date2
                } else {
                    return date1 > date2
                }
            } else {
                return true
            }
        }
    }
}
