//
//  LightFilters.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/9/23.
//

import Foundation
import CoreImage
import SwiftUI

enum LightFilters: String, CoreImageFunctionFilterType {
    case gamma, exposure, sharpenLuminance, highlight, shadow
    var variableField: String {
        switch self {
        case .exposure:
            return kCIInputEVKey
        case .gamma:
            return "inputPower"
        case .sharpenLuminance:
            return kCIInputSharpnessKey
        case .highlight:
            return "inputHighlightAmount"
        case .shadow:
            return "inputShadowAmount"
        }
    }
    
    var filterName: String {
        switch self {
        case .gamma:
            return "CIGammaAdjust"
        case .exposure:
            return "CIExposureAdjust"
        case .sharpenLuminance:
            return "CISharpenLuminance"
        case .highlight, .shadow:
            return "CIHighlightShadowAdjust"
        }
    }
    
    var displayName: String {
        switch self {
        case .sharpenLuminance:
            return "SHARPEN LUMINANCE"
        default:
            return self.rawValue.uppercased()
        }
    }
    
    var icon: Image {
        switch self {
        case .gamma:
            return Image(systemName: "camera.aperture")
        case .exposure:
            return Image(systemName: "plus.forwardslash.minus")
        case .sharpenLuminance:
            return Image(systemName: "triangle.righthalf.filled")
        case .highlight:
            return Image(systemName: "circle.lefthalf.filled")
        case .shadow:
            return Image(systemName: "circle.righthalf.filled")
        }
    }
}
