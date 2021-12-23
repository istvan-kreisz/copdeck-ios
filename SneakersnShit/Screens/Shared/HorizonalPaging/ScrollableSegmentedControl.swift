//
//  ScrollableSegmentedControl.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/12/21.
//

import SwiftUI
import Nuke

struct ScrollableSegmentedControl: View {
    struct ButtonConfig {
        let title: String
        let tapped: () -> Void
    }

    @Binding private var selectedIndex: Int
    @Binding private var titles: [String]
    let isContentLocked: Bool
    let button: ButtonConfig?
    let size: CGFloat?

    @State private var frames: [CGRect]
    @State private var backgroundFrame = CGRect.zero
    @State private var isScrollable = true

    init(selectedIndex: Binding<Int>, titles: Binding<[String]>, isContentLocked: Bool, button: ButtonConfig?, size: CGFloat? = nil) {
        self._selectedIndex = selectedIndex
        self._titles = titles
        self.isContentLocked = isContentLocked
        self.button = button
        self.size = size
        self._frames = State<[CGRect]>(initialValue: [CGRect](repeating: .zero, count: titles.wrappedValue.count))
    }
    
    #warning("enable adding 1 stack")
    #warning("enable stack sharing")

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { sp in
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(titles.indices.uniqued(), id: \.self) { (index: Int) in
                            let textColor: Color = selectedIndex == index ? .customBlack : .customText2
                            Button {
                                selectedIndex = index
                            } label: {
                                Text(titles[index])
                                    .font(.bold(size: 22))
                                    .foregroundColor(textColor)
                                    .frame(height: 42)
                            }
                            .lockedContent(displayStyle: .adjacentRight(spacing: -15),
                                           contentSttyle: .lock(size: 20, color: textColor),
                                           lockEnabled: isContentLocked && index > 1 && AppStore.default.state.user?.membershipInfo?.isBetaTester != true)
                            .buttonStyle(CustomSegmentButtonStyle())
                            .frame(width: size)
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
                                if !isContentLocked {
                                    ZStack {
                                        Circle()
                                            .fill(Color.customBlue.opacity(0.2))
                                            .frame(width: 21, height: 21)
                                        Image(systemName: "plus")
                                            .font(.bold(size: 9))
                                            .foregroundColor(Color.customBlue)
                                    }
                                    .frame(width: 21, height: 21)
                                }
                            }
                        }
                        .lockedContent(displayStyle: .adjacentRight(spacing: 4),
                                       contentSttyle: .lock(size: 20, color: .customBlue),
                                       lockEnabled: isContentLocked && titles.count > 2)
                        .padding(.horizontal, 20)
                    }
                }
                .onChange(of: selectedIndex) { value in
                    if size == nil {
                        withAnimation {
                            sp.scrollTo(value, anchor: .center)
                        }
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
        } else if frames[safe: index] != nil {
            frames[index] = frame
        }
    }

    private func removeFrame(atIndex index: Int) {
        if frames[safe: index] != nil {
            frames.remove(at: index)
        }
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
