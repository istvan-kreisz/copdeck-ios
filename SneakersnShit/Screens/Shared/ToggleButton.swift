//
//  ToggleButton.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/22/21.
//

import Foundation
import SwiftUI

struct ToggleButton: View {
    var title: String
    @Binding var selection: String
    var options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.regular(size: 12))
                .foregroundColor(.customText1)
                .padding(.leading, 5)

            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                        .font(.bold(size: 12))
                        .frame(width: 71, height: 31)
                        .if(option == selection) {
                            $0
                                .foregroundColor(Color.white)
                                .background(Capsule().fill(Color.customBlue))
                        } else: {
                            $0
                                .foregroundColor(Color.customText1)
                                .background(Capsule().stroke(Color.customAccent1, lineWidth: 2))
                        }
                        .onTapGesture {
                            selection = option
                        }
                }
            }
        }
    }
}

struct ToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        ToggleButton(title: "test", selection: .constant("yo"), options: ["yo", "hey", "sup"])
    }
}
