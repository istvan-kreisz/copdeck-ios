//
//  ScraperRequestInfo.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/28/21.
//

import Foundation

struct ScraperConfig: Codable, Equatable {
    let storeId: StoreId
    let isValid: Bool
    let cookie: String?
    let csrf: String?
}


struct ScraperRequestInfo: Equatable {
    let storeId: StoreId
    var cookie: String?
    var imageDownloadHeaders: [String: String]
}

struct Cookie: Codable, Equatable {
    let store: StoreId
    let cookie: String?
}

struct HeadersWithStoreId: Codable, Equatable {
    let storeId: StoreId
    let headers: [String: String]
}
