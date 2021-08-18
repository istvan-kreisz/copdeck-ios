//
//  ItemCache.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/17/21.
//

import Foundation
import Combine

typealias ItemCache = Cache<String, Item>

extension ItemCache {
    func insert(item: Item, settings: CopDeckSettings) {
        insert(item, forKey: Item.databaseId(itemId: item.id, settings: settings))
    }

    func valuePublisher(itemId: String, settings: CopDeckSettings) -> AnyPublisher<Value?, Never> {
        valuePublisher(forKey: Item.databaseId(itemId: itemId, settings: settings))
    }

    func value(item: Item, settings: CopDeckSettings) -> Item? {
        value(forKey: Item.databaseId(itemId: item.id, settings: settings))
    }

    func value(itemId: String, settings: CopDeckSettings) -> Item? {
        value(forKey: Item.databaseId(itemId: itemId, settings: settings))
    }

    static let `default`: Cache<String, Item> = {
        Cache<String, Item>(entryLifetimeMin: AppStore.pricesRefreshRateMin * 2)
    }()
}
