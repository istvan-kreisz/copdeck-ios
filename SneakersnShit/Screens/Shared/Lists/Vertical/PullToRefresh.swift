//
//  PullToRefresh.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/4/21.
//

import SwiftUI

struct PullToRefresh: View {
    let generator = UIImpactFeedbackGenerator(style: .light)

    var coordinateSpaceName: String
    var onRefresh: () -> Void

    let offset: CGFloat = 195

    var body: some View {
        GeometryReader { geo in
            if geo.frame(in: .named(coordinateSpaceName)).midY > offset {
                Spacer()
                    .onAppear {
                        log("shaaaa - \(geo.frame(in: .named(coordinateSpaceName)).midY)")
                        guard geo.frame(in: .named(coordinateSpaceName)).midY > offset else { return }
                        generator.impactOccurred()
                        onRefresh()
                    }
                ProgressView()
                    .centeredHorizontally()
                    .padding(.top, 50)
            }
        }
        .padding(.top, -offset)
    }
}
