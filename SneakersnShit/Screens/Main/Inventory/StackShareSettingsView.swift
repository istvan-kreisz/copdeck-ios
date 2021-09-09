//
//  StackShareSettingsView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/9/21.
//

import SwiftUI

struct StackShareSettingsView: View {
    private static let popupTitles = ["Publish on Feed", "Make Public"]
    private static let popupDescriptions = ["some text blah blah blah", "some text blah blah blah"]

    let linkURL: String

    @State var stack: Stack
    @State var isPublished: Bool
    @State var isPublic: Bool

    @State private var showSnackBar = false
    @State private var popupIndex: Int? = nil

    var showSnackbar: (_ text: String) -> Void
    var showPopup: (_ title: String, _ subtitle: String) -> Void
    var updateStack: (_ stack: Stack) -> Void

    init(linkURL: String,
         stack: Stack,
         isPublic: Bool,
         isPublished: Bool,
         showSnackbar: @escaping (_ text: String) -> Void,
         showPopup: @escaping (_ title: String, _ subtitle: String) -> Void,
         updateStack: @escaping (_ stack: Stack) -> Void) {
        self.linkURL = linkURL
        self._stack = State(initialValue: stack)
        self._isPublished = State<Bool>(initialValue: isPublished)
        self._isPublic = State<Bool>(initialValue: isPublic)
        self.showSnackbar = showSnackbar
        self.showPopup = showPopup
        self.updateStack = updateStack
    }

    func toggleView(title: String, isOn: Binding<Bool>, didTapButton: @escaping () -> Void) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .lineLimit(1)
                .font(.bold(size: 18))
                .foregroundColor(.customText1)
                .layoutPriority(2)
                .withTellTip(didTap: didTapButton)
        }
    }

    var body: some View {
        let isPublished = Binding<Bool>(get: { self.isPublished }, set: { didTogglePublished(newValue: $0) })
        let isPublic = Binding<Bool>(get: { self.isPublic }, set: { didTogglePublic(newValue: $0) })

        toggleView(title: "Publish on Feed", isOn: isPublished) {
            showPopup(Self.popupTitles[0], Self.popupDescriptions[0])
        }
        .buttonStyle(PlainButtonStyle())

        toggleView(title: "Make Public", isOn: isPublic) {
            showPopup(Self.popupTitles[1], Self.popupDescriptions[1])
        }
        .buttonStyle(PlainButtonStyle())

        VStack(alignment: .leading, spacing: 4) {
            Text("share link")
                .font(.regular(size: 12))
                .foregroundColor(.customText1)
                .padding(.leading, 5)
            ZStack {
                Text(linkURL)
                    .foregroundColor(.customText2)
                    .frame(height: Styles.inputFieldHeight)
                    .padding(.horizontal, 17)
                    .background(Color.customWhite)
                    .cornerRadius(Styles.cornerRadius)
                    .withDefaultShadow()
                Button {
                    copyLinkTapped()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: Styles.cornerRadius)
                            .fill(Color.customGreen)
                            .frame(width: Styles.inputFieldHeight, height: Styles.inputFieldHeight)
                        Image(systemName: "link")
                            .font(.bold(size: 15))
                            .foregroundColor(Color.customWhite)
                    }
                }
                .rightAligned()
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 12)
    }

    func copyLinkTapped() {
        var updatedStack = stack
        UIPasteboard.general.string = linkURL
        showSnackbar("Link Copied")
        updatedStack.isSharedViaLink = true
        updateStack(updatedStack)
    }

    func didTogglePublished(newValue: Bool) {
        var updatedStack = stack
        updatedStack.isPublished = newValue
        isPublished = newValue
        if newValue {
            isPublic = newValue
            updatedStack.isPublic = newValue
        }
        updateStack(updatedStack)
    }

    func didTogglePublic(newValue: Bool) {
        var updatedStack = stack
        updatedStack.isPublic = newValue
        isPublic = newValue
        if !newValue {
            isPublished = newValue
            updatedStack.isPublished = newValue
        }
        updateStack(updatedStack)
    }
}
