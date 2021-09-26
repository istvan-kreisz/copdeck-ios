//
//  ImageService.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/20/21.
//

import Foundation
import Firebase
import Combine
import UIKit
import FirebaseStorage

class DefaultImageService: ImageService {
    private let storage: Storage
    private var userId: String?
    private let imagesQueue = DispatchQueue(label: "profile.images")
    private let imageUploadQueue = DispatchQueue(label: "image.upload", qos: .background)

    private let imageSubject = CurrentValueSubject<URL?, Never>(nil)

    private var profileImageUploadTask: StorageUploadTask?
    private var itemImageUploadTasks: [String: Int] = [:]
    private var uploadedItems: [String] = []
    private let errorsSubject = PassthroughSubject<AppError, Never>()

    private let imageCache = Cache<String, URL>(entryLifetimeMin: 60)

    var profileImagePublisher: AnyPublisher<URL?, Never> {
        imageSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    init() {
        storage = Storage.storage()
    }

    func setup(userId: String) {
        guard userId != self.userId else { return }

        self.userId = userId
        refreshUserProfileImage()
    }

    func reset() {
        userId = nil
    }

    func getImageURLs(for users: [User]) -> AnyPublisher<[User], AppError> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.success(users))
                return
            }
            var usersWithImageURLs: [User] = []
            let dispatchGroup = DispatchGroup()

            for user in users {
                dispatchGroup.enter()
                self.getImage(imageId: user.id, reference: self.profileImageRef(userId: user.id), callbackQueue: self.imagesQueue) { url in
                    usersWithImageURLs.append(user.withImageURL(url))
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                promise(.success(usersWithImageURLs))
            }
        }.eraseToAnyPublisher()
    }

    func getImage(for itemId: String, completion: @escaping (URL?) -> Void) {
        getImage(imageId: itemId, reference: itemImageRef(itemId: itemId), callbackQueue: .main, completion: completion)
    }

    func uploadProfileImage(image: UIImage) {
        guard let data = image.resizeImage(300).jpegData(compressionQuality: 0.4),
              let userId = userId
        else { return }
        let imageRef = profileImageRef(userId: userId)
        profileImageUploadTask?.cancel()

        imageRef.getMetadata { [weak self] meta, error in
            if meta != nil {
                imageRef.delete { [weak self] error in
                    self?.uploadProfileImageData(data)
                }
            } else {
                self?.uploadProfileImageData(data)
            }
        }
    }

    func uploadItemImage(itemId: String, image: UIImage) {
        guard itemImageUploadTasks[itemId] == nil, !itemId.isEmpty else { return }
        itemImageUploadTasks[itemId] = 1
        let imageRef = itemImageRef(itemId: itemId)

        imageRef.getMetadata { [weak self] meta, error in
            guard let self = self, meta == nil else { return }
            self.imageUploadQueue.async { [weak self] in
                guard let data = image.resized(toWidth: 500)?.jpegData(compressionQuality: 0.5) else {
                    DispatchQueue.main.async {
                        self?.itemImageUploadTasks[itemId] = nil
                    }
                    return
                }
                DispatchQueue.main.async {
                    imageRef.putData(data, metadata: nil) { [weak self] metadata, error in
                        if metadata == nil {
                            DispatchQueue.main.async {
                                self?.itemImageUploadTasks[itemId] = nil
                            }
                        }
                    }
                }
            }
        }
    }

    private func refreshUserProfileImage() {
        guard let userId = userId else { return }
        profileImageRef(userId: userId).downloadURL { [weak self] url, error in
            if let error = error {
                log("error downloading image \(error)", logType: .error)
            } else {
                self?.imageSubject.send(url)
            }
        }
    }

    private func profileImageRef(userId: String) -> StorageReference {
        storage.reference().child("images/\(userId)/profilePicture.jpg")
    }

    private func itemImageRef(itemId: String) -> StorageReference {
        storage.reference().child("items/\(Item.idWithoutForwardSlash(itemId: itemId)).jpg")
    }

    private func uploadProfileImageData(_ data: Data) {
        guard let userId = userId else { return }
        profileImageUploadTask = profileImageRef(userId: userId).putData(data, metadata: nil) { [weak self] metadata, error in
            if let error = error {
                self?.errorsSubject.send(AppError(error: error))
            } else {
                self?.refreshUserProfileImage()
            }
        }
    }

    func getInventoryItemImages(userId: String, inventoryItem: InventoryItem, completion: @escaping ([URL]) -> Void) {
        var urls: [URL] = []
        let dispatchGroup = DispatchGroup()

        storage.reference().child("inventoryItems/\(userId)/\(inventoryItem.id)")
            .listAll { result, error in
                guard !result.items.isEmpty else {
                    completion([])
                    return
                }

                result.items.forEach { [weak self] ref in
                    guard let self = self else { return }
                    dispatchGroup.enter()
                    self.getImage(imageId: ref.fullPath, reference: ref, callbackQueue: self.imagesQueue) { url in
                        if let url = url {
                            urls.append(url)
                        }
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    completion(urls)
                }
            }
    }

    func uploadInventoryItemImages(inventoryItem: InventoryItem, images: [UIImage], completion: @escaping ([String]) -> Void) {
        guard let userId = userId, !images.isEmpty else {
            completion([])
            return
        }
        let dispatchGroup = DispatchGroup()
        var imageIds: [String] = []

        images
            .map { image -> (UIImage, String, StorageReference) in
                let imageId = UUID().uuidString
                return (image, imageId, storage.reference().child("inventoryItems/\(userId)/\(inventoryItem.id)/\(imageId)"))
            }
            .forEach { (image: UIImage, imageId: String, ref: StorageReference) in
                dispatchGroup.enter()
                DispatchQueue.global(qos: .background).async {
                    guard let data = image.resized(toWidth: 500)?.jpegData(compressionQuality: 0.5) else {
                        dispatchGroup.leave()
                        return
                    }
                    ref.putData(data, metadata: nil) { metadata, error in
                        guard error == nil else {
                            dispatchGroup.leave()
                            return
                        }
                        DispatchQueue.main.async {
                            imageIds.append(imageId)
                            dispatchGroup.leave()
                        }
                    }
                }
            }
        dispatchGroup.notify(queue: .main) {
            completion(imageIds)
        }
    }

    func deleteInventoryItemImage(imageURL: URL, completion: @escaping (Bool) -> Void) {
        storage.reference(forURL: imageURL.absoluteString).delete { error in
            completion(error == nil)
        }
    }

    func deleteInventoryItemImages(inventoryItem: InventoryItem) {
        guard let userId = userId else { return }
        storage.reference().child("inventoryItems/\(userId)/\(inventoryItem.id)")
            .listAll { result, error in
                guard !result.items.isEmpty else { return }
                result.items.forEach { $0.delete() }
            }
    }

    private func getImage(imageId: String, reference: StorageReference, callbackQueue: DispatchQueue, completion: @escaping (URL?) -> Void) {
        if let cached = imageCache.value(forKey: imageId) {
            log("cache image load - id: \(imageId)", logType: .cache)
            completion(cached)
        } else {
            reference.downloadURL { [weak self] url, error in
                if let url = url {
                    log("storage image load - id: \(imageId)", logType: .cache)
                    self?.imageCache.insert(url, forKey: imageId)
                }
                if let error = error {
                    log("error downloading image \(error)", logType: .error)
                }
                callbackQueue.async {
                    completion(url)
                }
            }
        }
    }
}
