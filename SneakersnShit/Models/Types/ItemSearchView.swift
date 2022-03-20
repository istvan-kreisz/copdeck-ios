//
//  ItemSearchView.swift
//  CopDeck
//
//  Created by István Kreisz on 1/14/22.
//

import Foundation
import SwiftUI

protocol ItemSearchView: LoadViewWithAlert {
    var searchText: State<String> { get }
    var searchModel: StateObject<SearchModel> { get }
    var searchResultsLoader: StateObject<Loader> { get }
    func getSearchResults(searchTerm: String,
                          sendFetchRequest: Bool,
                          isExactSearchById: Bool,
                          loader: @escaping (Result<Void, AppError>) -> Void,
                          didFinishLoading: (() -> Void)?)
}

extension ItemSearchView {
    func getSearchResults(searchTerm: String,
                          sendFetchRequest: Bool,
                          isExactSearchById: Bool,
                          loader: @escaping (Result<Void, AppError>) -> Void,
                          didFinishLoading: (() -> Void)? = nil) {
        AppStore.default.send(.main(action: .getSearchResults(searchTerm: searchTerm, sendFetchRequest: sendFetchRequest, completion: { result in
            if searchTerm == self.searchText.wrappedValue {
                handleResult(result: result, loader: nil) { items in
                    if self.searchModel.wrappedValue.state.searchResults.searchTerm == searchTerm {
                        let currentIds = self.searchModel.wrappedValue.state.searchResults.searchResults.map(\.id)
                        let newItems = items.filter {
                            let isAdded = currentIds.contains($0.id)
                            let matchesIdIfNeeded = (isExactSearchById ? $0.id.lowercased() == searchTerm.lowercased() : true)
                            return !isAdded && matchesIdIfNeeded
                        }

                        if sendFetchRequest {
                            self.searchModel.wrappedValue.state.searchResults.searchResults.insert(contentsOf: newItems, at: 0)
                        } else {
                            self.searchModel.wrappedValue.state.searchResults.searchResults += newItems
                        }
                    } else {
                        self.searchModel.wrappedValue.state.searchResults = .init(searchTerm: searchTerm, searchResults: items)
                    }
                    didFinishLoading?()
                    loader(.success(()))
                }
            }
        })), debounceDelayMs: sendFetchRequest ? 1000 : 300)
    }

    func showError(_ appError: AppError) {}

    func searchItems(searchTerm: String, isExactSearchById: Bool = false, didFinishLoading: (() -> Void)? = nil) {
        if searchTerm.isEmpty {
            self.searchModel.wrappedValue.state.searchResults = .init(searchTerm: "")
        } else {
            let loader = searchResultsLoader.wrappedValue.getLoader()
            getSearchResults(searchTerm: searchTerm, sendFetchRequest: true, isExactSearchById: isExactSearchById, loader: loader, didFinishLoading: didFinishLoading)
            getSearchResults(searchTerm: searchTerm, sendFetchRequest: false, isExactSearchById: isExactSearchById, loader: loader, didFinishLoading: didFinishLoading)
        }
    }
}
