//
//  Filters.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/21/21.
//

import Foundation

struct Filters: Codable, Equatable {
    enum SoldStatusFilter: String, Equatable, CaseIterable, EnumCodable {
        case Sold, Unsold, All
    }

    enum SortOption: String, Equatable, CaseIterable, EnumCodable {
        case CreatedDesc
        case CreatedAsc
        case UpdatedDesc
        case UpdatedAsc

        var name: String {
            switch self {
            case .CreatedDesc:
                return "Created date (desc)"
            case .CreatedAsc:
                return "Created date (asc)"
            case .UpdatedDesc:
                return "Updated date (desc)"
            case .UpdatedAsc:
                return "Updated date (asc)"
            }
        }

        static func initWith(name: String) -> Self? {
            Self.allCases.first(where: { $0.name == name })
        }
    }

    var soldStatus: SoldStatusFilter
    var sortOption: SortOption
    var groupByModels = false

    static let `default` = Filters(soldStatus: .All, sortOption: .CreatedDesc, groupByModels: false)
}

extension Filters {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        soldStatus = try container.decode(SoldStatusFilter.self, forKey: .soldStatus)
        sortOption = try container.decodeIfPresent(SortOption.self, forKey: .sortOption) ?? .CreatedAsc
        groupByModels = try container.decodeIfPresent(Bool.self, forKey: .groupByModels) ?? false
    }
}
