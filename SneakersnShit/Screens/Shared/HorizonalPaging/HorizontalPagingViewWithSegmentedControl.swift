//
//  HorizontalPagingViewWithSegmentedControl.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/12/21.
//

import SwiftUI

struct HorizontalPagingViewWithSegmentedControl: View {
    @State var selectedIndex = 0
    let titles = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth"]

    var body: some View {
        VStack {
            ScrollableSegmentedControl(selectedIndex: $selectedIndex, titles: titles)
            HorizonalPagingView(selectedIndex: $selectedIndex, viewCount: .constant(titles.count)) { index in
                Text(titles[index])
                    .frame(width: 200, height: 100)
            }
        }
    }
}

struct HorizontalPagingViewWithSegmentedControl_Previews: PreviewProvider {
    @State static var selectedIndex: Int = 0

    static var previews: some View {
        HorizontalPagingViewWithSegmentedControl()
    }
}
