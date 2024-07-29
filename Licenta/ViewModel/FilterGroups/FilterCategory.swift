//
//  FilterCategory.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/20/23.
//

import Foundation
import CoreImage
import Combine
import UIKit
import SwiftUI

//categoriile de filtre posibile si proprietatile lor
enum FilterCategory: String, CaseIterable, Identifiable, Hashable, Comparable {
    static func < (lhs: FilterCategory, rhs: FilterCategory) -> Bool {
        lhs.sortIndex < rhs.sortIndex
    }
    
    var id: Int {
        return sortIndex
    }
    
    case color, light, filters, paint, object, crop, effects, grad
    
    //filtrele posibile din categorie. alte filtre dependente de alte obiecte sunt initializate ulterior
    func possibleFilters<T: Filter>() -> [T]? {
        switch self {
        case .color:
            return ColorFilters.allFilters as? [T]
        case .light:
            return LightFilters.allFilters as? [T]
        case .filters:
            return ImageFilterFilters.allFilters as? [T]
        case .paint:
            return []
        case .object:
            return []
        case .grad:
            return BlendMode.allFilters as? [T]
        case .effects:
            return EffectFilter.allFilters as? [T]
        case .crop:
            return [OrientationFilter()] as? [T]
        }
    }
    
    //pictograma din meniu
    var image: Image {
        switch self {
        case .color:
            return Image(systemName: "paintpalette.fill")
        case .light:
            return Image(systemName: "rays")
        case .filters:
            return Image(systemName: "slider.vertical.3")
        case .effects:
            return Image(systemName: "text.below.photo.fill")
        case .paint:
            return Image(systemName: "paintbrush.pointed.fill")
        case .object:
            return Image(systemName: "camera.macro.circle")
        case .crop:
            return Image(systemName: "crop.rotate")
        case .grad:
            return Image(systemName: "square.lefthalf.filled")
        }
    }
    
    //sortarea categoriilor in interfata grafica
    var sortIndex: Int {
        switch self {
        case .object:
            return 0
        case .color:
            return 1
        case .light:
            return 2
        case .filters:
            return 3
        case .paint:
            return 6
        case .crop:
            return 7
        case .effects:
            return 4
        case .grad:
            return 5
        }
    }
    
    //indexul de aplicare pe imagine. filtrele sunt aplicate in ordinea crescatoare acestor numere
    var applyIndex: Int {
        switch self {
        case .color:
            return 1
        case .light:
            return 2
        case .filters:
            return 5
        case .paint:
            return 7
        case .object:
            return 0
        case .crop:
            return 8
        case .effects:
            return 4
        case .grad:
            return 6
        }
    }
    
    //implementarea interfetei de hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(sortIndex)
    }
}
