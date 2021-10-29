//
//  AttributedText.swift
//  CopDeck
//
//  Created by István Kreisz on 10/25/21.
//

import SwiftUI

struct AttributedText: UIViewRepresentable {
    var attributedText: NSMutableAttributedString
    var didTapLink: ((URL) -> Void)?

    init(_ attributedText: NSMutableAttributedString, didTapLink: ((URL) -> Void)? = nil) {
        self.attributedText = attributedText
        self.didTapLink = didTapLink
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextViewWithDelegate(didTapLink: didTapLink)
        textView.isEditable = false
        textView.isSelectable = true
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        return textView
    }

    func updateUIView(_ label: UITextView, context: Context) {
        label.attributedText = attributedText
        label.backgroundColor = .clear
        label.sizeToFit()
    }
}

class UITextViewWithDelegate: UITextView, UITextViewDelegate {
    var didTapLink: ((URL) -> Void)?

    init(didTapLink: ((URL) -> Void)?) {
        self.didTapLink = didTapLink
        super.init(frame: .zero, textContainer: nil)
        self.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let didTapLink = didTapLink {
            didTapLink(URL)
            return false
        } else {
            return true
        }
    }
}
