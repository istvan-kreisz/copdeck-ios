//
//  Snackbar.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/27/21.
//

import SwiftUI

struct Snackbar: View {
    @Binding var isShowing: Bool
    private let text: String
    private let actionText: String?
    private let action: (() -> Void)?

    init(isShowing: Binding<Bool>,
         text: String,
         actionText: String? = nil,
         action: (() -> Void)? = nil) {
        self._isShowing = isShowing
        self.text = text
        self.actionText = actionText
        self.action = action
    }

    var body: some View {
        VStack {
            Spacer()
            if isShowing {
                HStack {
                    Text(text)
                        .font(.semiBold(size: 18))
                        .foregroundColor(.customWhite)
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.semiBold(size: 17))
                        .foregroundColor(.customWhite)
                    if let actionText = actionText, let action = action {
                        Text(actionText)
                            .font(.bold(size: 16))
                            .foregroundColor(.customWhite)
                            .onTapGesture {
                                action()
                                withAnimation {
                                    isShowing = false
                                }
                            }
                    }
                }
                .padding()
                .frame(width: UIScreen.screenSize.width - 80, height: 50)
                .background(Color.customGreen)
                .cornerRadius(Styles.cornerRadius)
                .withDefaultShadow()
                .padding(.bottom, UIApplication.shared.safeAreaInsets().bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(Animation.spring())
            }
        }
        .onTapGesture {
            withAnimation {
                isShowing = false
            }
        }
        .simultaneousGesture(DragGesture()
            .onChanged { _ in
                withAnimation {
                    isShowing = false
                }
            })
        .onChange(of: isShowing) { showing in
            guard showing else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}

struct Snackbar_Previews: PreviewProvider {
    static var previews: some View {
        Snackbar(isShowing: .constant(true), text: "")
    }
}
