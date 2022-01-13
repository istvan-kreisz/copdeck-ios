//
//  BackendAPI.swift
//  CopDeck
//
//  Created by István Kreisz on 11/4/21.
//

import Combine
import UIKit

protocol BackendAPI {
    var errorsPublisher: AnyPublisher<AppError, Never> { get }

    // setup
    func setup(userId: String)
    func reset()
    // feed
    func getFeedPosts(loadMore: Bool) -> AnyPublisher<PaginatedResult<[FeedPost]>, AppError>
    func updateLike(onStack stack: Stack, addLike: Bool, stackOwnerId: String)
    // search
    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates?) -> AnyPublisher<[ItemSearchResult], AppError>
    func update(item: Item, forced: Bool, settings: CopDeckSettings, exchangeRates: ExchangeRates?, completion: @escaping () -> Void)
    func updateUserItems(completion: @escaping () -> Void)
    // user
    func getUserProfile(userId: String) -> AnyPublisher<ProfileData, AppError>
    func searchUsers(searchTerm: String) -> AnyPublisher<[User], AppError>
    func getUsers(userIds: [String], completion: @escaping (Result<[User], AppError>) -> Void)
    // spreadsheet import
    func startSpreadsheetImport(urlString: String, completion: @escaping (Error?) -> Void)
    func revertLastImport(completion: @escaping (Error?) -> Void)
    // admin
    func updateSpreadsheetImportStatus(importedUserId: String,
                                       spreadSheetImportStatus: User.SpreadSheetImportStatus,
                                       spreadSheetImportError: String?,
                                       completion: @escaping (Result<User, Error>) -> Void)
    func runImport(importedUserId: String, completion: @escaping (Result<User, Error>) -> Void)
    func finishImport(importedUserId: String, completion: @escaping (Result<User, Error>) -> Void)
    func getImportedInventoryItems(importedUserId: String, completion: @escaping (Result<[InventoryItem], Error>) -> Void)
    // membership
    func applyReferralCode(_ code: String, completion: ((Result<Void, AppError>) -> Void)?)
    func getAffiliateList(completion: @escaping (Result<[ReferralCode], Error>) -> Void)
    func refreshUserSubscriptionStatus(completion: ((Result<Void, AppError>) -> Void)?)
    // contact support
    func sendMessage(email: String, message: String, completion: ((Result<Void, AppError>) -> Void)?)
}
