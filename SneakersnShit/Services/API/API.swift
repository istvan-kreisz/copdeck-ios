//
//  API.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine

protocol API {
    func getExchangeRates(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<ExchangeRates, AppError>
    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError>
    func getItemDetails(for item: Item?, itemId: String, forced: Bool, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError>
//    func addToInventory(userId: String, inventoryItem: InventoryItem) -> AnyPublisher<InventoryItem, AppError>
//    func removeFromInventory(userId: String, inventoryItem: InventoryItem) -> AnyPublisher<Void, AppError>
//    func getInventoryItems(userId: String) -> AnyPublisher<[InventoryItem], AppError>
}
