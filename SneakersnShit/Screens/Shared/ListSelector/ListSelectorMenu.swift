//
//  ListSelectorMenu.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/19/21.
//

import SwiftUI

struct ListSelectorMenu: View {
    let title: String
    let description: String?
    let selectorScreenTitle: String
    let buttonTitle: String
    let options: [String]
    var selectedOptions: Binding<[String]>?
    var selectedOption: Binding<String>?
    var isContentLocked: Bool
    let buttonTapped: () -> Void

    init(title: String,
         description: String? = nil,
         selectorScreenTitle: String,
         buttonTitle: String,
         options: [String],
         selectedOption: Binding<String>,
         isContentLocked: Bool = false,
         buttonTapped: @escaping () -> Void) {
        self.title = title
        self.description = description
        self.selectorScreenTitle = selectorScreenTitle
        self.buttonTitle = buttonTitle
        self.options = options
        self.selectedOptions = nil
        self.selectedOption = selectedOption
        self.isContentLocked = isContentLocked
        self.buttonTapped = buttonTapped
    }

    init(title: String,
         description: String? = nil,
         selectorScreenTitle: String,
         buttonTitle: String,
         options: [String],
         selectedOptions: Binding<[String]>,
         isContentLocked: Bool = false,
         buttonTapped: @escaping () -> Void) {
        self.title = title
        self.description = description
        self.selectorScreenTitle = selectorScreenTitle
        self.buttonTitle = buttonTitle
        self.options = options
        self.selectedOptions = selectedOptions
        self.selectedOption = nil
        self.isContentLocked = isContentLocked
        self.buttonTapped = buttonTapped
    }

    private var formattedSelectedListString: String {
        if let selectedOptions = selectedOptions?.wrappedValue {
            return ListFormatter.localizedString(byJoining: selectedOptions)
        } else {
            return selectedOption?.wrappedValue ?? ""
        }
    }

    var body: some View {
        let _options = selectedOptions ?? Binding<[String]>(get: {
            (selectedOption?.wrappedValue).map { [$0] } ?? []
        }, set: { options in
            options.first.map { self.selectedOption?.wrappedValue = $0 }
        })
        NavigationLink(destination: ListSelector(title: selectorScreenTitle,
                                                 description: description,
                                                 buttonTitle: buttonTitle,
                                                 enableMultipleSelection: selectedOptions != nil,
                                                 popBackOnSelect: true,
                                                 options: options,
                                                 isContentLocked: isContentLocked,
                                                 selectedOptions: _options,
                                                 buttonTapped: buttonTapped).navigationbarHidden()) {
                HStack {
                    Text(title)
                    Spacer()
                    Text(formattedSelectedListString)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                }
        }
    }
}
