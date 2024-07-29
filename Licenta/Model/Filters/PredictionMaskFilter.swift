//
//  PredictionMaskFilter.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/2/23.
//

import Foundation
import CoreImage
import CoreML
import UIKit

//Filtrul care mascheaza pixelii unui obiect din predictie
class PredictionMaskFilter: TypedFilter {
    var type: ModelClass
    @Published var mask: CIImage?
    @Published var background: CIImage?
    var inverted = false
    
    init(predictionClass: ModelClass) {
        self.type = predictionClass
    }
    
    func apply(input: CIImage) -> CIImage? {
        //masca este o masca alb-negru care considera pixelii negri ca fiind culoarea transparenta
        guard let mask = inverted ? mask?.inverted : mask else { return input }
        //adaugarea fundalului daca este cazul
        if let background = background?.scaleFill(to: input) {
            return CIFilter(name: "CIBlendWithMask", parameters: [
                kCIInputImageKey: input,
                kCIInputBackgroundImageKey: background,
                kCIInputMaskImageKey: mask.scaleFill(to: input) as Any])?.outputImage
        }
        return CIFilter(name: "CIBlendWithMask", parameters: [
            kCIInputImageKey: input,
            kCIInputMaskImageKey: mask.scaleFill(to: input) as Any])?.outputImage
    }
    //realizarea mastii din harta de segmentare
    func computeMask(from segmentationMap: CGImage?) {
        guard let mapImage = segmentationMap?.mask(modelClass: type) else { return }
        mask = CIImage(cgImage: mapImage)
    }
}
