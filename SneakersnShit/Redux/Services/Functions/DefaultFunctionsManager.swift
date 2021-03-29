//
//  DefaultFunctionsManager.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import FirebaseFunctions

class DefaultFunctionsManager: FunctionsManager {
    func search(userId: String, searchTerm: String) -> AnyPublisher<[Item], AppError> {
        callFirebaseFunctionArray(functionName: "search", userId: userId, parameters: ["searchTerm": searchTerm])
    }

    private let functions = Functions.functions()

    init() {
        #if DEBUG
            if DebugSettings.shared.useFunctionsEmulator {
                functions.useEmulator(withHost: "http://istvans-macbook-pro-2.local", port: 5001)
            }
        #endif
    }

    private func callFirebaseFunction(functionName: String,
                                      userId: String,
                                      parameters: [String: Any] = [:]) -> AnyPublisher<Void, AppError> {
        Future<Void, AppError> { [weak self] completion in
            self?.functions.httpsCallable(functionName).call(parameters.merging(["userId": userId]) { $1 }) { [weak self] result, error in
                guard let self = self else { return }
                do {
                    try self.handleError(error)
                    completion(.success(()))
                } catch {
                    let error = (error as? AppError) ?? AppError()
                    completion(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func callFirebaseFunction<Model: Decodable>(functionName: String,
                                                        userId: String,
                                                        parameters: [String: Any] = [:]) -> AnyPublisher<Model, AppError> {
        Future<Model, AppError> { [weak self] completion in
            self?.functions.httpsCallable(functionName).call(parameters.merging(["userId": userId]) { $1 }) { [weak self] result, error in
                guard let self = self else { return }
                do {
                    try self.handleError(error)
                    let result: Model = try self.decodeResult(result)
                    completion(.success(result))
                } catch {
                    let error = (error as? AppError) ?? AppError()
                    print(error)
                    completion(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func callFirebaseFunctionArray<Model: Decodable>(functionName: String,
                                                             userId: String,
                                                             parameters: [String: Any] = [:]) -> AnyPublisher<[Model], AppError> {
        Future<[Model], AppError> { [weak self] completion in
            self?.functions.httpsCallable(functionName).call(parameters.merging(["userId": userId]) { $1 }) { [weak self] result, error in
                guard let self = self else { return }
                do {
                    try self.handleError(error)
                    let result: [Model] = try self.decodeResultArray(result)
                    completion(.success(result))
                } catch {
                    let error = (error as? AppError) ?? AppError()
                    print(error)
                    completion(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func decodeResult<Model: Decodable>(_ result: HTTPSCallableResult?) throws -> Model {
        if let result = result?.data as? [String: Any] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                return try JSONDecoder().decode(Model.self, from: jsonData)
            } catch {
                throw AppError(title: "Network Error", message: "Data decoding failed", error: error)
            }
        } else {
            throw AppError(title: "Network Error", message: "Data decoding failed")
        }
    }

    private func decodeResultArray<Model: Decodable>(_ result: HTTPSCallableResult?) throws -> [Model] {
        if let result = result?.data as? [Any] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                return try JSONDecoder().decode([Model].self, from: jsonData)
            } catch {
                throw AppError(title: "Network Error", message: "Data decoding failed", error: error)
            }
        } else {
            throw AppError(title: "Network Error", message: "Data decoding failed")
        }
    }

    private func handleError(_ error: Error?) throws {
        if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
                let message = error.localizedDescription
                throw AppError(message: message, error: error)
            } else {
                throw AppError(title: "Network Error", message: error.localizedDescription, error: error)
            }
        }
    }
}
