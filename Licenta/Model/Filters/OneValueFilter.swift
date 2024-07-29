//
//  OneValueFilter.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/2/23.
//

import Foundation
import CoreImage
import Combine

//un filtru de Core image cu o valoare reglabila
class OneValueFilter<T:CoreImageFunctionFilterType>: TypedFilter {
    let type: T
    let filter: CIFilter?
    @Published var value: Double
    
    init(type: T) {
        self.value = type.defaultValue
        self.type = type
        filter = type.ciFilter
    }
    
    func apply(input: CIImage) -> CIImage? {
        guard let filter = filter else { return input }
        filter.setValue(type.function(input: value), forKeyPath: type.variableField)
        filter.setValue(input, forKey: kCIInputImageKey)
        return filter.outputImage
    }
    
    weak var undoManager: UndoManager?
    func registerUndo(from oldValue: Double, to newValue: Double) {
        undoManager?.registerUndo(withTarget: self, handler: { handler in
            handler.registerUndo(from: newValue, to: oldValue)
            handler.value = oldValue
        })
    }
}
