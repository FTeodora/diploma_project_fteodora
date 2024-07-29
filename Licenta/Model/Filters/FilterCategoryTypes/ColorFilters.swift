//
//  ColorFilters.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/9/23.
//

import Foundation
import SwiftUI
import CoreImage

//filtrele pentru culoare
enum ColorFilters: String, CoreImageFunctionFilterType {
    typealias FilterType = OneValueFilter
    
    case hue, saturation, brightness, contrast, vibrance, tone, temperature
    
    var filterName: String {
        switch self {
        case .hue:
            return "CIHueAdjust"
        case .vibrance:
            return "CIVibrance"
        case .tone, .temperature:
            return "CITemperatureAndTint"
        case .saturation, .brightness, .contrast:
            return "CIColorControls"
        }
    }
    
    var variableField: String {
        switch self {
        case .hue:
            return kCIInputAngleKey
        case .vibrance:
            return kCIInputAmountKey
        case .tone, .temperature:
            return "inputNeutral"
        case .saturation:
            return kCIInputSaturationKey
        case .brightness:
            return kCIInputBrightnessKey
        case .contrast:
            return kCIInputContrastKey
        }
    }
    
    var range: ClosedRange<Double>? {
        switch self {
        case .tone :
            return (-100.0...100.0)
        case .temperature:
            return (-3000.0 ... 3000.0)
        default:
            let min = variableFieldValue(at: kCIAttributeSliderMin) as? Double ?? 0.0
            let max = variableFieldValue(at: kCIAttributeSliderMax) as? Double ?? 0.0
            return (min...max)
        }
    }
    
    var displayName: String {
        return self.rawValue.uppercased()
    }
    
    //filtrele pentru ton si temperatura sunt de fapt acelasi filtru, doar ca se regleaza cate o valoare diferita
    func function<T>(input: T) -> Any? {
        switch self {
        case .tone:
            guard let value = input as? Double else { return nil }
            return CIVector.init(x: 6500, y: CGFloat(value))
        case .temperature:
            guard let value = input as? Double else { return nil }
            return CIVector.init(x: CGFloat(value) + 6500, y: 0)
        default:
           return input
        }
    }
    
    var defaultValue: Double {
        switch self {
        case .tone, .temperature:
            return 0.0
        default:
            return variableFieldValue(at: kCIAttributeDefault) as? Double ?? 0.0
        }
    }
    
    var icon: Image {
        switch self {
        case .hue, .saturation, .vibrance:
            return Image(rawValue)
        case .brightness:
            return Image(systemName: "lightbulb")
        case .contrast:
            return Image(systemName: "circle.righthalf.filled")
        case .tone:
            return Image(systemName: "drop")
        case .temperature:
            return Image(systemName: "thermometer")
        }
    }
}
