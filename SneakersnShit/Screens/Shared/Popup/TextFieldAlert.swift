//
//  TextFieldAlert.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import SwiftUI
import UIKit

struct Popup<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    @Binding var text: String
    let presenting: Presenting
    let title: String
    let didTapOkay: (String) -> Void

    var body: some View {
        ZStack {
            presenting
                .disabled(isShowing)
            VStack {
                Text(title)
                TextField("", text: $text)
                Divider()
                HStack {
                    Button(action: {
                        withAnimation {
                            isShowing.toggle()
                        }
                    }) {
                            Text("Dismiss")
                    }
                    Button(action: {
                        didTapOkay(text)
                        withAnimation {
                            isShowing.toggle()
                        }
                    }) {
                            Text("Add Stack")
                    }
                }
            }
            .padding()
            .background(Color.white)
            .shadow(radius: 12)
            .opacity(isShowing ? 1 : 0)
        }
    }
}
