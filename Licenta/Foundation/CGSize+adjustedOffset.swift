//
//  CGSize+adjustedOffset.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/22/23.
//

import Foundation

extension CGSize {
    //calculeaza offset-ul unei imagini centrate intr-un superview in functie de dimensiunea sa maxima
    public func adjustedOffset(relativeTo proxy: CGSize) -> CGSize {
        let offset = height > width ? (proxy.width - width)/2 : (proxy.height - height)/2
        var adjusted: CGSize = .zero
        if height > width {
            adjusted.width = offset
        } else {
            adjusted.height = offset
        }
        return adjusted
    }
    
    //calculeaza scala relativa la alta dimensiune, pastrand aspect ratio-ul imaginii originale
    public func getScale(relativeTo proxy: CGSize) -> Double {
        width < height ? proxy.height/height : proxy.width/width
    }
}
