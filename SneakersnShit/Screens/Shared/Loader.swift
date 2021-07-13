//
//  Loader.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/13/21.
//

import Foundation
import Combine

class Loader: ObservableObject {
    @Published var isLoading = false
    var cancellables: Set<AnyCancellable> = []

    private var loaders: [UUID: (Result<Void, AppError>) -> Void] = [:] {
        didSet {
            isLoading = !loaders.isEmpty
        }
    }

    func getLoader() -> (Result<Void, AppError>) -> Void {
        let uuid = UUID()
        let loader: (Result<Void, AppError>) -> Void = { [weak self] result in
            self?.loaders[uuid] = nil
        }
        loaders[uuid] = loader
        return loader
    }
}

