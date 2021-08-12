//
//  HorizontalPagingViewWithSegmentedControl.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/12/21.
//

import SwiftUI

struct HorizontalPagingViewWithSegmentedControl<V: View>: View {
    @Binding var titles: [String]
    var viewAtIndex: (Int) -> V
    
    @State var selectedIndex = 0

    var body: some View {
        let viewCount = Binding<Int>(get: { titles.count }, set: { _ in })
        VStack {
            ScrollableSegmentedControl(selectedIndex: $selectedIndex, titles: $titles)
            HorizonalPagingView(selectedIndex: $selectedIndex, viewCount: viewCount, viewAtIndex: viewAtIndex)
        }
    }
}

struct HorizontalPagingViewWithSegmentedControl_Previews: PreviewProvider {
    @State static var selectedIndex: Int = 0

    static var previews: some View {
        let titles = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth"]
        HorizontalPagingViewWithSegmentedControl(titles: .constant(titles)) { index in
            Text(titles[index])
        }
    }
}
