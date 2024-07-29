//
//  AffineFilter.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/7/23.
//

import Foundation
import CoreImage
import SwiftUI

//filtrele pentru operatii afine

//decupare
class CropFilter: Filter {
    @Published var cropRect: CGRect
    init(with cropRect: CGRect) {
        self.cropRect = cropRect
    }
    
    func apply(input: CIImage) -> CIImage? {
        input.cropped(to: cropRect)
    }
}

//filtru pentru orientare. orientarea este pastrata sub forma de numar care este transformat intr-o anumita orientare
class OrientationFilter: Filter {
    @Published var currentOrientation: Int = 0
    
    func apply(input: CIImage) -> CIImage? {
        return input.oriented(Orientation.possibleOrientations[currentOrientation])
    }
    
    //actualizeaza orientarea in functie de oglindire sau rotatie
    func update(by orientation: Orientation) {
        currentOrientation = orientation.update(from: currentOrientation)
    }
}

//operatiile de schimbare a orientarii
enum Orientation: SelectableFilter {
    case mirror, rotate
    
    var displayName: String {
        return ""
    }
    
    var icon: Image {
        switch self {
        case .mirror:
            return Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill")
        case .rotate:
            return Image(systemName: "rotate.right")
        }
    }
    
    //orientarile posibile, a caror ordine este specifica
    static var possibleOrientations: [CGImagePropertyOrientation] {
        [CGImagePropertyOrientation.up, CGImagePropertyOrientation.right, CGImagePropertyOrientation.down, CGImagePropertyOrientation.left, CGImagePropertyOrientation.upMirrored, CGImagePropertyOrientation.rightMirrored, CGImagePropertyOrientation.downMirrored, CGImagePropertyOrientation.leftMirrored]
    }
    
    //actualizarea in functie de orientarea aplicata
    func update(from currentOrientation: Int) -> Int {
        switch self {
        case .mirror:
            var newOrientation = currentOrientation
            //daca imaginea este rotita in anumite pozitii atunci cand se realizeaza o oglindire, trebuie aplicata o verificare in plus
            //deoarece rotirea la dreapta sau stanga rezulta intro imagine perpendiculara pe cea originala, axele sale se schimba, deci
            //oglindirea se va realiza pe axe diferite
            if currentOrientation%2 == 1 {
                newOrientation = rotate(currentOrientation, by: 2)
            }
            return (newOrientation + 4) % 8
        case .rotate:
            return rotate(currentOrientation, by: 1)
        }
    }
    
    func rotate(_ currentOrientation: Int, by iteration: Int) -> Int {
        4 * (currentOrientation/4) + (currentOrientation + iteration) % 4
    }
}
