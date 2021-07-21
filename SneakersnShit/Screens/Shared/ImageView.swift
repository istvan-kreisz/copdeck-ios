//
//  ImageView.swift
//  CopDeck
//
//  Created by István Kreisz on 2/14/21.
//

import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }

    init(urlString: String) {
        guard let url = URL(string: urlString), !urlString.isEmpty else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image: UIImage = UIImage()
    let url: String
    let size: CGFloat
    let aspectRatio: CGFloat?

    init(withURL url: String, size: CGFloat, aspectRatio: CGFloat?) {
        self.url = url
        self.size = size
        self.aspectRatio = aspectRatio
        self.imageLoader = ImageLoader(urlString: url)
    }

    var body: some View {
        #if DEBUG
            if url.isEmpty {
                Image("dude")
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .frame(width: size, height: size)
                    .onReceive(imageLoader.didChange) { data in
                        self.image = UIImage(data: data) ?? UIImage()
                    }
            } else {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .frame(width: size, height: size)
                    .onReceive(imageLoader.didChange) { data in
                        self.image = UIImage(data: data) ?? UIImage()
                    }
            }
        #else
            Image(uiImage: image)
                .resizable()
                .aspectRatio(aspectRatio, contentMode: .fit)
                .frame(width: size, height: size)
                .onReceive(imageLoader.didChange) { data in
                    self.image = UIImage(data: data) ?? UIImage()
                }
        #endif
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(withURL: "", size: 80, aspectRatio: 1)
    }
}
