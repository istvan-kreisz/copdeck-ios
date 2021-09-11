//
//  StackShareSettingsView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/9/21.
//

import SwiftUI

struct StackShareSettingsView: View {
    private static let popupTitles = ["Publish on Feed",
                                      "Make public",
                                      "Share via Link"]
    private static let popupDescriptions =
        ["Publish your stack on the CopDeck feed. This will make your stack public so other users can see your items. They will also be able to visit your profile from the Feed and Search tabs.",
         "Make your stack public so other users can see your items when they visit your profile. Note: making it public won't publish it on the CopDeck feed, you have to enable that separately.",
         "Share your stack via a link. Note: the link will open a webpage so anyone can view your stack even if they don't have the CopDeck app."]

    let linkURL: String

    @State var stack: Stack
    @State var isPublic: Bool
    @State var isPublished: Bool

    let includeTitle: Bool

    @State private var showSnackBar = false
    @State private var popupIndex: Int? = nil

    var showSnackbar: (_ text: String) -> Void
    var showPopup: (_ title: String, _ subtitle: String) -> Void
    var updateStack: (_ stack: Stack) -> Void

    init(linkURL: String,
         stack: Stack,
         isPublic: Bool,
         isPublished: Bool,
         includeTitle: Bool,
         showSnackbar: @escaping (_ text: String) -> Void,
         showPopup: @escaping (_ title: String, _ subtitle: String) -> Void,
         updateStack: @escaping (_ stack: Stack) -> Void) {
        self.linkURL = linkURL
        self._stack = State(initialValue: stack)
        self._isPublic = State<Bool>(initialValue: isPublic)
        self._isPublished = State<Bool>(initialValue: isPublished)
        self.includeTitle = includeTitle
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

        VStack(alignment: .leading, spacing: 12) {
            if includeTitle {
                Text("Share stack:".uppercased())
                    .font(.bold(size: 12))
                    .foregroundColor(.customText2)
                    .leftAligned()
            }

            toggleView(title: "Publish on Feed", isOn: isPublished) {
                showPopup(Self.popupTitles[0], Self.popupDescriptions[0])
            }

            toggleView(title: "Make Public", isOn: isPublic) {
                showPopup(Self.popupTitles[1], Self.popupDescriptions[1])
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Share via Link")
                    .font(.bold(size: 18))
                    .foregroundColor(.customText1)
//                .padding(.leading, 5)
                    .withTellTip {
                        showPopup(Self.popupTitles[2], Self.popupDescriptions[2])
                    }
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
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 8)
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
