//
//  CIImage.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/13/23.
//

import Foundation
import CoreImage
import SwiftUI
import UIKit

//extensie pentru clasa CIImage din pachetul CoreImage
extension CIImage {
    //transforma o imagine din CIIMage in UIImage pe pentru afisare
    var uIImage: UIImage? {
        let context = CIContext()
        if let cgImage = context.createCGImage(self, from: self.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

extension CIImage {
    //redimensioneaza imaginea la dimensiunea mentionata folosind algoritmul Lanczos din libraria CoreImage
    func scaleFill(to targetSize: CGSize) -> CIImage? {
        let resizeFilter = CIFilter(name:"CILanczosScaleTransform")
        let scale = targetSize.height / (extent.height)
        let aspectRatio = targetSize.width / ((extent.width) * scale)

        resizeFilter?.setValue(self, forKey: kCIInputImageKey)
        resizeFilter?.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        return resizeFilter?.outputImage
    }
    
    //la fel ca si functia anterioara, doar ca si translateaza imaginea in functie de originea dreptunghiului
    func scaleFill(around targetRect: CGRect) -> CIImage? {
        return scaleFill(to: targetRect.size)?.transformed(by: CGAffineTransform(translationX: targetRect.origin.x, y: targetRect.origin.y))
    }
    
    //aduce dimensiunile la aceleasi dimensiuni ca alta imagine
    func scaleFill(to image: CIImage) -> CIImage? {
        scaleFill(around: image.extent)
    }
}

extension CIImage {
    //inverseaza culorile obiectului instanta
    var inverted: CIImage? {
        (CIFilter(name: "CIColorInvert", parameters: [kCIInputImageKey: self])?.outputImage)
    }
}
