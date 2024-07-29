//
//  EffectFilter.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/2/23.
//

import Foundation
import CoreImage

//un filtru de Core Image care nu are valori reglabile si se aplica direct pe imagine
class Effect: TypedFilter {
    var id: String {
        type.rawValue
    }
    let type: EffectFilter
    let filter: CIFilter?
    
    init(type: EffectFilter) {
        self.type = type
        filter = type.ciFilter
    }
    
    func apply(input: CIImage) -> CIImage? {
        guard let filter = filter else { return input }
        filter.setValue(input, forKey: kCIInputImageKey)
        return filter.outputImage
    }
}
