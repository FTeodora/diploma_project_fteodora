//
//  CGPoint+inScale.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 8/29/23.
//

import Foundation

extension CGPoint {
    //punctul rescalat in alt spatiu de coordonate
    func inScale(scaleX: CGFloat, scaleY: CGFloat) -> CGPoint {
        return CGPoint(x: x * scaleX, y: y * scaleY)
    }
    
    //punctul transpus din coordonate ecran in coordonate imagine
    func toImageCoords(height: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: height - y)
    }
}
