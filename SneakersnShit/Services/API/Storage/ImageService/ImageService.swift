//
//  ImageService.swift
//  CopDeck
//
//  Created by István Kreisz on 11/4/21.
//

import Combine
import UIKit

protocol ImageService {
    var errorsPublisher: AnyPublisher<AppError, Never> { get }

    var profileImagePublisher: AnyPublisher<URL?, Never> { get }

    func getImageURLs(for users: [User]) -> AnyPublisher<[User], AppError>
    func getImageURLs(for users: [User], completion: @escaping ([User]) -> Void)
    func uploadProfileImage(image: UIImage)
    func setup(userId: String)
    func reset()
    func getImage(for itemId: String, completion: @escaping (URL?) -> Void)
    func uploadItemImage(itemId: String, image: UIImage)

    func getInventoryItemImages(userId: String, inventoryItem: InventoryItem, completion: @escaping ([URL]) -> Void)
    func uploadInventoryItemImages(inventoryItem: InventoryItem, images: [UIImage], completion: @escaping ([String]) -> Void)
    func deleteInventoryItemImage(imageURL: URL, completion: @escaping (Bool) -> Void)
    func deleteInventoryItemImages(inventoryItem: InventoryItem)
}
