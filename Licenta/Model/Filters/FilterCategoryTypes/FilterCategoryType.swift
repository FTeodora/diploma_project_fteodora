//
//  FilterCategoryType.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/9/23.
//

import Foundation
import CoreImage
import SwiftUI

//un filtru afisabil simplu, nu neaparat de CoreImage
protocol SelectableFilter: CaseIterable, Equatable, Identifiable {
    var displayName: String { get }
    var icon: Image { get }
}

extension SelectableFilter {
    var id: Self {
        return self
    }
    var icon: Image {
        return Image(systemName: "questionmark.circle.fill")
    }
}

//Filtrele au fost separate in mai multe subcategorii in functie de categoria de filtre din care fac parte
//pentru granularitate deoarece multe filtre sunt din CoreImage
protocol CoreImageFilterType: SelectableFilter {
    var ciFilter: CIFilter? { get }
    var filterName: String { get }
}

extension CoreImageFilterType {
    var ciFilter: CIFilter? {
        return CIFilter(name: filterName)
    }
}

//un filtru de core image care are si o variabila reglabila
protocol CoreImageFunctionFilterType: CoreImageFilterType {
    var variableField: String { get }
    var defaultValue: Double { get }
    var range: ClosedRange<Double>? { get }
    func variableFieldValue(at keyPath: String) -> Any?
    func function<T>(input: T) -> Any?
}

extension CoreImageFunctionFilterType {
    //numele campului reglabil
    func variableFieldValue(at keyPath: String) -> Any? {
        guard let variable = ciFilter?.attributes[variableField] as? Dictionary<String, Any> else {
            return nil
        }
        return variable[keyPath]
    }
    
    //functia aplicata pentru a obtine valoarea filtrului.
    //in toate situatiile in afara filtrelor cu mai multe componente(ex temperatura, ton), aceasta este direct valoarea de input
    func function<T>(input: T) -> Any? {
        return input
    }
    //intervalul valorilor care pot fi atribuite filtrului
    var range: ClosedRange<Double>? {
        let min = variableFieldValue(at: kCIAttributeSliderMin) as? Double ?? 0.0
        let max = variableFieldValue(at: kCIAttributeSliderMax) as? Double ?? 0.0
        return (min...max)
    }
    
    //valoarea initiala a filtrului. nu este neaparat 0
    var defaultValue: Double {
        variableFieldValue(at: kCIAttributeDefault) as? Double ?? 0.0
    }
    
    static var allFilters: [OneValueFilter<Self>] {
        self.allCases.map { OneValueFilter<Self>(type: $0) }
    }
}
