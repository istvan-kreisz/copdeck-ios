//
//  API.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import UIKit

protocol DataController: BackendAPI, DatabaseManager, ImageService {
    func stack(inventoryItems: [InventoryItem], stack: Stack)
    func unstack(inventoryItems: [InventoryItem], stack: Stack)
    func update(item: Item?,
                itemId: String,
                styleId: String,
                forced: Bool,
                settings: CopDeckSettings,
                exchangeRates: ExchangeRates?,
                completion: @escaping () -> Void)
}
