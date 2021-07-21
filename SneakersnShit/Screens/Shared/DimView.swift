//
//  DimView.swift
//  CopDeck
//
//  Created by István Kreisz on 4/5/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import SwiftUI

struct DimView: View {
    var body: some View {
        Color.black
            .animation(nil)
            .opacity(0.22)
            .edgesIgnoringSafeArea(.all)
    }
}

struct DimView_Previews: PreviewProvider {
    static var previews: some View {
        DimView()
    }
}
