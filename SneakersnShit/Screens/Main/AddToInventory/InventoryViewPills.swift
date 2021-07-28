//
//  InventoryViewPills.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct InventoryViewPills: View {
    var inventoryItem: InventoryItem

    var statusText: String? {
        guard let status = inventoryItem.status else { return nil }
        switch status {
        case .none:
            return nil
        case .listed:
            return "listed"
        case .sold:
            if let soldPrice = inventoryItem.soldPrice {
                return soldPrice.storeId.map { "sold on: \($0)" } ?? "sold"
            } else {
                return "sold"
            }
        }
    }

    var columns: [GridItem] { Array.init(repeating: GridItem(.adaptive(minimum: 20, maximum: .infinity)), count: details.count) }

    var details: [(String, Int)] {
        [inventoryItem.condition.rawValue,
         inventoryItem.size,
         inventoryItem.purchasePrice.map { "\($0.currencySymbol.rawValue)\($0.price.rounded(toPlaces: 0))" },
         statusText].enumerated()
            .compactMap { item in item.element.map { ($0, item.offset) } ?? nil }
    }

    var body: some View {
//        TagCloudView(tags: details.map { $0.0 })
        HStack {
            ForEach(Array(details), id: \.self.1) { detail, index in
                PillView(title: detail, color: Color.pillColors[index % Color.pillColors.count])
            }
        }
    }
}

struct InventoryViewPills_Previews: PreviewProvider {
    static var previews: some View {
        return InventoryViewPills(inventoryItem: .init(fromItem: Item.sample))
    }
}

struct TagCloudView: View {
    var tags: [String]

    @State private var totalHeight
          = CGFloat.zero       // << variant for ScrollView/List
//        = CGFloat.infinity // << variant for VStack

    var body: some View {
        VStack(spacing: 3) {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight) // << variant for ScrollView/List
        // .frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.tags, id: \.self) { tag in
                self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > g.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.tags.last! {
                            width = 0 // last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if tag == self.tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(for text: String) -> some View {
        PillView(title: text, color: Color.randomPillColor)
//        Text(text)
//            .padding(.all, 5)
//            .font(.body)
//            .background(Color.blue)
//            .foregroundColor(Color.customWhite)
//            .cornerRadius(5)
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
