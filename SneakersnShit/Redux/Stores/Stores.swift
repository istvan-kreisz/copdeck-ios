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
    static var isChatDetailView = false
    static var requestInfo: [ScraperRequestInfo] = []

    static let `default`: AppStore = {
        let appStore = AppStore(state: .init(), reducer: appReducer, environment: World())
        appStore.setup()
        return appStore
    }()

    func setup() {
        setupTimers()
        setupObservers()
    }

    private func updateBestPrices(state: AppState, completion: @escaping ([String: ListingPrice]) -> Void) {
        let bestPrices = state.inventoryItems
            .map { (inventoryItem: InventoryItem) -> (String, ListingPrice?) in (inventoryItem.id, bestPrice(for: inventoryItem)) }
            .reduce([:]) { (dict: [String: ListingPrice], element: (String, ListingPrice?)) in
                if let price = element.1 {
                    var newDict = dict
                    newDict[element.0] = price
                    return newDict
                } else {
                    return dict
                }
            }
        completion(bestPrices)
    }

    private func updateTotalInventoryValue(state: AppState, bestPrices: [String: ListingPrice], completion: (PriceWithCurrency?) -> Void) {
        if let currencyCode = bestPrices.values.first?.price.currencyCode {
            let sum = state.inventoryItems
                .filter { (inventoryItem: InventoryItem) -> Bool in !inventoryItem.isSold }
                .compactMap { (inventoryItem: InventoryItem) -> Double? in bestPrices[inventoryItem.id]?.price.price }
                .sum()
            completion(PriceWithCurrency(price: sum, currencyCode: currencyCode))
        } else {
            completion(nil)
        }
    }

    private func updateInventoryValue() {
        let appState = state
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.updateBestPrices(state: appState) { bestPrices in
                self?.updateTotalInventoryValue(state: appState, bestPrices: bestPrices) { inventoryValue in
                    DispatchQueue.main.async {
                        self?.state.globalState.bestPrices = bestPrices
                        self?.state.globalState.inventoryValue = inventoryValue
                    }
                }
            }
        }
    }

    private func bestPrice(for inventoryItem: InventoryItem) -> ListingPrice? {
        if let itemId = inventoryItem.itemId, let item = ItemCache.default.value(itemId: itemId, settings: state.settings) {
            return item.bestPrice(for: inventoryItem.size,
                                  feeType: state.settings.bestPriceFeeType,
                                  priceType: state.settings.bestPricePriceType,
                                  stores: state.displayedStores)
        } else {
            return nil
        }
    }

    func setupObservers() {
        ItemCache.default.updatedPublisher.debounce(for: .milliseconds(2000), scheduler: RunLoop.main).prepend(())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateInventoryValue()
            }
            .store(in: &effectCancellables)

        environment.dataController.errorsPublisher.merge(with: environment.paymentService.errorsPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.state.error = error
            }
            .store(in: &effectCancellables)

        environment.dataController.userPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] newUser in
                      let oldSettings = self?.state.user?.settings
                      let newSettings = newUser.settings
                      if oldSettings?.feeCalculation != newSettings?.feeCalculation || oldSettings?.currency != newSettings?.currency {
                          self?.environment.dataController.clearConfigs()
                          ItemCache.default.removeAll()
                          self?.refreshItemPricesIfNeeded(newUser: newUser)
                      }
                      self?.state.user = newUser
                      self?.updateInventoryValue()
                  })
            .store(in: &effectCancellables)

        environment.dataController.inventoryItemsPublisher
            .map { inventoryItems in inventoryItems.filter { $0.pendingImport == nil } }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] inventoryItems in
                      self?.state.inventoryItems = inventoryItems
                      if !inventoryItems.isEmpty, self?.state.didFetchItemPrices == false {
                          self?.refreshItemPricesIfNeeded()
                          self?.state.didFetchItemPrices = true
                      }
                      self?.updateInventoryValue()
                  })
            .store(in: &effectCancellables)

        environment.dataController.stacksPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] stacks in
                      self?.state.stacks = [.allStack] + stacks
                  })
            .store(in: &effectCancellables)

        environment.dataController.exchangeRatesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] exchangeRates in
                      self?.state.exchangeRates = exchangeRates
                  })
            .store(in: &effectCancellables)

        environment.dataController.scraperConfigPublisher
            .removeDuplicates()
            .combineLatest(environment.dataController.imageDownloadHeadersPublisher.removeDuplicates()) { configs, headers in
                configs.map { (config: ScraperConfig) -> ScraperRequestInfo in
                    ScraperRequestInfo(storeId: config.storeId,
                                       cookie: config.cookie,
                                       imageDownloadHeaders: headers.first(where: { $0.storeId == config.storeId })?.headers ?? [:])
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                Self.requestInfo = $0
            })
            .store(in: &effectCancellables)

        environment.dataController.recentlyViewedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in
                      self?.state.recentlyViewedItems = $0
                  })
            .store(in: &effectCancellables)

        environment.dataController.favoritesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] favorites in
                      self?.state.favoritedItems = favorites
                  })
            .store(in: &effectCancellables)

        environment.dataController.profileImagePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] url in
                      self?.state.profileImageURL = url
                  })
            .store(in: &effectCancellables)

        environment.paymentService.packagesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] packages in
                      self?.state.allPackages = packages
                  })
            .store(in: &effectCancellables)

        environment.dataController.chatUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] chatUpdateInfo in
                      self?.state.globalState.chatUpdates = chatUpdateInfo
                  })
            .store(in: &effectCancellables)
    }

    func setupTimers() {
        Timer.scheduledTimer(withTimeInterval: 60 * World.Constants.priceCheckRefreshIntervalMin, repeats: true) { [weak self] _ in
            self?.refreshItemPricesIfNeeded()
        }
    }

    private struct Ids: Hashable {
        let itemId: String
        let styleId: String
    }

    func refreshItemPricesIfNeeded(newUser: User? = nil) {
        guard state.user != nil else { return }
        let idsToRefresh = Set(state.inventoryItems.compactMap { (inventoryItem: InventoryItem) -> Ids? in
            if let itemId = inventoryItem.itemId {
                return Ids(itemId: itemId, styleId: inventoryItem.styleId)
            } else {
                return nil
            }
        })
            .filter { ids in
                guard !ids.itemId.isEmpty, !ids.styleId.isEmpty else { return false }
                if let item = ItemCache.default.value(forKey: Item.databaseId(itemId: ids.itemId, settings: newUser?.settings ?? state.settings)) {
                    return item.storePrices.isEmpty || !item.isUptodate
                } else {
                    return true
                }
            }
        var idsWithDelay = idsToRefresh
            .map { (ids: Ids) in (ids, Double.random(in: 0.2 ... 0.45)) }

        idsWithDelay = idsWithDelay
            .enumerated()
            .map { (offset: Int, idWithDelay: (Ids, Double)) in
                (idWithDelay.0, idWithDelay.1 + (idsWithDelay[safe: offset - 1]?.1 ?? 0))
            }
        log("refreshing prices for items with ids: \(idsToRefresh)", logType: .scraping)
        if !state.didFetchItemPrices {
            idsWithDelay
                .forEach { [weak self] (ids: Ids, _) in
                    self?.send(.main(action: .refreshItemIfNeeded(itemId: ids.itemId, styleId: ids.styleId, fetchMode: .cacheOnly)))
                }
        }
        idsWithDelay
            .forEach { (ids: Ids, delay: Double) in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.send(.main(action: .refreshItemIfNeeded(itemId: ids.itemId, styleId: ids.styleId, fetchMode: .cacheOrRefresh)))
                }
            }
    }
}

private func imageRequest(for imageURL: ImageURL?) -> ImageRequestConvertible? {
    if let imageURL = imageURL, let url = URL(string: imageURL.url) {
        var request = URLRequest(url: url)

        if let headers = AppStore.requestInfo.first(where: { $0.storeId == imageURL.store?.id })?.imageDownloadHeaders {
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

func onMain(completion: @escaping () -> Void) {
    DispatchQueue.main.async(execute: completion)
}
