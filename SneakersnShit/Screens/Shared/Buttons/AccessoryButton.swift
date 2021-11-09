//
//  AccessoryButton.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct AccessoryButton: View {
    let title: String
    var shouldCapitalizeTitle = false
    let color: Color
    let textColor: Color
    var borderColor: Color?
    var fontSize: CGFloat = 12
    var height: CGFloat = 27
    let width: CGFloat?
    var padding: CGFloat = 10
    var accessoryViewSize: CGFloat = 18
    let imageName: String
    var buttonPosition: RoundedButtonPosition = .left
    var isContentLocked = false
    let tapped: () -> Void

    var body: some View {
        if isContentLocked {
            RoundedButton(text: title,
                          shouldCapitalizeTitle: shouldCapitalizeTitle,
                          width: width,
                          height: height,
                          fontSize: fontSize,
                          color: .clear,
                          borderColor: borderColor ?? color.opacity(0.4),
                          textColor: textColor,
                          padding: padding,
                          accessoryView: (Image(systemName: "lock.fill")
                              .font(.bold(size: 15))
                              .foregroundColor(textColor),
                              buttonPosition, 6, .none)) {
                AppStore.default.send(.paymentAction(action: .showPaymentView(show: true)))
            }
        } else {
            RoundedButton(text: title,
                          shouldCapitalizeTitle: shouldCapitalizeTitle,
                          width: width,
                          height: height,
                          fontSize: fontSize,
                          color: .clear,
                          borderColor: borderColor ?? color.opacity(0.4),
                          textColor: textColor,
                          padding: padding,
                          accessoryView: (ZStack {
                              Circle()
                                  .fill(color.opacity(0.2))
                                  .frame(width: accessoryViewSize, height: accessoryViewSize)
                              Image(systemName: imageName)
                                  .font(.bold(size: 7))
                                  .foregroundColor(color)
                          }.frame(width: accessoryViewSize, height: accessoryViewSize),
                          buttonPosition, 6, .none)) {
                tapped()
            }
        }
    }
}
