//
//  GradientGroup.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/15/23.
//

import Foundation
import CoreImage
import SwiftUI
import Combine

//Categoria pentru gradientul liniar aplicat
class GradientGroup: SingleFilterGroup<BlendModeFilter> {
    //pozitiile punctelor gradientului
    @Published var point1: CIVector {
        didSet {
            gradientFilter?.setValue(point1, forKey: "inputPoint0")
        }
    }
    @Published var point2: CIVector{
        didSet {
            gradientFilter?.setValue(point2, forKey: "inputPoint1")
        }
    }
    //culorile gradientului
    @Published var color1: Color {
        didSet {
            gradientFilter?.setValue(CIColor(color: UIColor(color1)), forKey: "inputColor0")
        }
    }
    
    @Published var color2: Color {
        didSet {
            gradientFilter?.setValue(CIColor(color: UIColor(color2)), forKey: "inputColor1")
        }
    }
    //filtrul care aplica gradientul
    @Published var gradientFilter: CIFilter?
    
    init() {
        let color1 = Color(.sRGB, red: 0.2 , green: 0.2, blue: 0.98)
        let color2 = Color(.sRGB, red: 0.98 , green: 0.2, blue: 0.2)
    
        let gradientFilter = CIFilter(name: "CISmoothLinearGradient")
        gradientFilter?.setValue(CIColor(color: UIColor(color1)), forKey: "inputColor0")
        gradientFilter?.setValue(CIColor(color: UIColor(color2)), forKey: "inputColor1")
        
        self.color1 = color1
        self.color2 = color2
        
        point1 = ((gradientFilter?.attributes["inputPoint0"] as? Dictionary<String, Any>))?[kCIAttributeDefault] as? CIVector ?? CIVector(x: 0, y: 0)
        point2 = ((gradientFilter?.attributes["inputPoint1"] as? Dictionary<String, Any>))?[kCIAttributeDefault] as? CIVector ?? CIVector(x: 0, y: 0)
        
        self.gradientFilter = gradientFilter
        super.init(type: .grad)
    }
    
    override var appliableFilters: [BlendModeFilter] {
        let selected = super.appliableFilters
        selected.forEach { filter in
            filter.blendedImage = gradientFilter?.outputImage?.cropped(to: CGRect(x: 0, y: 0, width: 200, height: 200))
        }
        return selected
    }
    
    func undoPoint(from oldValue: CIVector, to newValue: CIVector, pointNo: Int) {
        undoManager?.registerUndo(withTarget: self) { handler in
            handler.undoPoint(from: newValue, to: oldValue, pointNo: pointNo)
            (pointNo == 0) ? (handler.point1 = oldValue) : (handler.point2 = oldValue)
        }
    }
    
    func undoColor(from oldValue: Color, to newValue: Color, colorNo: Int) {
        undoManager?.registerUndo(withTarget: self) { handler in
            handler.undoColor(from: newValue, to: oldValue, colorNo: colorNo)
            (colorNo == 0) ? (handler.color1 = oldValue) : (handler.color2 = oldValue)
        }
    }
}
