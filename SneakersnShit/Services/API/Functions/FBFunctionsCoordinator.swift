//
//  FBFunctionsCoordinator.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/27/21.
//

import Foundation
import Combine
import FirebaseFunctions

class FBFunctionsCoordinator {
    private let functions = Functions.functions(region: "europe-west1")
    var userId: String?
    var cancellables: Set<AnyCancellable> = []

    let errorsSubject = PassthroughSubject<AppError, Never>()
    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    init() {
        if DebugSettings.shared.isInDebugMode, DebugSettings.shared.useFunctionsEmulator {
            functions.useFunctionsEmulator(origin: "http://\(DebugSettings.shared.ipAddress):5001")
        }
    }

    func setup(userId: String) {
        guard userId != self.userId else { return }
        self.userId = userId
    }

    func reset() {
        self.userId = nil
    }

    func handlePublisherResult<Model>(publisher: AnyPublisher<Model, AppError>, completion: ((Result<Model, AppError>) -> Void)? = nil) {
        publisher
            .sink { [weak self] result in
                switch result {
                case let .failure(error):
                    if let completion = completion {
                        completion(.failure(error))
                    } else {
                        self?.errorsSubject.send(error)
                    }
                case .finished:
                    break
                }
            } receiveValue: { value in completion?(.success(value)) }
            .store(in: &cancellables)
    }

    func callFirebaseFunction(functionName: String, model: Encodable) -> AnyPublisher<Void, AppError> {
        firebaseFunction(functionName: functionName, model: model) { result, completion in
            completion(.success(()))
        }
    }

    func callFirebaseFunction<Model: Decodable>(functionName: String, model: Encodable) -> AnyPublisher<Model, AppError> {
        firebaseFunction(functionName: functionName, model: model) { result, completion in
            let result: Model = try self.decodeResult(result)
            completion(.success(result))
        }
    }

    func callFirebaseFunctionArray<Model: Decodable>(functionName: String, model: Encodable) -> AnyPublisher<[Model], AppError> {
        firebaseFunction(functionName: functionName, model: model) { result, completion in
            let result: [Model] = try self.decodeResultArray(result)
            completion(.success(result))
        }
    }

    private func firebaseFunction<Model>(functionName: String,
                                         model: Encodable,
                                         handleResult: @escaping (HTTPSCallableResult?, (Result<Model, AppError>) -> Void) throws -> Void)
        -> AnyPublisher<Model, AppError> {
        guard let userId = userId else { return Fail(error: AppError.unauthenticated).eraseToAnyPublisher() }
        do {
            var parameters = try model.asDictionary()
            parameters["userId"] = userId
            return Future<Model, AppError> { [weak self] completion in
                self?.functions.httpsCallable(functionName).call(parameters) { [weak self] result, functionError in
                    guard let self = self else { return }
                    do {
                        try self.handleError(functionError)
                        try handleResult(result, completion)
                    } catch {
                        let appError = (error as? AppError) ?? AppError(error: error)
                        completion(.failure(appError))
                    }
                }
            }
            .eraseToAnyPublisher()
        } catch {
            return Fail(error: AppError(error: error)).eraseToAnyPublisher()
        }
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
