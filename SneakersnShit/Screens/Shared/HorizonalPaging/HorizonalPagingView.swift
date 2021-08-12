//
//  HorizonalPagingView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/12/21.
//

import SwiftUI

struct HorizonalPagingView<V: View>: View {
    @Binding var selectedIndex: Int
    @Binding var viewCount: Int
    var viewAtIndex: (Int) -> V

    var body: some View {
        ScrollView {
            LazyHStack {
                TabView(selection: $selectedIndex) {
                    ForEach(0 ..< viewCount) { index in
                        viewAtIndex(index)
                            .tag(index)
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: 300)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
    }
}

struct HorizonalPagingView_Previews: PreviewProvider {
    @State static var selectedIndex: Int = 0

    static var previews: some View {
        HorizonalPagingView(selectedIndex: $selectedIndex, viewCount: .constant(3)) { index in
            Text("\(index)")
        }
    }
}
