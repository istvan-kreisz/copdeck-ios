//
//  CustomSpinner.swift
//  CopDeck
//
//  Created by István Kreisz on 7/12/21.
//

import SwiftUI

struct CustomSpinner: View {
    let text: String?
    var fontSize: CGFloat = 14
    let style = StrokeStyle(lineWidth: 4, lineCap: .round)
    let color1 = Color.customText2
    let color2 = Color.customText2.opacity(0.5)

    @State var animate = false

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(x: fontSize < 14 ? 0.8 : 1.0, y: fontSize < 14 ? 0.8 : 1.0, anchor: .center)
//            Circle()
//                .trim(from: 0, to: 0.7)
//                .stroke(AngularGradient(gradient: .init(colors: [color1, color2]), center: .center), style: style)
//                .rotationEffect(Angle(degrees: animate ? 360 : 0))
//                .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
//                .frame(width: 15, height: 15)
            if let text = text {
                Text(text)
                    .font(.bold(size: fontSize))
                    .foregroundColor(.customText1)
            }
            Spacer()
        }

//        .onAppear {
//            animate.toggle()
//        }
    }
}
