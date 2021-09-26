//
//  ImagePickerView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/25/21.
//

import SwiftUI
import UIKit
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var showPicker: Bool
    var selectionLimit: Int
    let onImagesPicked: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> some UIViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = selectionLimit
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePickerView

        init(parent: ImagePickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                parent.showPicker.toggle()
                return
            }
            var images: [UIImage] = []

            let dispatchGroup = DispatchGroup()

            for img in results {
                guard img.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
                dispatchGroup.enter()
                img.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    guard let image = image as? UIImage else {
                        dispatchGroup.leave()
                        return
                    }

                    DispatchQueue.main.async {
                        images.append(image)
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) { [weak self] in
                self?.parent.onImagesPicked(images)
                self?.parent.showPicker.toggle()
            }
        }
    }
}
