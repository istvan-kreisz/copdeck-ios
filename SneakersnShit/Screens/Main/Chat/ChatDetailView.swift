//
//  ChatDetailView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/30/21.
//

import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    
    let channel: Channel
    
    var body: some View {
        Text("Hello, World!")
            .onAppear(perform: markAsSeen)
            .onDisappear(perform: markAsSeen)
    }
    
    func markAsSeen() {
        store.send(.main(action: .markChannelAsSeen(channel: channel)))
    }
}
