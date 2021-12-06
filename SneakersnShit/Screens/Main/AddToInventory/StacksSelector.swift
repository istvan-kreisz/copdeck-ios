//
//  StacksSelector.swift
//  CopDeck
//
//  Created by István Kreisz on 12/6/21.
//

import SwiftUI

struct StacksSelector: View {
    static let padding: CGFloat = 3
    
    let style: NewItemCard.Style
    @Binding var selectedStacks: [Stack]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("add to stack(s)")
                .font(.regular(size: 12))
                .foregroundColor(style == .card ? .customText2 : .customText1)
                .padding(.leading, 5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Color.clear.frame(width: 2)
                    ForEach(AppStore.default.state.stacks) { (stack: Stack) in
                        let isSelected = Binding<Bool>(get: { selectedStacks.map(\.id).contains(stack.id) },
                                                       set: { newValue in
                                                           if newValue {
                                                               if !selectedStacks.map(\.id).contains(stack.id) {
                                                                   selectedStacks.append(stack)
                                                               }
                                                           } else {
                                                               selectedStacks = selectedStacks.filter { $0.id != stack.id }
                                                           }
                                                       })
                        StackSelectorView(title: stack.name, color: .customPurple, isSelected: isSelected)
                    }
                }
                .padding(.vertical, Self.padding)
            }
        }
    }
}
