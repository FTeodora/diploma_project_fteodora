//
//  ImageFilterFilters.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/9/23.
//

import Foundation
import CoreImage

enum ImageFilterFilters: String, CoreImageFunctionFilterType {
    case original, vignette, sepia, bloom, gloom, dither, pixellate, mosaic, morphology, blur
    
    var filterName: String {
        switch self {
        case .vignette:
            return "CIVignette"
        case .bloom:
            return "CIBloom"
        case .gloom:
            return "CIGloom"
        case .dither:
            return "CIDither"
        case .pixellate:
            return "CIPixellate"
        case .mosaic:
            return "CICrystallize"
        case .morphology:
            return "CIMorphologyGradient"
        case .original:
            return ""
        case .sepia:
            return "CISepiaTone"
        case .blur:
            return "CIDiscBlur"
        }
    }
    
    var displayName: String {
        rawValue.uppercased()
    }
    
    var variableField: String {
        switch self {
        case .gloom, .dither, .sepia, .vignette:
            return kCIInputIntensityKey
        case .bloom, .mosaic, .morphology, .blur:
            return kCIInputRadiusKey
        case .pixellate:
            return kCIInputScaleKey
        case .original:
            return ""
        }
    }
    
    var defaultValue: Double {
        if self == .original {
            return 0.0
        }
        return variableFieldValue(at: kCIAttributeDefault) as? Double ?? 0.0
    }
    
    var range: ClosedRange<Double>? {
        if self == .original {
            return nil
        }
        let min = variableFieldValue(at: kCIAttributeSliderMin) as? Double ?? 0.0
        let max = variableFieldValue(at: kCIAttributeSliderMax) as? Double ?? 0.0
        return (min...max)
    }
}
