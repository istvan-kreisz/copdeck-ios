//
//  ListSelector.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/19/21.
//

import SwiftUI

struct ListSelector: View {
    let title: String
    let buttonTitle: String
    let enableMultipleSelection: Bool
    let options: [String]
    @Binding var selectedOptions: [String]
    let buttonTapped: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .foregroundColor(.customText1)
                .font(.bold(size: 35))
                .leftAligned()
                .padding(.leading, 6)
                .padding(.horizontal, 28)
                .withDefaultPadding(padding: .top)

            List {
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
                Color.clear.padding(.bottom, 137)
            }
        }
        .withFloatingButton(button: NextButton(text: buttonTitle,
                                               size: .init(width: 260, height: 60),
                                               color: .customBlack,
                                               tapped: buttonTapped)
                .centeredHorizontally()
                .padding(.top, 20))
        .hideKeyboardOnScroll()
    }
}

struct ListSelector_Previews: PreviewProvider {
    static var previews: some View {
        ListSelector(title: "title",
                     buttonTitle: "buttonTitle",
                     enableMultipleSelection: true,
                     options: ["first", "second", "third"],
                     selectedOptions: .constant(["first", "second"])) { print("hey") }
    }
}
