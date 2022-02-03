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

    struct SpreadsheetImport: Equatable, Codable {
        struct Summary: Equatable, Codable {
            let importCount: Int
            let errorCount: Int
            let description: String
        }

        let url: String?
        let status: SpreadSheetImportStatus?
        let pendingImport: Bool?
        let date: Double?
        let importer: String?
        let error: String?
        let summary: Summary?
        let spreadsheetId: String?
    }

    struct MembershipInfo: Equatable, Codable {
        let group: String?
        let referralCodeUsed: String?
        let referralCodeDiscount: String?
        let referralCodeName: String?

        var isBetaTester: Bool {
            group?.contains("iosbetatester") ?? false
        }
    }

    enum Subscription: String, Codable {
        case pro
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
    var tags: [Tag]? = nil
    var imageURL: URL?
    let spreadsheetImport: SpreadsheetImport?
    let membershipInfo: MembershipInfo?
    let country: String?
    var facebookProfileURL: String?
    var subscription: Subscription?
    let subscribedDate: String?
    var notificationsEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case id, inited, name, nameInsensitive, email, isPublic, created, updated, settings, tags, spreadsheetImport, membershipInfo, country, facebookProfileURL, subscription, subscribedDate, notificationsEnabled
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
        tags = try container.decodeIfPresent([Tag].self, forKey: .tags)
        spreadsheetImport = try container.decodeIfPresent(SpreadsheetImport.self, forKey: .spreadsheetImport)
        membershipInfo = try container.decodeIfPresent(MembershipInfo.self, forKey: .membershipInfo)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        facebookProfileURL = try container.decodeIfPresent(String.self, forKey: .facebookProfileURL)
        subscription = try container.decodeIfPresent(Subscription.self, forKey: .subscription)
        subscribedDate = try container.decodeIfPresent(String.self, forKey: .subscribedDate)
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled)
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
                  tags: nil,
                  spreadsheetImport: nil,
                  membershipInfo: nil,
                  country: nil,
                  facebookProfileURL: nil,
                  subscription: nil,
                  subscribedDate: nil,
                  notificationsEnabled: nil)
    }

    func withImageURL(_ url: URL?) -> User {
        var copy = self
        copy.imageURL = url
        return copy
    }
}

extension Array where Element == User {
    var asProfiles: [ProfileData] {
        get { self.map { .init(user: $0) } }
        set {}
    }
}
