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
    @Binding var selectedOptions: [String]
    let buttonTapped: () -> Void

    private var formattedSelectedListString: String {
        ListFormatter.localizedString(byJoining: selectedOptions)
    }

    var body: some View {
        NavigationLink(destination: ListSelector(title: selectorScreenTitle,
                                                 buttonTitle: buttonTitle,
                                                 enableMultipleSelection: enableMultipleSelection,
                                                 options: options,
                                                 selectedOptions: $selectedOptions,
                                                 buttonTapped: buttonTapped)) {
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
