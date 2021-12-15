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

    static let `default`: AppStore = {
        let appStore = AppStore(state: .init(), reducer: appReducer, environment: World())
        appStore.setup()
        return appStore
    }()

    func setup() {
        setupTimers()
        setupObservers()
    }

    private func updateBestPrices(items: [Item], completion: @escaping ([String: ListingPrice]) -> Void) {
        let bestPrices = state.inventoryItems
            .compactMap { (inventoryItem: InventoryItem) -> (String, ListingPrice?)? in
                guard let item = items.first(where: { $0.id == inventoryItem.itemId }) else { return nil }
                return (inventoryItem.id, bestPrice(for: inventoryItem, item: item))
            }
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

    private func bestPrice(for inventoryItem: InventoryItem, item: Item) -> ListingPrice? {
        item.bestPrice(for: inventoryItem.size,
                       feeType: state.settings.bestPriceFeeType,
                       priceType: state.settings.bestPricePriceType,
                       stores: state.displayedStores)
    }

    private func updateInventoryValue() {
        environment.dataController.getItems(withIds: state.inventoryItems.compactMap(\.itemId), settings: state.settings) { items in
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                self?.updateBestPrices(items: items) { [weak self] bestPrices in
                    guard let self = self else { return }
                    let updatedInventoryItems = self.state.inventoryItems
                        .map { (inventoryItem: InventoryItem) -> InventoryItem in
                            var updatedInventoryItem = inventoryItem
                            if let itemId = inventoryItem.itemId, let bestPrice = bestPrices[itemId] {
                                updatedInventoryItem.bestPrice = bestPrice
                            }
                            return updatedInventoryItem
                        }
                    self.state.inventoryItems = updatedInventoryItems
                }
            }
        }
    }

    private func updateInventoryItemsWithItemFields(inventoryItems: [InventoryItem]) {
        environment.dataController.getItems(withIds: inventoryItems.compactMap(\.itemId), settings: state.settings) { [weak self] items in
            guard let self = self else { return }
            let updatedInventoryItems = inventoryItems.map { inventoryItem -> InventoryItem in
                if let item = items.first(where: { $0.id == inventoryItem.itemId }) {
                    var updatedInventoryItem = inventoryItem
                    updatedInventoryItem.itemFields = .init(from: item, size: inventoryItem.size)
                    return updatedInventoryItem
                } else {
                    return inventoryItem
                }
            }
            self.updateCalculatedPrices(inventoryItems: updatedInventoryItems)
        }
    }

    private func updateCalculatedPrices(inventoryItems: [InventoryItem]) {
        let settings = state.settings
        let exchageRates = state.exchangeRates
        let updatedInventoryItems = inventoryItems.map { calculatePrices(inventoryItem: $0, settings: settings, exchangeRates: exchageRates) }
        updateBestPrices(inventoryItems: updatedInventoryItems)
    }

    private func updateBestPrices(inventoryItems: [InventoryItem]) {
        let updatedInventoryItems = inventoryItems.map { inventoryItem in
            var updatedInventoryItem = inventoryItem
//            updatedInventoryItem.bestPrice =
        }
    }

    func setupObservers() {
        environment.dataController.errorsPublisher.merge(with: environment.paymentService.errorsPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.state.error = error
            }
            .store(in: &effectCancellables)

        environment.dataController.userPublisher
            .withPrevious()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] previousUser, newUser in
                      guard let self = self else { return }
                      let oldSettings = self.state.user?.settings
                      let newSettings = newUser.settings
                      if oldSettings?.feeCalculation.country != newSettings?.feeCalculation.country ||
                          oldSettings?.currency != newSettings?.currency ||
                          previousUser?.id != newUser.id {
                          #warning("called on login??")
                          self.environment.dataController.updateUserItems {
                              self.updateInventoryItemsWithItemFields(inventoryItems: self.state.inventoryItems)
                          }
                      } else if oldSettings?.feeCalculation != newSettings?.feeCalculation {
                          self.updateCalculatedPrices(inventoryItems: self.state.inventoryItems)
                      } else if oldSettings?.bestPricePriceType != newSettings?.bestPricePriceType ||
                          oldSettings?.bestPriceFeeType != newSettings?.bestPriceFeeType ||
                          oldSettings?.displayedStores != newSettings?.displayedStores {
                          self.updateBestPrices(inventoryItems: self.state.inventoryItems)
                      }
                      self.state.user = newUser
                  })
            .store(in: &effectCancellables)

        environment.dataController.inventoryItemsPublisher
            .map { inventoryItems in inventoryItems.filter { $0.pendingImport == nil } }
            .withPrevious()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] previousInventoryItems, newInventoryItems in
                      guard let self = self else { return }
                      var inventoryItemsToUpdate: [InventoryItem] = []
                      let updatedNewInventoryItems = newInventoryItems.map { new -> InventoryItem in
                          var newInventoryItem = new
                          guard let previousInventoryItem = previousInventoryItems?.first(where: { $0.id == newInventoryItem.id }),
                                let itemFields = previousInventoryItem.itemFields,
                                previousInventoryItem.size == newInventoryItem.size
                          else {
                              inventoryItemsToUpdate.append(newInventoryItem)
                              return newInventoryItem
                          }
                          newInventoryItem.itemFields = itemFields
                          return newInventoryItem
                      }
                      self.updateInventoryItemsWithItemFields(inventoryItems: inventoryItemsToUpdate)
                      self.state.inventoryItems = updatedNewInventoryItems
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
//        guard state.user != nil else { return }
//        let idsToRefresh = Set(state.inventoryItems.compactMap { (inventoryItem: InventoryItem) -> Ids? in
//            if let itemId = inventoryItem.itemId {
//                return Ids(itemId: itemId, styleId: inventoryItem.styleId)
//            } else {
//                return nil
//            }
//        })
//            .filter { ids in
//                guard !ids.itemId.isEmpty, !ids.styleId.isEmpty else { return false }
//                if let item = ItemCache.default.value(forKey: Item.databaseId(itemId: ids.itemId, settings: newUser?.settings ?? state.settings)) {
//                    return item.storePrices.isEmpty || !item.isUptodate
//                } else {
//                    return true
//                }
//            }
//        var idsWithDelay = idsToRefresh
//            .map { (ids: Ids) in (ids, Double.random(in: 0.2 ... 0.45)) }
//
//        idsWithDelay = idsWithDelay
//            .enumerated()
//            .map { (offset: Int, idWithDelay: (Ids, Double)) in
//                (idWithDelay.0, idWithDelay.1 + (idsWithDelay[safe: offset - 1]?.1 ?? 0))
//            }
//        log("refreshing prices for items with ids: \(idsToRefresh)", logType: .scraping)
        #warning("call refreshPrices for user")
    }
}

private func imageRequest(for imageURL: ImageURL?) -> ImageRequestConvertible? {
    if let imageURL = imageURL, let url = URL(string: imageURL.url) {
        return ImageRequest(urlRequest: URLRequest(url: url))
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
