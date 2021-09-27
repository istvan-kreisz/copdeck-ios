//
//  ImageViewer.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/27/21.
//

import SwiftUI
import UIKit
import NukeUI

public struct ImageViewer: View {
    @Binding var image: URL?
    @State var caption: Text?

    @State var dragOffset: CGSize = CGSize.zero
    @State var dragOffsetPredicted: CGSize = CGSize.zero

    public init(image: Binding<URL?>, caption: Text? = nil) {
        _image = image
        _caption = State(initialValue: caption)
    }

    public var body: some View {
        VStack {
            if let imageURL = image {
                ZStack {
                    DeleteButton(style: .fill, size: .large, color: .customBlack) {
                        self.image = nil
                    }
                    .topAligned()
                    .rightAligned()
                    .padding(.top, UIApplication.shared.safeAreaInsets().top + 20)
                    .padding(.trailing, 20)
                    .zIndex(2)

                    VStack {
                        ZStack {
                            LazyImage(source: imageURL) { state in
                                if let image = state.image {
                                    image.resizingMode(.aspectFit)
                                }
                            }
                            .offset(x: dragOffset.width, y: dragOffset.height)
                            .rotationEffect(Angle(degrees: Double(dragOffset.width / 30)))
                            .pinchToZoom()
                            .gesture(DragGesture()
                                .onChanged { value in
                                    self.dragOffset = value.translation
                                    self.dragOffsetPredicted = value.predictedEndTranslation
                                }
                                .onEnded { value in
                                    if (abs(self.dragOffset.height) + abs(self.dragOffset.width) > 570) ||
                                        (abs(self.dragOffsetPredicted.height) / abs(self.dragOffset.height) > 3) ||
                                        (abs(self.dragOffsetPredicted.width) / abs(self.dragOffset.width)) > 3 {
                                        withAnimation(.spring()) {
                                            self.dragOffset = self.dragOffsetPredicted
                                        }
                                        self.image = nil
                                        return
                                    }
                                    withAnimation(.interactiveSpring()) {
                                        self.dragOffset = .zero
                                    }
                                })

                            if self.caption != nil {
                                VStack {
                                    Spacer()
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            self.caption
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                            Spacer()
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.12,
                                      opacity: 1.0 - Double(abs(self.dragOffset.width) + abs(self.dragOffset.height)) / 1000).edgesIgnoringSafeArea(.all))
                    .zIndex(1)
                }
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                .onAppear {
                    self.dragOffset = .zero
                    self.dragOffsetPredicted = .zero
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

class PinchZoomView: UIView {
    weak var delegate: PinchZoomViewDelgate?

    private(set) var scale: CGFloat = 0 {
        didSet {
            delegate?.pinchZoomView(self, didChangeScale: scale)
        }
    }

    private(set) var anchor: UnitPoint = .center {
        didSet {
            delegate?.pinchZoomView(self, didChangeAnchor: anchor)
        }
    }

    private(set) var offset: CGSize = .zero {
        didSet {
            delegate?.pinchZoomView(self, didChangeOffset: offset)
        }
    }

    private(set) var isPinching: Bool = false {
        didSet {
            delegate?.pinchZoomView(self, didChangePinching: isPinching)
        }
    }

    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0

    init() {
        super.init(frame: .zero)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc private func pinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPinching = true
            startLocation = gesture.location(in: self)
            anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
            numberOfTouches = gesture.numberOfTouches

        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                // If the number of fingers being used changes, the start location needs to be adjusted to avoid jumping.
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)

                numberOfTouches = gesture.numberOfTouches
            }

            scale = gesture.scale

            location = gesture.location(in: self)
            offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)

        case .ended,
             .cancelled,
             .failed:
            withAnimation(.interactiveSpring()) {
                isPinching = false
                scale = 1.0
                anchor = .center
                offset = .zero
            }
        default:
            break
        }
    }
}

protocol PinchZoomViewDelgate: AnyObject {
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
}

struct PinchZoom: UIViewRepresentable {
    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    @Binding var isPinching: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView()
        pinchZoomView.delegate = context.coordinator
        return pinchZoomView
    }

    func updateUIView(_ pageControl: PinchZoomView, context: Context) {}

    class Coordinator: NSObject, PinchZoomViewDelgate {
        var pinchZoom: PinchZoom

        init(_ pinchZoom: PinchZoom) {
            self.pinchZoom = pinchZoom
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
            pinchZoom.isPinching = isPinching
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
            pinchZoom.scale = scale
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
            pinchZoom.anchor = anchor
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize) {
            pinchZoom.offset = offset
        }
    }
}

struct PinchToZoom: ViewModifier {
    @State var scale: CGFloat = 1.0
    @State var anchor: UnitPoint = .center
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .overlay(PinchZoom(scale: $scale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
    }
}

extension View {
    func pinchToZoom() -> some View {
        self.modifier(PinchToZoom())
    }
}
