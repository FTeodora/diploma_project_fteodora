//
//  EffectFilterGroup.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 8/29/23.
//

import Foundation
import CoreImage

//Categoria efectelor neregrabile
//acestea pastreaza in cadrul lor o imagine redimensionata folosita pentru previzualizare
class EffectFilterGroup: SingleFilterGroup<Effect> {
    var previewImage: CIImage?
    init(with previewImage: CIImage?) {
        super.init(type: .effects)
        let resizeFilter = CIFilter(name:"CILanczosScaleTransform")
        
        let scale = 55.0/(previewImage?.extent.height ?? 1.0)
        let aspectRatio = (previewImage?.extent.width ?? 1.0) / (previewImage?.extent.height ?? 1.0)
        
        resizeFilter?.setValue(previewImage, forKey: kCIInputImageKey)
        resizeFilter?.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        self.previewImage = resizeFilter?.outputImage?.cropped(to: CGRect(x: 0, y: 0, width: 43, height: 55))
    }
}
