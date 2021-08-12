//
//  ScrollableSegmentedControl.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/12/21.
//

import SwiftUI

struct ScrollableSegmentedControl: View {
    @Binding private var selectedIndex: Int

    @State private var frames: [CGRect]
    @State private var backgroundFrame = CGRect.zero
    @State private var isScrollable = true

    private let titles: [String]

    init(selectedIndex: Binding<Int>, titles: [String]) {
        self._selectedIndex = selectedIndex
        self.titles = titles
        frames = [CGRect](repeating: .zero, count: titles.count)
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(titles.indices, id: \.self) { index in
                        Button {
                            selectedIndex = index
                        } label: {
                            HStack {
                                Text(titles[index])
                                    .font(.bold(size: 22))
                                    .foregroundColor(selectedIndex == index ? .customBlack : .customText2)
                                    .frame(height: 42)
                            }
                        }
                        .buttonStyle(CustomSegmentButtonStyle())
                        .background(GeometryReader { geoReader in
                            Color.clear.preference(key: RectPreferenceKey.self, value: geoReader.frame(in: .global))
                                .onPreferenceChange(RectPreferenceKey.self) {
                                    setFrame(index: index, frame: $0)
                                }
                        })
                    }
                }
                .background(Rectangle()
                    .fill(Color.customBlack)
                    .frame(width: frames[selectedIndex].width, height: 2)
                    .offset(x: frames[selectedIndex].minX - frames[0].minX), alignment: .bottomLeading)
                .background(Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1), alignment: .bottomLeading)
                .animation(.default)
            }
        }
    }

    private func setFrame(index: Int, frame: CGRect) {
        frames[index] = frame
    }
}

struct ScrollableSegmentedControl_Previews: PreviewProvider {
    @State static var selectedIndex: Int = 0

    static var previews: some View {
        let titles = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth"]
        ScrollableSegmentedControl(selectedIndex: $selectedIndex, titles: titles)
    }
}

private struct CustomSegmentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
            .background(configuration.isPressed ? Color.customAccent2 : Color.clear)
    }
}

struct RectPreferenceKey: PreferenceKey {
    typealias Value = CGRect
    static var defaultValue = CGRect.zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
