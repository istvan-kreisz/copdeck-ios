//
//  API.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import UIKit

protocol DataController: LocalAPI, BackendAPI, DatabaseManager, ImageService {
    func clearCookies()
    func stack(inventoryItems: [InventoryItem], stack: Stack)
    func unstack(inventoryItems: [InventoryItem], stack: Stack)
    func getItemDetails(for item: Item?,
                        itemId: String,
                        styleId: String,
                        fetchMode: FetchMode,
                        settings: CopDeckSettings,
                        exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError>
}
