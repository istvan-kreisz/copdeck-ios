////
////  DatabaseManager.swift
////  SneakersnShit
////
////  Created by István Kreisz on 7/19/21.
////
//
//import Foundation
//import Combine
//
//protocol DatabaseManagerDelegate: AnyObject {
//    func updatedItems(newItems: [Item])
//}
//
//protocol DatabaseManager {
//    // init
//    func setup(userId: String)
//
//    // write
//    func addToInventory(item: Item)
//    func deleteFromInventory(item: Item)
//    func updateSettings(settings: Settings)
//
//    // read
//    func listenToListChanges(userId: String, updated: @escaping ([TodoList]) -> Void)
//    func stopListening()
//}
