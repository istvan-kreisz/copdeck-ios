//
//  FirebaseWriteService.swift
//  ToDo
//
//  Created by István Kreisz on 4/7/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//


import Foundation
import Firebase

class FirebaseService: DatabaseManager {

    let firestore = Firestore.firestore()
    var userRef: DocumentReference?
    var listener: ListenerRegistration?

    private weak var delegate: DatabaseManagerDelegate?

    func setup(userId: String, delegate: DatabaseManagerDelegate?) {
        self.delegate = delegate
        userRef = firestore.collection("users").document(userId)
        listenToChanges(userId: userId)
    }

    func listenToChanges(userId: String) {
        listener = userRef?.collection("inventory")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }

//                let lists = documents.compactMap {
//                    Item($0)
////                    TodoList(from: $0.data())
//                }
//                updated(lists)
        }
    }

    func stopListening() {
        listener?.remove()
    }

    func addToInventory(item: Item) {}
    func deleteFromInventory(item: Item) {}
    func updateSettings(settings: CopDeckSettings) {}

}

////    func addTodo(with text: String, priority: Priority, toList list: TodoList) {
////        let todo = Todo(text: text,
////                        priority: priority,
////                        isChecked: false)
////
////        var updatedList = list
////        updatedList.todos.append(todo)
////
////        updateTodos(on: updatedList)
////    }
////
////    func update(todo: Todo, list: TodoList, newText: String?, newPriority: Priority?, isChecked: Bool?) {
////        var updatedTodo = todo
////
////        if let newText = newText {
////            updatedTodo.text = newText
////        }
////        if let newPriority = newPriority {
////            updatedTodo.priority = newPriority
////        }
////        if let isChecked = isChecked {
////            updatedTodo.isChecked = isChecked
////        }
////
////        var updatedList = list
////        updatedList.todos.removeAll(where: { $0.id == todo.id })
////        updatedList.todos.append(updatedTodo)
////
////        updateTodos(on: updatedList)
////    }
////
////    func remove(todo: Todo, list: TodoList) {
////        var updatedList = list
////        updatedList.todos.removeAll(where: { $0.id == todo.id })
////
////        updateTodos(on: updatedList)
////    }
////
////    func addList(with name: String) {
////        let todoList = TodoList(name: name, todos: [])
////        listRef?
////            .document(todoList.id)
////            .setData(todoList.data) { [weak self] in self?.handleResult($0) }
////    }
////
////    func removeList(with id: String) {
////        listRef?
////            .document(id)
////            .delete() { [weak self] in self?.handleResult($0) }
////    }
////
////    private func updateTodos(on list: TodoList) {
////        listRef?
////            .document(list.id)
////            .updateData(list.todosData) { [weak self] in self?.handleResult($0) }
////    }
////
////    private func createUnassignedList() {
////        let todoList = TodoList.unassigned
////        listRef?
////            .document(todoList.id)
////            .setData(todoList.data) { [weak self] error in
////                self?.handleResult(error)
////                if error != nil {
////                    self?.createUnassignedList()
////                }
////        }
////    }
////
////    private func handleResult(_ error: Error?) {
////        if let error = error {
////            print("nah dude")
////            print(error)
////        } else {
////            print("success")
////        }
////    }
//}
