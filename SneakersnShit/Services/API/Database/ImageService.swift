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
    private let profileImagesQueue = DispatchQueue(label: "profile.images")

    private let imageSubject = CurrentValueSubject<URL?, Never>(nil)

    private var profileImageUploadTask: StorageUploadTask?
    private var itemImageUploadTasks: [String: StorageUploadTask] = [:]
    private var itemImageUploadTasks2: [String: Int] = [:]
    private let errorsSubject = PassthroughSubject<AppError, Never>()

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
        getUserProfileImage()
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
                self.getImage(at: self.profileImageRef(userId: user.id)) { [weak self] url, error in
                    self?.profileImagesQueue.async {
                        if let error = error {
                            log("error downloading image \(error)", logType: .error)
                            usersWithImageURLs.append(user)
                        } else {
                            var copy = user
                            copy.imageURL = url
                            usersWithImageURLs.append(copy)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                promise(.success(usersWithImageURLs))
            }
        }.eraseToAnyPublisher()
    }

    func getImage(for itemId: String, completion: @escaping (URL?) -> Void) {
        getImage(at: itemImageRef(itemId: itemId)) { url, error in
            completion(url)
        }
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
        guard itemImageUploadTasks[itemId] == nil, itemImageUploadTasks2[itemId] == nil, !itemId.isEmpty else { return }
        itemImageUploadTasks2[itemId] = 1
        let imageRef = itemImageRef(itemId: itemId)

        imageRef.getMetadata { [weak self] meta, error in
            guard meta == nil else {
                self?.itemImageUploadTasks[itemId] = nil
                self?.itemImageUploadTasks2[itemId] = nil
                return
            }
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let data = image.resized(toWidth: 500)?.jpegData(compressionQuality: 0.5) else {
                    self?.itemImageUploadTasks[itemId] = nil
                    self?.itemImageUploadTasks2[itemId] = nil
                    return
                }
                log("uploading image \(itemId)")
                self?.itemImageUploadTasks[itemId] = imageRef.putData(data, metadata: nil) { [weak self] metadata, error in
                    self?.itemImageUploadTasks[itemId] = nil
                    self?.itemImageUploadTasks2[itemId] = nil
                }
            }
        }
    }

    private func getUserProfileImage() {
        guard let userId = userId else { return }
        getImage(at: profileImageRef(userId: userId)) { [weak self] url, error in
            if let error = error {
                log("error downloading image \(error)", logType: .error)
            } else {
                self?.imageSubject.send(url)
            }
        }
    }

    private func getImage(at storageRef: StorageReference?, completion: @escaping (URL?, Error?) -> Void) {
        storageRef?.downloadURL(completion: completion)
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
                self?.getUserProfileImage()
            }
        }
    }

    #warning("fix caching")
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
                    self.getImage(at: ref) { url, error in
                        guard let url = url else {
                            dispatchGroup.leave()
                            return
                        }
                        DispatchQueue.main.async {
                            urls.append(url)
                            dispatchGroup.leave()
                        }
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
}
