//
//  Message.swift
//  CopDeck
//
//  Created by István Kreisz on 10/3/21.
//

import UIKit
import MessageKit

// struct ImageMediaItem: MediaItem {
//    var url: URL?
//    var image: UIImage?
//    var placeholderImage: UIImage
//    var size: CGSize
//
//    init(image: UIImage) {
//        self.image = image
//        self.size = CGSize(width: 240, height: 240)
//        self.placeholderImage = UIImage()
//    }
// }

struct Message: MessageType, Codable, Identifiable {
    let id: String
    let author: Sender
    let content: String
    let dateSent: Double
    
    var sender: SenderType { author }
    var kind: MessageKind { .text(content) }
    var messageId: String { id }
    var sentDate: Date { dateSent.serverDate }
    
//    var image: UIImage?
//    var downloadURL: URL?

//    var kind: MessageKind {
//        if let image = image {
//            let mediaItem = ImageMediaItem(image: image)
//            return .photo(mediaItem)
//        } else {
//            return .text(content)
//        }
//    }

//    init(user: User, image: UIImage) {
//        sender = Sender(senderId: user.uid, displayName: AppSettings.displayName)
//        self.image = image
//        content = ""
//        sentDate = Date()
//        id = nil
//    }
}

extension Message {
    init(user: User, content: String) {
        self.init(author: .init(user: user), content: content)
    }

    init(author: Sender, content: String) {
        self.id = UUID().uuidString
        self.author = author
        self.content = content
        self.dateSent = Date.serverDate
    }
}

extension Message: Comparable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
