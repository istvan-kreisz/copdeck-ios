//
//  InfoPopupView.swift
//  ToDo
//
//  Created by István Kreisz on 4/13/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import SwiftUI

struct InfoPopupView: View {
        
    @Binding var isPresented: Bool
    
    let text1: String
    let text2: String
            
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            HStack {
                Spacer()
                Image(systemName: "lightbulb")
                    .font(.bold(size: 30))
                    .foregroundColor(.customYellow)
                Text("Tips")
                    .font(.bold(size: 30))
                Spacer()
            }
            .padding(.bottom, 10)
            Text(text1)
                .font(.bold(size: 17))
                .multilineTextAlignment(.center)
            
            Text(text2)
                .font(.bold(size: 17))
                .foregroundColor(.customRed)
                .multilineTextAlignment(.center)
            
            Button(action: {
                self.isPresented = false
            }) {
                Text("Got it!")
                    .font(.bold(size: 30))
                    .foregroundColor(.customGreen)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 30)
        .frame(width: 270, height: 290)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .modifier(DefaultShadow())
        .offset(x: 0, y: isPresented ? 0 : UIScreen.screenHeight + 165)
        .animation(Animation.spring())
    }
}

extension InfoPopupView {
    static func mainView(isPresented: Binding<Bool>) -> InfoPopupView {
        InfoPopupView(isPresented: isPresented,
                      text1: "The top 3 lists contain all your todos sorted by priority",
                      text2: "Swipe left on a list to delete it")
    }
    
    static func listView(isPresented: Binding<Bool>) -> InfoPopupView {
        InfoPopupView(isPresented: isPresented,
                      text1: "Swipe right on a todo to mark it as completed",
                      text2: "Swipe left on a todo to delete it")
    }
}

struct InfoPopupView_Previews: PreviewProvider {
    static var previews: some View {
        InfoPopupView.mainView(isPresented: .constant(true))
    }
}
