//
//  ListSelector.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/19/21.
//

import SwiftUI

struct ListSelector: View {
    @Environment(\.presentationMode) var presentationMode

    let title: String
    var description: String?
    let buttonTitle: String
    let enableMultipleSelection: Bool
    let popBackOnSelect: Bool
    let options: [String]
    @Binding var selectedOptions: [String]
    let buttonTapped: () -> Void

    var body: some View {
        SettingMenu(title: title, description: description, buttonTitle: buttonTitle, popBackOnSelect: popBackOnSelect, buttonTapped: buttonTapped) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if enableMultipleSelection {
                        if let index = selectedOptions.firstIndex(of: option) {
                            selectedOptions.remove(at: index)
                        } else {
                            selectedOptions.append(option)
                        }
                    } else {
                        selectedOptions = [option]
                    }
                }) {
                        HStack {
                            Text(option)
                            Spacer()
                            if selectedOptions.contains(option) {
                                ZStack {
                                    Circle()
                                        .fill(Color.customBlue)
                                        .frame(width: 25, height: 25)
                                    Image(systemName: "checkmark")
                                        .font(.bold(size: 12))
                                        .foregroundColor(.customWhite)
                                }
                            }
                        }
                }
            }
        }
    }
}
