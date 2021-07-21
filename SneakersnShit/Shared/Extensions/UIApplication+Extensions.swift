//
//  UIApplication+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func safeAreaInsets() -> (top: CGFloat, bottom: CGFloat) {
        var top: CGFloat = 0
        var bottom: CGFloat = 0
        
        guard let window = UIApplication.shared.windows.first else { return (0, 0) }
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        top = safeFrame.minY
        bottom = window.frame.maxY - safeFrame.maxY
        return (top, bottom)
    }
}

