//
//  Stores.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation
import Combine
import Nuke
import SwiftUI

typealias AppStore = ReduxStore<AppState, AppAction, World>

extension AppStore {
    static var isChatDetailView = false
    static var conversionFetchCount = 0
    static var lastConfigFetch = 0.0
    static var lastPriceUpdate = 0.0

    static let `default`: AppStore = {
        let appStore = AppStore(state: .init(), reducer: appReducer, environment: World())
        appStore.setup()
        return appStore
    }()

    func setup() {
        setupObservers()
        fetchConfigs()
    }

    private func bestPrice(for inventoryItem: InventoryItem, settings: CopDeckSettings) -> ListingPrice? {
        guard let itemFields = inventoryItem.itemFields else { return nil }
        return Item.bestPrice(forSize: inventoryItem.size,
                              feeType: settings.bestPriceFeeType,
                              priceType: settings.bestPricePriceType,
                              stores: settings.displayedStores,
                              currency: settings.currency,
                              prices: itemFields.storePrices,
                              storeInfos: [])
    }

    func updateUserItems() {
        guard Self.lastPriceUpdate.isOlderThan(minutes: World.Constants.itemPricesRefreshPeriodMin) else { return }
        Self.lastPriceUpdate = Date.serverDate

        Debouncer.debounce(delay: .milliseconds(3000), id: "updateUserItems") { [weak self] in
            self?.environment.dataController.updateUserItems {}
        }
    }

    func updateInventoryItems(associatedWith item: Item) {
        Debouncer.debounce(delay: .milliseconds(500), id: "updateInventoryItems(associatedWith") { [weak self] in
            print(">>>>>>>>>>> 1")
            self?.workerQueue.async { [weak self] in
                guard let self = self else { return }
                let updatedInventoryItems = self.state.inventoryItems
                    .filter { $0.itemId == item.id }
                    .map { inventoryItem -> InventoryItem in
                        var updatedInventoryItem = inventoryItem
                        updatedInventoryItem.itemFields = .init(from: item, size: inventoryItem.size)
                        return updatedInventoryItem
                    }
                self.updateCalculatedPrices(inventoryItems: updatedInventoryItems)
            }
        }
    }

    private func updateInventoryItemsWithItemFields(inventoryItems: [InventoryItem]) {
        Debouncer.debounce(delay: .milliseconds(500), id: "updateInventoryItemsWithItemFields(inventoryItems") { [weak self] in
            print(">>>>>>>>>>> 2")
            self?.workerQueue.async { [weak self] in
                guard let self = self else { return }
                self.environment.dataController.getItems(withIds: inventoryItems.compactMap(\.itemId), settings: self.state.settings) { [weak self] items in
                    guard let self = self else { return }
                    let updatedInventoryItems = inventoryItems.map { inventoryItem -> InventoryItem in
                        if let item = items.first(where: { $0.id == inventoryItem.itemId }) {
                            var updatedInventoryItem = inventoryItem
                            updatedInventoryItem.itemFields = .init(from: item, size: inventoryItem.size)
                            return updatedInventoryItem
                        } else {
                            var updatedInventoryItem = inventoryItem
                            updatedInventoryItem.itemFields = nil
                            updatedInventoryItem.bestPrice = nil
                            return updatedInventoryItem
                        }
                    }
                    self.updateCalculatedPrices(inventoryItems: updatedInventoryItems)
                }
            }
        }
    }

    private func updateCalculatedPrices(inventoryItems: [InventoryItem]) {
        Debouncer.debounce(delay: .milliseconds(500), id: "updateCalculatedPrices(inventoryItems") { [weak self] in
            print(">>>>>>>>>>> 3")
            self?.workerQueue.async { [weak self] in
                guard let self = self else { return }
                self.updateBestPrices(inventoryItems: inventoryItems.map { withCalculatedPrices(inventoryItem: $0) })
            }
        }
    }

    private func updateBestPrices(inventoryItems: [InventoryItem]) {
        Debouncer.debounce(delay: .milliseconds(500), id: "updateBestPrices(inventoryItems") { [weak self] in
            print(">>>>>>>>>>> 4")
            self?.workerQueue.async { [weak self] in
                guard let self = self else { return }
                let settings = self.state.settings
                let updatedInventoryItems = inventoryItems.map { inventoryItem -> InventoryItem in
                    var updatedInventoryItem = inventoryItem
                    let bestPrice = self.bestPrice(for: inventoryItem, settings: settings)
                    updatedInventoryItem.bestPrice = bestPrice?.price.price == 0 ? nil : bestPrice
                    return updatedInventoryItem
                }
                let updatedInventoryItemIds = updatedInventoryItems.map(\.id)

                onMain { [weak self] in
                    guard let self = self else { return }
                    self.state.inventoryItems = self.state.inventoryItems.filter { !updatedInventoryItemIds.contains($0.id) } + updatedInventoryItems
                }
            }
        }
    }

    func setupObservers() {
        environment.dataController.canViewPricesPublisher
            .map { $0 || !isContentLocked }
            .removeDuplicates()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] canViewPrices in
                      self?.state.globalState.canViewPrices = canViewPrices
                  })
            .store(in: &effectCancellables)

        environment.dataController.errorsPublisher.merge(with: environment.paymentService.errorsPublisher)
            .sink { [weak self] error in
                self?.state.error = error
            }
            .store(in: &effectCancellables)

        environment.dataController.userPublisher
            .withPrevious()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] previousUser, newUser in
                      guard let self = self else { return }
                      let oldSettings = self.state.user?.settings
                      let newSettings = newUser.settings
                      if oldSettings?.feeCalculation.country != newSettings?.feeCalculation.country ||
                          oldSettings?.currency != newSettings?.currency ||
                          previousUser?.id != newUser.id ||
                          (newUser.subscription == .pro && previousUser?.subscription != .pro) {
                          self.updateInventoryItemsWithItemFields(inventoryItems: self.state.inventoryItems)
                          self.updateUserItems()
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
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] newInventoryItems in
                      guard let self = self else { return }
                      var inventoryItemsToUpdate: [InventoryItem] = []
                      let updatedNewInventoryItems = newInventoryItems.map { new -> InventoryItem in
                          var newInventoryItem = new
                          if isContentLocked {
                              guard let previousInventoryItem = self.state.inventoryItems.first(where: { $0.id == newInventoryItem.id }),
                                    let itemFields = previousInventoryItem.itemFields
                              else {
                                  if !(newInventoryItem.itemId ?? "").isEmpty {
                                      inventoryItemsToUpdate.append(newInventoryItem)
                                  }
                                  return newInventoryItem
                              }
                              newInventoryItem.itemFields = itemFields
                              return newInventoryItem
                          } else {
                              guard let previousInventoryItem = self.state.inventoryItems.first(where: { $0.id == newInventoryItem.id }),
                                    let itemFields = previousInventoryItem.itemFields,
                                    let bestPrice = previousInventoryItem.bestPrice,
                                    previousInventoryItem.size == newInventoryItem.size,
                                    previousInventoryItem.updateTrigger == newInventoryItem.updateTrigger
                              else {
                                  if !(newInventoryItem.itemId ?? "").isEmpty {
                                      inventoryItemsToUpdate.append(newInventoryItem)
                                  }
                                  return newInventoryItem
                              }
                              newInventoryItem.itemFields = itemFields
                              newInventoryItem.bestPrice = bestPrice
                              return newInventoryItem
                          }
                      }
                      self.state.inventoryItems = updatedNewInventoryItems
                      self.updateInventoryItemsWithItemFields(inventoryItems: inventoryItemsToUpdate)
                  })
            .store(in: &effectCancellables)

        environment.dataController.stacksPublisher
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] stacks in
                      self?.state.stacks = [.allStack] + stacks
                  })
            .store(in: &effectCancellables)

        environment.dataController.recentlyViewedPublisher
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in
                      self?.state.recentlyViewedItems = $0
                  })
            .store(in: &effectCancellables)

        environment.dataController.favoritesPublisher
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] favorites in
                      self?.state.favoritedItems = favorites
                  })
            .store(in: &effectCancellables)

        environment.dataController.profileImagePublisher
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] url in
                      self?.state.profileImageURL = url
                  })
            .store(in: &effectCancellables)

        environment.paymentService.packagesPublisher
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] packages in
                      self?.state.allPackages = packages
                  })
            .store(in: &effectCancellables)

        environment.dataController.chatUpdatesPublisher
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] chatUpdateInfo in
                      self?.state.globalState.chatUpdates = chatUpdateInfo
                  })
            .store(in: &effectCancellables)
    }

    func applicationWillEnterForeground() {
        fetchConfigs()
        updateUserItems()
    }

    private func fetchConfigs() {
        guard Self.lastConfigFetch.isOlderThan(minutes: 5) else { return }
        Self.lastConfigFetch = Date.serverDate

        environment.dataController.getSizeConversions { sizeConversions in
            sizeCharts = sizeConversions
        }

        environment.dataController.getExchangeRates { [weak self] exchangeRates in
            self?.state.exchangeRates = exchangeRates
        }

        environment.dataController.getRemoteConfig { [weak self] remoteConfig in
            self?.state.globalState.remoteConfig = remoteConfig
        }
    }
}

private func imageRequest(for imageURL: ImageURL?) -> ImageRequestConvertible? {
    if let imageURL = imageURL, let url = URL(string: imageURL.url) {
        if DefaultImageService.failedFetchURLs.contains(url.absoluteString) {
            return nil
        } else {
            return ImageRequest(urlRequest: URLRequest(url: url))
        }
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

func onMain(block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}
