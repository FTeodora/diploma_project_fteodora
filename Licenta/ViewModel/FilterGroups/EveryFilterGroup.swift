//
//  OverlayedFilterGroup.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/2/23.
//

import Foundation
import Combine

//o categorie de filtre care aplica toate filtrele sale pe imagine
class EveryFilterGroup<T: Filter>: FilterGroup {
    var type: FilterCategory
    @Published var filters: [T] = []
    
    init(type: FilterCategory) {
        self.type = type
        filters = type.possibleFilters() ?? []
    }
    
    var appliableFilters: [T] {
        filters
    }
}
