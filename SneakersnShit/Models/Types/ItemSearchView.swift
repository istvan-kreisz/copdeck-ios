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

    func getSearchResults(searchTerm: String, sendFetchRequest: Bool, loader: @escaping (Result<Void, AppError>) -> Void)
}

extension ItemSearchView {
    func getSearchResults(searchTerm: String, sendFetchRequest: Bool, loader: @escaping (Result<Void, AppError>) -> Void) {
        AppStore.default.send(.main(action: .getSearchResults(searchTerm: searchTerm, sendFetchRequest: sendFetchRequest, completion: { result in
            if searchTerm == self.searchText.wrappedValue {
                handleResult(result: result, loader: nil) { items in
                    if self.searchModel.wrappedValue.state.searchResults.searchTerm == searchTerm {
                        let currentIds = self.searchModel.wrappedValue.state.searchResults.searchResults.map(\.id)
                        let newItems = items.filter { !currentIds.contains($0.id) }
                        if sendFetchRequest {
                            self.searchModel.wrappedValue.state.searchResults.searchResults.insert(contentsOf: newItems, at: 0)
                        } else {
                            self.searchModel.wrappedValue.state.searchResults.searchResults += newItems
                        }
                        loader(.success(()))
                    } else {
                        self.searchModel.wrappedValue.state.searchResults = .init(searchTerm: searchTerm, searchResults: items)
                    }
                }
            }
        })), debounceDelayMs: sendFetchRequest ? 1000 : 300)
    }
    
    func showError(_ appError: AppError) {}

    func searchItems(searchTerm: String) {
        if searchTerm.isEmpty {
            self.searchModel.wrappedValue.state.searchResults = .init(searchTerm: "")
        } else {
            let loader = searchResultsLoader.wrappedValue.getLoader()
            getSearchResults(searchTerm: searchTerm, sendFetchRequest: true, loader: loader)
            getSearchResults(searchTerm: searchTerm, sendFetchRequest: false, loader: loader)
        }
    }
}
