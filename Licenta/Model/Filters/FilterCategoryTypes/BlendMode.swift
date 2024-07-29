//
//  BlendMode.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/16/23.
//

import Foundation

//Tipurole de filtre pentru blending mode-urile gradientului
enum BlendMode: String, CoreImageFilterType {
    case normal = "none", overlay, multiply, luminosity, screen, softLight = "soft light", burn, dodge, lighten, hue, exclusion
    var filterName: String {
        switch self {
        case .normal:
            return ""
        case .overlay:
            return "CIOverlayBlendMode"
        case .multiply:
            return "CIMultiplyBlendMode"
        case .luminosity:
            return "CILuminosityBlendMode"
        case .screen:
            return "CIScreenBlendMode"
        case .softLight:
            return "CISoftLightBlendMode"
        case .burn:
            return "CIColorBurnBlendMode"
        case .dodge:
            return "CIColorDodgeBlendMode"
        case .lighten:
            return "CILightenBlendMode"
        case .hue:
            return "CIHueBlendMode"
        case .exclusion:
            return "CIExclusionBlendMode"
        }
    }
    
    var displayName: String {
        return rawValue.uppercased()
    }
    
    static var allFilters: [BlendModeFilter] {
        return BlendMode.allCases.map { BlendModeFilter(type: $0) }
    }
}
