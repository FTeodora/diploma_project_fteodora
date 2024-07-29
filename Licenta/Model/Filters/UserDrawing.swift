//
//  UserDrawing.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/7/23.
//

import Foundation
import CoreImage
import PencilKit

//desenele realizate de  user peste imagine care trebuie suprapuse peste aceasta
class UserDrawing: Filter {
    @Published var markups: CIImage?
    var bounds: CGRect = .zero
    
    init(markups: CIImage? = nil, bounds: CGRect) {
        self.markups = markups
        self.bounds = bounds
    }
    func apply(input: CIImage) -> CIImage? {
        guard let markups = markups else { return input }
        return (markups.scaleFill(around: bounds)?.composited(over: input))
    }
}
