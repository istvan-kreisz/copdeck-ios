//
//  CustomSpinner.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/12/21.
//

import SwiftUI

struct CustomSpinner: View {

    let text: String?
    let style = StrokeStyle(lineWidth: 6, lineCap: .round)
    let color1 = Color.customText1
    let color2 = Color.customText1.opacity(0.5)

    @State var animate = false

    var body: some View {
        ZStack {
            HStack(spacing: 15) {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(AngularGradient(gradient: .init(colors: [color1, color2]), center: .center), style: style)
                    .rotationEffect(Angle(degrees: animate ? 360 : 0))
                    .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
                    .frame(width: 30, height: 30)
                if let text = text {
                    Text(text)
                        .font(.bold(size: 28))
                        .foregroundColor(.customText1)
                }
                Spacer()
            }
        }
        .onAppear {
            self.animate.toggle()
        }
    }
}

struct CustomSpinner_Previews: PreviewProvider {
    static var previews: some View {
        return CustomSpinner(text: "Loading...", animate: true)
    }
}
