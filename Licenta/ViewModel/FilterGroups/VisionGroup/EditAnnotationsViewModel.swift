//
//  EditAnnotationsViewModel.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 7/22/23.
//

import Foundation
import Combine
import UIKit
import SwiftUI
  
//linia desenata pe ecran de utilizator.
struct Line {
    var points = [CGPoint]()
    var color: UIColor = .red
    var lineWidth: Double = 1.0
    var modelClass: ModelClass?
}

class EditAnnotationsViewModel: ObservableObject {
    var baseImage: UIImage
    var segmentationMap: CGImage?
    @Published var isAddingClass = false
    @Published var annotationsPreview: UIImage?
    //clasa curenta cu care se adnoteaza
    @Published var selectedClass: ModelClass? {
        didSet {
            guard let selectedClass = selectedClass else { return }
            currentLine.color = selectedClass.color
            currentLine.modelClass = selectedClass
        }
    }
    @Published var currentLine = Line(lineWidth: 8.0)
    @Published var lines: [Line] = []
    @Published var thickness: Double = 8.0 {
        didSet {
            currentLine.lineWidth = thickness
        }
    }
    @Published var previewDot: Bool = false
    var proxy: CGSize = .zero
    var poppedLines: [Line] = []
    
    init(baseImage: UIImage, annotationsPreview: UIImage? = nil) {
        self.baseImage = baseImage
        self.annotationsPreview = annotationsPreview
    }
    
    //elimina ultima linie introdusa de utiliztor
    func undo() {
        guard !lines.isEmpty else { return }
        let lastLine = lines.removeLast()
        poppedLines.append(lastLine)
    }
    
    //reintroduce linia eliminata prin undo
    func redo() {
        guard !poppedLines.isEmpty else { return }
        let lastLine = poppedLines.removeLast()
        lines.append(lastLine)
    }
    
    //resetarea adnotarilor la inchidere
    func updateAnnotations() {
        self.segmentationMap = updateSegmentationMap()
        lines = []
        poppedLines = []
    }
    
    //functia care redeseneaza adnotarile
    func updateSegmentationMap() -> CGImage? {
        guard let segmentationMap = segmentationMap else { return segmentationMap }
        let width = segmentationMap.width
        let height = segmentationMap.height
        let bounds = CGRect(x: 0, y:0, width: width, height: height)
        //redesenarea se realizeaza printr-un context care va realiza operatiile grafice precum desenarea
        guard let cgContext = CGContext(data: nil,
                                      width: width, height: height,
                                      bitsPerComponent: 8 ,
                                      bytesPerRow: width * 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return segmentationMap }
        cgContext.saveGState()
        //dezactivarea antialias-ului deoarece este nevoie ca pixelii sa fie de o singura culoare exacta pentru autenticitatea hartii
        //daca nu s-ar dezactiva antialias-ul, s-ar introduce noi clase neasteptate datorita interpolarii cu vecinii realizate de acesta
        cgContext.setShouldAntialias(false)
        //desenarea imaginii la baza
        cgContext.draw(segmentationMap, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let xScale = CGFloat(width)/proxy.width
        let yScale = CGFloat(height)/proxy.height
        //rescalarea grosimii liniei din spatiul ecranului in spatiul imaginii
        //grosimea liniei are un aspect ratio de 1.0, avand latimea egala cu inaltimea
        let weightScale = max(xScale, yScale)
        
        //parcurgerea fiecarei linii pentru desenare
        lines.forEach { line in
            guard let startPoint = line.points.first?.inScale(scaleX: xScale, scaleY: yScale).toImageCoords(height: CGFloat(height)) else { return }
            cgContext.setLineWidth((line.lineWidth) * weightScale)
            
            let label = CGFloat(line.modelClass?.orderNumber ?? 0)
            
            cgContext.setStrokeColor(CGColor(genericGrayGamma2_2Gray: (label+0.1)/255.0, alpha: 1.0))
            
            cgContext.move(to: startPoint)
            cgContext.beginPath()
            line.points.forEach { point in
                //fiecare punct trebuie transpus din coordonate ecran in coordonate imagine prin inversarea axei Oy
                let point = point.inScale(scaleX: xScale, scaleY: yScale).toImageCoords(height: CGFloat(height))
                cgContext.addLine(to: point)
                cgContext.move(to: point)
            }
            //la final se traseaza linia prin punctele adaugate
            cgContext.strokePath()
        }
        //preluarea imaginii finale din contextul grafic
        let map = cgContext.makeImage()
        cgContext.restoreGState()
        return map
    }
}
