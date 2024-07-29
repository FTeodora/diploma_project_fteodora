//
//  FilterGroupProtocol.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/2/23.
//

import Foundation
import Combine

//interfata pentru o categorie de filtre
protocol FilterGroup: ObservableObject, Identifiable {
    associatedtype FilterType: Filter
    var type: FilterCategory { get }
    var appliableFilters: [FilterType] { get }
}
