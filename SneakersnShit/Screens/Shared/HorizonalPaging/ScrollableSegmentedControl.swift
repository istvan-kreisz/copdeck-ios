//
//  ScrollableSegmentedControl.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/12/21.
//

import SwiftUI

struct ScrollableSegmentedControl: View {
    struct ButtonConfig {
        let title: String
        let tapped: () -> Void
    }

    @Binding private var selectedIndex: Int
    @Binding private var titles: [String]
    let button: ButtonConfig?

    @State private var frames: [CGRect]
    @State private var backgroundFrame = CGRect.zero
    @State private var isScrollable = true

    init(selectedIndex: Binding<Int>, titles: Binding<[String]>, button: ButtonConfig?) {
        self._selectedIndex = selectedIndex
        self._titles = titles
        self.button = button
        #warning("fix")
        frames = [CGRect](repeating: .zero, count: titles.wrappedValue.count)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { sp in
                HStack(spacing: 0) {
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
                            .id(index)
                        }
                    }
                    .background(Rectangle()
                        .fill(Color.customBlack)
                        .frame(width: frames[safe: selectedIndex]?.width ?? 0, height: 2)
                        .offset(x: (frames[safe: selectedIndex]?.minX ?? 0) - (frames[safe: 0]?.minX ?? 0)), alignment: .bottomLeading)
                    .background(Rectangle()
                        .fill(Color.gray)
                        .frame(height: 1), alignment: .bottomLeading)
                    .animation(.default)
                    

                    if let button = button {
                        Button(action: button.tapped) {
                            HStack {
                                Text(button.title)
                                    .font(.bold(size: 22))
                                    .foregroundColor(.customBlue)
                                    .frame(height: 42)
                                ZStack {
                                    Circle()
                                        .fill(Color.customBlue.opacity(0.2))
                                        .frame(width: 21, height: 21)
                                    Image(systemName: "plus")
                                        .font(.bold(size: 9))
                                        .foregroundColor(Color.customBlue)
                                }.frame(width: 21, height: 21)
                            }
                        }
                        .padding(.horizontal, 20)
                        .id(titles.count)
                    }
                }
                .onChange(of: selectedIndex) { value in
                    withAnimation {
                        sp.scrollTo(value, anchor: .center)
                    }
                }
                .onChange(of: titles) { newTitles in
                    if selectedIndex >= newTitles.count {
                        selectedIndex = newTitles.count - 1
                    }
                }
            }
        }
    }

    private func setFrame(index: Int, frame: CGRect) {
        if index >= frames.count {
            frames.append(frame)
        } else {
            frames[index] = frame
        }
    }

    private func removeFrame(atIndex index: Int) {
        frames.remove(at: index)
    }

}

struct ScrollableSegmentedControl_Previews: PreviewProvider {
    @State static var selectedIndex: Int = 0

    static var previews: some View {
        let titles = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth"]
        ScrollableSegmentedControl(selectedIndex: $selectedIndex, titles: .constant(titles), button: nil)
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
