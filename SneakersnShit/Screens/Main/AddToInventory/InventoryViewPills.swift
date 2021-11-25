//
//  InventoryViewPills.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct InventoryViewPills: View {
    enum InventoryItemDetail: CaseIterable {
        case condition, size, purchasePrice
    }

    var inventoryItem: InventoryItem
    var inventoryItemDetails: [InventoryItemDetail] = InventoryItemDetail.allCases

    var columns: [GridItem] { Array.init(repeating: GridItem(.adaptive(minimum: 20, maximum: .infinity)), count: details.count) }

    var details: [(String, Int)] {
        inventoryItemDetails.map { type -> String? in
            switch type {
            case .condition:
                return inventoryItem.condition.rawValue
            case .size:
                return inventoryItem.convertedSize
            case .purchasePrice:
                return inventoryItem.purchasePrice?.asString
            }
        }
        .enumerated()
        .compactMap { item in item.element.map { ($0, item.offset) } ?? nil }
    }

    private func pillsHStack(pills: [(String, Int)], startIndex: Int) -> some View {
        Text(details.map(\.0).filter { !$0.isEmpty }.joined(separator: " • "))
            .font(.semiBold(size: 14))
            .foregroundColor(.customText2)
    }

    var body: some View {
        if UIScreen.isSmallScreen && details.count > 3 {
            VStack(spacing: 4) {
                pillsHStack(pills: details.first(n: 2), startIndex: 0)
                pillsHStack(pills: Array(details.dropFirst(2)), startIndex: 2)
            }
        } else {
            pillsHStack(pills: details, startIndex: 0)
        }
    }
}
