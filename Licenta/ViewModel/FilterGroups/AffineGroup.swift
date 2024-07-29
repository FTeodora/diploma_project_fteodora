//
//  AffineGroup.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/7/23.
//

import Foundation
import CoreImage
import Combine
import SwiftUI

//grupul de filtre care se ocupa cu decuparea, rotirea si oglindirea imaginii
class AffineGroup: EveryFilterGroup<OrientationFilter> {
    @Published var lastOperation: Orientation? {
        willSet {
            if lastOperation != nil, lastOperation != newValue {
                reversed = lastOperation == .mirror
            }
        }
    }
    @Published var orientationFilters = Orientation.allCases
    @Published var reversed: Bool = false
    
    init() {
        super.init(type: .crop)
    }
    
    override var appliableFilters: [OrientationFilter] {
        return filters.reversed()
    }
    
    //calculul orientarii in functie de daca se aplica o oglindire atunci cand imaginea este rotita
    var orientationInUI: UIImage.Orientation {
        let mirror = filters[0].currentOrientation * 4
        var rotation = 0
        switch filters[1].currentOrientation {
        case 0:
            rotation = 0
        case 1:
            rotation = 3
        default:
            rotation = (filters[1].currentOrientation)-1
        }
        return UIImage.Orientation(rawValue: mirror + rotation) ?? UIImage.Orientation.up
    }
    
    func update(by operation: Orientation) {
        filters[0].update(by: operation)
    }
}

class CropGroup: EveryFilterGroup<CropFilter> {
    var maxWidth: CGFloat
    var maxHeight: CGFloat
    init(with image: CIImage?) {
        maxWidth = image?.extent.width ?? 0.0
        maxHeight = image?.extent.height ?? 0.0
        super.init(type: .crop)
        filters = [CropFilter(with: image?.extent ?? .zero)]
    }
    
    func registerCropUndo(on undoManager: UndoManager?, from oldValue: CGRect, to newValue: CGRect) {
        undoManager?.registerUndo(withTarget: self, handler: { handler in
            handler.registerCropUndo(on: undoManager, from: newValue, to: oldValue)
            handler.filters[0].cropRect = oldValue
        })
    }
    
    //recalcularea pozitionarii dreptunghiului de crop la rotire sau oglindire. acest lucru este necesar pentru actualizarea dreptunghiului de decupare din ui
    //coordonatele punctelor au fost calculate dupa matrici de operatii afine, la fel cum au fost descrise in capitolul 4.2 al documentatiei
    func update(by filter: Orientation) {
        let previousRect = filters[0].cropRect
        switch filter {
        case .mirror:
            filters[0].cropRect = CGRect(x: maxWidth - filters[0].cropRect.origin.x - filters[0].cropRect.width, y: filters[0].cropRect.origin.y, width: filters[0].cropRect.width, height: filters[0].cropRect.height)
        case .rotate:
            filters[0].cropRect = CGRect(x: filters[0].cropRect.origin.y, y:  maxWidth - filters[0].cropRect.origin.x - filters[0].cropRect.width, width: filters[0].cropRect.height, height: filters[0].cropRect.width)
            swap(&maxWidth, &maxHeight)
        }
    }
}
