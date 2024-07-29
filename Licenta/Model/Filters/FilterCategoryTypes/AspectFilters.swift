//
//  AspectFilters.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/9/23.
//

import Foundation
import CoreImage

enum EffectFilter: String, CoreImageFilterType {
    case original, medianFilter, chrome, transfer, process, fade, instant, mono, tonal, noir, invert, xray, gabor, comic, thermal
    
    var filterName: String {
        switch self {
        case .chrome, .noir, .tonal, .fade, .instant, .mono, .process, .transfer:
            return "CIPhotoEffect\(rawValue.capitalized)"
        case .medianFilter:
            return "CIMedianFilter"
        case .invert:
            return "CIColorInvert"
        case .comic:
            return "CIComicEffect"
        case .xray:
            return "CIXRay"
        case .original:
            return ""
        case .gabor:
            return "CIGaborGradients"
        case .thermal:
            return "CIThermal"
        }
    }
    
    var displayName: String {
        switch self {
        case .medianFilter:
            return "MEDIAN FILTER"
        case .original:
            return "ORIGINAL"
        default:
            return ciFilter?.attributes[kCIAttributeDisplayName] as? String ?? self.rawValue.uppercased()
        }
    }
    
    static var allFilters: [Effect] {
        EffectFilter.allCases.map { Effect(type: $0)}
    }
}
