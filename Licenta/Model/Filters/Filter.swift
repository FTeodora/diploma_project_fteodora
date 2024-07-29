//
//  Filter.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/20/23.
//

import Foundation
import CoreImage
import Combine
import UIKit
import SwiftUI

//interfata de filtru
protocol Filter: ObservableObject, Identifiable {
    func apply(input: CIImage) -> CIImage?
}

//un filtru care contine si un tip
protocol TypedFilter: Filter, Identifiable {
    associatedtype TypeEnum: SelectableFilter
    var type: TypeEnum { get }
    var id: ObjectIdentifier { get }
}

extension TypedFilter {
    var id: TypeEnum {
        type
    }
}
