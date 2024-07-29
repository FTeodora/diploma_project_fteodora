//
//  Filter.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/28/23.
//

import Foundation
import CoreImage
import Combine
import UIKit
import SwiftUI

enum FilterCategory: String, CaseIterable, Identifiable {
    var id: String {
        return self.rawValue
    }
    
    case color, light, effects, paint, object, crop, conv, aspect
    
    var possibleFilters: [any Filter] {
        switch self {
        case .color:
            return [OneValueFilter(type: .hue),
                OneValueFilter(type: .saturation),
                OneValueFilter(type: .temperature),
                OneValueFilter(type: .tone) ]
        case .light:
            return [OneValueFilter(type: .gamma),
                    OneValueFilter(type: .exposure),
                    OneValueFilter(type: .sharpenLuminance),
                    OneValueFilter(type: .highlight),
                    OneValueFilter(type: .shadow)]
        case .effects:
            return [OneValueFilter(type: .bloom),
                    OneValueFilter(type: .gloom),
                    OneValueFilter(type: .dither)]
        case .paint:
            return []
        case .object:
            return []
        case .conv:
            return [ConvolutionFilter()]
        case .aspect:
            return [Effect(type: .comicEffect),
                    Effect(type: .chrome),
                    Effect(type: .medianFilter),
                    Effect(type: .invert)]
        case .crop:
            return []
        }
    }
    
    var image: Image {
        switch self {
        case .color:
            return Image(systemName: "paintpalette.fill")
        case .light:
            return Image(systemName: "rays")
        case .effects, .aspect:
            return Image(systemName: "text.below.photo.fill")
        case .paint:
            return Image(systemName: "paintbrush.pointed.fill")
        case .object:
            return Image(systemName: "rays")
        case .conv:
            return Image(systemName: "rectangle.split.3x3")
        case .crop:
            return Image(systemName: "crop.rotate")
        }
    }
    
    static func allAsObjects() -> [AnyFilterGroup] {
        [EveryFilterGroup(type: .color),
         EveryFilterGroup(type: .light),
         SingleFilterGroup<ChannelFilters>(type: .effects),
         SingleFilterGroup<ChannelFilters>(type: .aspect),
         PaintingFilterGroup(),
         VisionModelGroup(),
         AnyFilterGroup(type: .conv)
        ]
    }
}

class SingleFilterGroup<T: Equatable>: AnyFilterGroup {
    @Published var selectedFilter: T?
    
    override var appliableFilters: [any Filter] {
        if let selected = (filters as! [any TypedFilter]).first(where: { $0.type as? T == selectedFilter}) {
            return [selected]
        }
        return []
    }
}

class PaintingFilterGroup: AnyFilterGroup {
    @Published var markups: UIImage?
    
    init() {
        super.init(type: .paint)
    }
}
