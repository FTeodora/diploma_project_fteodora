//
//  ImageSaver.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/10/23.
//  sursa https://www.hackingwithswift.com/books/ios-swiftui/how-to-save-images-to-the-users-photo-library

import Foundation
import UIKit

class ImageSaver: NSObject {
    var onComplete: (Error?) -> () = { _ in }
    
    init(onComplete: @escaping (Error?) -> () = { _ in }) {
        self.onComplete = onComplete
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        guard let pngData = image.pngData(), let transparentImage = UIImage(data: pngData) else { return }
        UIImageWriteToSavedPhotosAlbum(transparentImage, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        onComplete(error)
    }
}
