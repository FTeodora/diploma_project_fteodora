//
//  BlendModeFilter.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/16/23.
//

import Foundation
import CoreImage

//Filtru care aplica un gradient peste imagine cu un anumit blending mode
class BlendModeFilter: TypedFilter {
    var filter: CIFilter?
    var type: BlendMode
    
    init(type: BlendMode) {
        self.type = type
        filter = type.ciFilter
    }
    
    @Published var blendedImage: CIImage?
    func apply(input: CIImage) -> CIImage? {
        guard let filter = filter else { return input }
        filter.setValue(blendedImage?.scaleFill(to: input), forKey: kCIInputImageKey)
        filter.setValue(input, forKey: kCIInputBackgroundImageKey)
        return filter.outputImage
    }
}
