//
//  SingleFilterGroup.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/7/23.
//

import Foundation
import Combine

//un grup de filtre care aplica pe imagine doar un anumit filtru selectat la un momentdat
class SingleFilterGroup<T: TypedFilter>: FilterGroup {
    @Published var selectedFilter: T.TypeEnum?
    @Published var filters: [T] = []
    
    var type: FilterCategory
    var id: Int
    weak var undoManager: UndoManager?
    
    init(type: FilterCategory) {
        self.type = type
        let filtrs: [T] = type.possibleFilters() ?? []
        filters = filtrs
        selectedFilter = filtrs.first?.type
        self.id = type.sortIndex
    }
    
    var appliableFilters: [T] {
        guard let selectedFilter = selectedFilter, let selected = filters.first(where: { $0.type == selectedFilter}) else { return [] } 
        return [selected]
    }
    
    func registerUndo(from oldValue: T.TypeEnum?, to newValue: T.TypeEnum?) {
        undoManager?.registerUndo(withTarget: self, handler: { handler in
            handler.registerUndo(from: newValue, to: oldValue)
            handler.selectedFilter = oldValue
        })
    }
}
