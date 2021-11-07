//
//  InventoryViewPills.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct InventoryViewPills: View {
    enum PillType: CaseIterable {
        case condition, size, purchasePrice
    }

    var inventoryItem: InventoryItem
    var pillTypes: [PillType] = PillType.allCases

    var columns: [GridItem] { Array.init(repeating: GridItem(.adaptive(minimum: 20, maximum: .infinity)), count: details.count) }

    var details: [(String, Int)] {
        [inventoryItem.condition.rawValue,
         inventoryItem.convertedSize,
         inventoryItem.purchasePrice?.asString].enumerated()
            .compactMap { item in item.element.map { ($0, item.offset) } ?? nil }
    }
    
    private func pillsHStack(pills: [(String, Int)], startIndex: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(pills, id: \.self.1) { (detail: String, index: Int) in
                PillView(title: detail, color: Color.pillColors[(index + startIndex) % Color.pillColors.count])
            }
            Spacer()
        }
    }

    var body: some View {
        if UIScreen.isSmallScreen && details.count > 2 {
            VStack(spacing: 4) {
                pillsHStack(pills: details.first(n: 2), startIndex: 0)
                pillsHStack(pills: Array(details.dropFirst(2)), startIndex: 2)
            }
        } else {
            pillsHStack(pills: details, startIndex: 0)
        }
    }
}
