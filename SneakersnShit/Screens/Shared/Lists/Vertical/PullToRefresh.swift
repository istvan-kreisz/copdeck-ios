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

    var body: some View {
        GeometryReader { geo in
            if geo.frame(in: .named(coordinateSpaceName)).midY > 130 {
                Spacer()
                    .onAppear {
                        guard geo.frame(in: .named(coordinateSpaceName)).midY > 130 else { return }
                        generator.impactOccurred()
                        onRefresh()
                    }
            }
            ProgressView()
                .centeredHorizontally()
        }
        .padding(.top, -50)
    }
}
