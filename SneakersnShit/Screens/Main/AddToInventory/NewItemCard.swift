//
//  NewItemCard.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/21/21.
//

import SwiftUI

struct NewItemCard: View {
    @State private var selectedStrength = "asdasdasdsdsasdasdasdsds"
    let strengths = ["Mild", "Medium", "Mature", "asdasdasdsdsasdasdasdsds", "Medium", "Mature", "Mild", "Medium", "Mature", "Mild", "Medium", "Mature", "Mild", "Medium", "Mature",
                     "Mild", "Medium", "Mature", "Mild", "Medium", "Mature"]

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack(alignment: .top, spacing: 10) {
                        TextFieldRounded(title: "purchase price",
                                         placeHolder: "yoooo",
                                         backgroundColor: .customAccent4,
                                         text: .constant("name"))
                        DropDownMenu(title: "hey", selectedItem: .constant("yo"), options: ["yo"])
                        DropDownMenu(title: "hey", selectedItem: .constant("yo"), options: ["yo"])
                    }
                }
            }
            .navigationTitle("Select your cheese")
        }
    }
}

struct NewItemCard_Previews: PreviewProvider {
    static var previews: some View {
        NewItemCard()
    }
}
