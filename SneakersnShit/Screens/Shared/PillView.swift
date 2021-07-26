//
//  PillView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct PillView: View {
    var title: String
    var color: Color

    var body: some View {
        Text(title)
            .padding(.horizontal, 9)
            .font(.semiBold(size: 14))
            .frame(height: 22)
            .foregroundColor(Color.white)
            .background(Capsule().fill(color))
    }
}

struct PillView_Previews: PreviewProvider {
    static var previews: some View {
        return PillView(title: "yooo", color: Color.randomPillColor)
    }
}
