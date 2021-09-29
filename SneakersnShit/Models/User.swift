//
//  User.swift
//  CopDeck
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

struct User: Codable, Equatable, Identifiable {
    enum SpreadSheetImportStatus: String, Equatable, Codable, CaseIterable, Identifiable {
        case Pending, Processing, Done, Error

        var id: String { rawValue }
    }
    
    let id: String
    var inited: Bool?
    var name: String?
    var nameInsensitive: String?
    let email: String?
    var isPublic: Bool? = true
    let created: Double?
    let updated: Double?
    var settings: CopDeckSettings?
    var imageURL: URL?
    #warning("refactor into object")
    let spreadSheetImportUrl: String?
    let spreadSheetImportStatus: SpreadSheetImportStatus?
    let spreadSheetImportDate: Double?
    let spreadSheetImporter: String?
    let spreadSheetImportError: String?
    let affiliatePromoCode: String?

    enum CodingKeys: String, CodingKey {
        case id, inited, name, nameInsensitive, email, isPublic, created, updated, settings, spreadSheetImportUrl, spreadSheetImportStatus, spreadSheetImportDate,
             spreadSheetImporter, spreadSheetImportError, affiliatePromoCode
    }
}

extension User {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        inited = try container.decodeIfPresent(Bool.self, forKey: .inited)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        nameInsensitive = try container.decodeIfPresent(String.self, forKey: .nameInsensitive)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        isPublic = true
        created = try container.decodeIfPresent(Double.self, forKey: .created)
        updated = try container.decodeIfPresent(Double.self, forKey: .updated)
        settings = try container.decodeIfPresent(CopDeckSettings.self, forKey: .settings)
        spreadSheetImportUrl = try container.decodeIfPresent(String.self, forKey: .spreadSheetImportUrl)
        spreadSheetImportStatus = try container.decodeIfPresent(SpreadSheetImportStatus.self, forKey: .spreadSheetImportStatus)
        spreadSheetImportDate = try container.decodeIfPresent(Double.self, forKey: .spreadSheetImportDate)
        spreadSheetImporter = try container.decodeIfPresent(String.self, forKey: .spreadSheetImporter)
        spreadSheetImportError = try container.decodeIfPresent(String.self, forKey: .spreadSheetImportError)
        affiliatePromoCode = try container.decodeIfPresent(String.self, forKey: .affiliatePromoCode)
    }

    init(id: String) {
        self.init(id: id,
                  name: nil,
                  nameInsensitive: nil,
                  email: nil,
                  isPublic: true,
                  created: nil,
                  updated: nil,
                  settings: nil,
                  spreadSheetImportUrl: nil,
                  spreadSheetImportStatus: nil,
                  spreadSheetImportDate: nil,
                  spreadSheetImporter: nil,
                  spreadSheetImportError: nil,
                  affiliatePromoCode: nil)
    }

    func withImageURL(_ url: URL?) -> User {
        var copy = self
        copy.imageURL = url
        return copy
    }
}

extension Array where Element == User {
    var asProfiles: [ProfileData] {
        get { self.map { .init(user: $0, stacks: [], inventoryItems: []) } }
        set {}
    }
}
