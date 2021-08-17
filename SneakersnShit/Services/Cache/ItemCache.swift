//
//  ItemCache.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/17/21.
//

import Foundation

typealias ItemCache = Cache<String, Item>

extension ItemCache {
    static let `default`: Cache<String, Item> = {
        Cache<String, Item>(entryLifetimeMin: AppStore.pricesRefreshRateMin * 2)
    }()
}
