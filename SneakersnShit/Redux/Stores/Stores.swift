//
//  Stores.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation
import Combine
import Nuke

typealias AppStore = ReduxStore<AppState, AppAction, World>

extension AppStore {
    static let `default`: AppStore = {
        let appStore = AppStore(state: .init(), reducer: appReducer, environment: World())
        appStore.setup()
        return appStore
    }()

    func setup() {
        setupTimers()
        setupObservers()
    }

    func setupObservers() {
        environment.dataController.errorsPublisher.merge(with: environment.paymentService.errorsPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.state.error = error
            }
            .store(in: &effectCancellables)

        environment.dataController.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newUser in
                let oldSettings = self?.state.user?.settings
                let newSettings = newUser.settings
                if oldSettings?.feeCalculation != newSettings?.feeCalculation || oldSettings?.currency != newSettings?.currency {
                    ItemCache.default.removeAll()
                    self?.refreshItemPricesIfNeeded(newUser: newUser)
                }
                self?.state.user = newUser
            }
            .store(in: &effectCancellables)

        environment.dataController.inventoryItemsPublisher
            .map { inventoryItems in inventoryItems.filter { $0.pendingImport == nil } }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inventoryItems in
                self?.state.inventoryItems = inventoryItems
                self?.updateAllStack(withInventoryItems: inventoryItems)
                if !inventoryItems.isEmpty, self?.state.didFetchItemPrices == false {
                    self?.refreshItemPricesIfNeeded()
                    self?.state.didFetchItemPrices = true
                }
            }
            .store(in: &effectCancellables)

        environment.dataController.stacksPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stacks in
                self?.state.stacks = (self?.state.allStack.map { (stack: Stack) in [stack] } ?? []) + stacks
            }
            .store(in: &effectCancellables)

        environment.dataController.exchangeRatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exchangeRates in
                self?.state.exchangeRates = exchangeRates
            }
            .store(in: &effectCancellables)

        environment.dataController.cookiesPublisher.removeDuplicates()
            .combineLatest(environment.dataController.imageDownloadHeadersPublisher.removeDuplicates()) { cookies, headers in
                cookies.map { (cookie: Cookie) -> ScraperRequestInfo in
                    ScraperRequestInfo(storeId: cookie.store,
                                       cookie: cookie.cookie,
                                       imageDownloadHeaders: headers.first(where: { $0.storeId == cookie.store })?.headers ?? [:])
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.state.requestInfo = $0
            })
            .store(in: &effectCancellables)

        environment.dataController.recentlyViewedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recentlyViewed in
                self?.state.recentlyViewed = recentlyViewed
            }
            .store(in: &effectCancellables)

        environment.dataController.favoritesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favorites in
                self?.state.favoritedItems = favorites
            }
            .store(in: &effectCancellables)

        environment.dataController.profileImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.state.profileImageURL = url
            }
            .store(in: &effectCancellables)

        environment.paymentService.packagesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] packages in
                self?.state.allPackages = packages
            }
            .store(in: &effectCancellables)

        environment.paymentService.purchaserInfoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] purchaserInfo in
                self?.state.purchaserInfo = purchaserInfo
            }
            .store(in: &effectCancellables)
    }

    func updateAllStack(withInventoryItems inventoryItems: [InventoryItem]) {
        if state.stacks.isEmpty {
            state.stacks = [.allStack(inventoryItems: inventoryItems)]
        } else if let allStackIndex = state.allStackIndex {
            state.stacks[allStackIndex].items = inventoryItems.map { (inventoryItem: InventoryItem) in StackItem(inventoryItemId: inventoryItem.id) }
        } else {
            state.stacks.insert(.allStack(inventoryItems: inventoryItems), at: 0)
        }
    }

    func setupTimers() {
        Timer.scheduledTimer(withTimeInterval: 60 * World.Constants.pricesRefreshPeriodMin, repeats: true) { [weak self] _ in
            self?.refreshItemPricesIfNeeded()
        }
    }

    func refreshItemPricesIfNeeded(newUser: User? = nil) {
        guard state.user != nil else { return }
        let idsToRefresh = Set(state.inventoryItems.compactMap { $0.itemId }).filter { id in
            if let item = ItemCache.default.value(forKey: Item.databaseId(itemId: id, settings: newUser?.settings ?? state.settings)) {
                return item.storePrices.isEmpty || !item.isUptodate
            } else {
                return true
            }
        }
        var idsWithDelay = idsToRefresh
            .map { (id: String) in (id, Double.random(in: 0.2 ... 0.45)) }

        idsWithDelay = idsWithDelay
            .enumerated()
            .map { (offset: Int, idWithDelay: (String, Double)) in
                (idWithDelay.0, idWithDelay.1 + (idsWithDelay[safe: offset - 1]?.1 ?? 0))
            }
        log("refreshing prices for items with ids: \(idsToRefresh)", logType: .scraping)
        if !state.didFetchItemPrices {
            idsWithDelay
                .forEach { [weak self] (id: String, _) in
                    self?.send(.main(action: .refreshItemIfNeeded(itemId: id, fetchMode: .cacheOnly)))
                }
        }
        idsWithDelay
            .forEach { (id: String, delay: Double) in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.send(.main(action: .refreshItemIfNeeded(itemId: id, fetchMode: .cacheOrRefresh)))
                }
            }
    }
}

private func imageRequest(for imageURL: ImageURL?) -> ImageRequestConvertible? {
    if let imageURL = imageURL, let url = URL(string: imageURL.url) {
        var request = URLRequest(url: url)

        if let headers = AppStore.default.state.requestInfo.first(where: { $0.storeId == imageURL.store?.id })?.imageDownloadHeaders {
            headers.forEach { name, value in
                request.setValue(value, forHTTPHeaderField: name)
            }
        }
        return ImageRequest(urlRequest: request)
    } else {
        return nil
    }
}

func imageSource(for item: Item?) -> ImageViewSourceType {
    guard let item = item else { return .url(nil) }
    return .publisher(Future { promise in
        AppStore.default.send(.main(action: .getItemImage(itemId: item.id,
                                                          completion: { url in
                                                              if let url = url {
                                                                  promise(.success(url))
                                                              } else {
                                                                  promise(.success(imageRequest(for: item.imageURL)))
                                                              }
                                                          })))
    }.eraseToAnyPublisher())
}

func imageSource(for inventoryItem: InventoryItem) -> ImageViewSourceType {
    guard let itemId = inventoryItem.itemId else { return .url(imageRequest(for: inventoryItem.imageURL)) }
    return .publisher(Future { promise in
        AppStore.default.send(.main(action: .getItemImage(itemId: itemId,
                                                          completion: { url in
                                                              if let url = url {
                                                                  promise(.success(url))
                                                              } else {
                                                                  promise(.success(imageRequest(for: inventoryItem.imageURL)))
                                                              }
                                                          })))
    }.eraseToAnyPublisher())
}
