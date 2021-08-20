//
//  ListSelectorMenu.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/19/21.
//

import SwiftUI

struct ListSelectorMenu: View {
    let title: String
    let selectorScreenTitle: String
    let buttonTitle: String
    let enableMultipleSelection: Bool
    let options: [String]
    var selectedOptions: Binding<[String]>?
    var selectedOption: Binding<String>?
    let buttonTapped: () -> Void

    init(title: String,
         selectorScreenTitle: String,
         buttonTitle: String,
         enableMultipleSelection: Bool,
         options: [String],
         selectedOption: Binding<String>,
         buttonTapped: @escaping () -> Void) {
        self.title = title
        self.selectorScreenTitle = selectorScreenTitle
        self.buttonTitle = buttonTitle
        self.enableMultipleSelection = enableMultipleSelection
        self.options = options
        self.selectedOptions = nil
        self.selectedOption = selectedOption
        self.buttonTapped = buttonTapped
    }

    init(title: String,
         selectorScreenTitle: String,
         buttonTitle: String,
         enableMultipleSelection: Bool,
         options: [String],
         selectedOptions: Binding<[String]>,
         buttonTapped: @escaping () -> Void) {
        self.title = title
        self.selectorScreenTitle = selectorScreenTitle
        self.buttonTitle = buttonTitle
        self.enableMultipleSelection = enableMultipleSelection
        self.options = options
        self.selectedOptions = selectedOptions
        self.selectedOption = nil
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
                                                 buttonTitle: buttonTitle,
                                                 enableMultipleSelection: enableMultipleSelection,
                                                 popBackOnSelect: true,
                                                 options: options,
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
