//
//  ObjectsGroup.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/2/23.
//

import Foundation
import Vision
import CoreML
import UIKit
import SwiftUI
import Combine

//ViewModel-ul pentru obiectele din imagine. Acestea sunt prelucrate ca selectie sub forma de masca de pixeli
class ObjectsGroup: SingleFilterGroup<PredictionMaskFilter> {
    //modurile pentru prelucrarea unei selectii. Remove elimina restul selectiei, color o inlocuieste cu o culoare,
    //image cu o alta imagine, iar blur blureaza restul selectiei
    enum BackgroundMode: String, CaseIterable {
        case remove, color, image, blur
    }
    //modelul care realizeaza predictia
    var model: VisionModel?
    //imaginea originala. aceasta este folosita pentru optiunea de blur
    var image: CIImage?
    //filtrul de blur care blureaza restul imaginii
    @Published var blurFilter = OneValueFilter<BlurMode>(type: .background) {
        didSet {
            guard let image = image else { return }
            bgImage = blurFilter.apply(input: image)?.uIImage
        }
    }
    //modul selectat pentru masca
    @Published var selectedMode: BackgroundMode {
        didSet {
            registerModeUndo(from: oldValue, to: selectedMode)
            bgImage = imageMode
        }
    }
    
    //harta de adnotare de rezolutie redusa care este folosita pentru filtrele propriu-zise
    //atunci cand aceasta se schimba, trebuie refacute mastile pentru obiectele din imagine
    @Published var predictionMaskResized: CGImage? {
        didSet {
            guard let predictionMask = predictionMask, let predictionMaskResized = predictionMaskResized else { return }
            filters = predictionMaskResized.classes().map { PredictionMaskFilter(predictionClass: $0) }
            selectedFilter = nil
            guard let previewMap = predictionMaskResized.previewMap() else { return }
                    editAnnotationsViewModel?.annotationsPreview = UIImage(cgImage: previewMap.resize(size: CGSize(width: predictionMask.width, height: predictionMask.height))!)
            updateMasks()
        }
    }
    
    //masca de predictie la rezolutie completa
    //cand aceasta se schimba, ea actualizeaza automat variabila pentru harta redimensionata
    @Published var predictionMask: CGImage? {
        didSet {
            guard let predictionMask = predictionMask else { return }
            let scale = 320.0/Double(max(predictionMask.width, predictionMask.height))
            editAnnotationsViewModel?.segmentationMap = predictionMask
            //actualizarea mastii de predictie redimensionata la 320 pe dimensiunea maxima, pastrand aspect ratio-ul
            //aceasta actualizare declanseaza o reactie in lant
            predictionMaskResized = predictionMask.resize(size: CGSize(width: Double(predictionMask.width) * scale, height: Double(predictionMask.height) * scale))
        }
    }
    
    //inversarea zonei mascate
    @Published var inverted: Bool = false {
        didSet {
            for i in 0..<filters.count {
                filters[i].inverted = inverted
            }
        }
    }
    
    //imaginea care se foloseste pentru fundal
    @Published var bgImage: UIImage? {
        didSet {
            filters.forEach { mask in
                if let bgImage = bgImage {
                    mask.background = CIImage(image: bgImage)
                } else {
                    mask.background = nil
                }
            }
        }
    }
    
    //culoarea pentru modul de culoare
    @Published var color: Color = Color(.sRGB, red: 0.98 , green: 0.99, blue: 0.98)
    {
        didSet {
            registerColorUndo(from: oldValue, to: color)
            if selectedMode == .color {
                bgImage = UIImage(color: UIColor(color), size: CGSize(width: 100.0, height: 100.0))
            }
        }
    }
    
    //imaginea selectata in modul de imagine
    @Published var pickedImage: UIImage? {
        didSet {
            registerImageUndo(from: oldValue, to: pickedImage)
            if selectedMode == .image {
                bgImage = pickedImage
            }
        }
    }
    
    //genereaza imaginea in functie de modul selectat
    var imageMode: UIImage? {
        switch selectedMode {
        case .remove:
            return nil
        case .color:
            return UIImage(color: UIColor(color), size: CGSize(width: 100.0, height: 100.0))
        case .image:
            return pickedImage
        case .blur:
            guard let image = image else { return nil }
            return blurFilter.apply(input: image)?.uIImage
        }
    }
    
    //viewmodel-ul pentru fereastra de editare de adnotari care este deschisa
    var editAnnotationsViewModel: EditAnnotationsViewModel?
    
    //initializarea de la o imagine locala, avand modelul pentru a realiza predictia
    convenience init(with model: VNCoreMLModel? = nil, for image: UIImage?) {
        self.init(for: image)
        self.model = VisionModel(with: model) { [weak self] segmentationMap in
            let imageBounds = image?.size ?? .zero
            self?.predictionMask = segmentationMap.labelsToImage(with: imageBounds)
        }
    }
    //initializarea de la o imagine cloud. in cazul acesta nu este nevoie de o predictie intermediara, ci harta e initializata
    //direct cu cea existenta
    convenience init(with existingAnnotations: CGImage?, for image: UIImage?) {
        self.init(for: image)
        predictionMask = existingAnnotations
        editAnnotationsViewModel?.segmentationMap = existingAnnotations
    }
    
    //un init care incapsuleaza partea comuna a celor doua initializari
    private init(for image: UIImage?) {
        if let image = image {
            editAnnotationsViewModel = EditAnnotationsViewModel(baseImage: image)
            self.image = CIImage(image: image)
        }
        self.selectedMode = .remove
        super.init(type: .object)
    }
    
    //actualizeaza mastile atunci cand se schimba harta de predictii redimensionata
    func updateMasks() {
        guard let predictionMaskResized = predictionMaskResized else { return }
        for i in 0..<filters.count {
            filters[i].computeMask(from: predictionMaskResized)
        }
    }
    
    //initializarea predictiei cu un model de coreML
    func initializePrediction(with image: CIImage?) {
        let context = CIContext(options: nil)
        guard let image = image, let cgImage = context.createCGImage(image, from: image.extent) else { return }
        model?.predict(on: cgImage)
        self.image = image
    }
    
    func registerModeUndo(from oldValue: BackgroundMode, to newValue: BackgroundMode) {
        undoManager?.registerUndo(withTarget: self) { handler in
            handler.registerModeUndo(from: newValue, to: oldValue)
            handler.selectedMode = oldValue
        }
    }
    
    func registerInvertUndo() {
        undoManager?.registerUndo(withTarget: self) { handler in
            handler.registerInvertUndo()
            handler.inverted.toggle()
        }
    }
    
    func registerImageUndo(from oldValue: UIImage?, to newValue: UIImage?) {
        undoManager?.registerUndo(withTarget: self, handler: { handler in
            handler.registerImageUndo(from: newValue, to: oldValue)
            handler.pickedImage = oldValue
        })
    }
    
    func registerColorUndo(from oldValue: Color, to newValue: Color) {
        undoManager?.registerUndo(withTarget: self, handler: { handler in
            handler.registerColorUndo(from: newValue, to: oldValue)
            handler.color = oldValue
        })
    }
}

//filtreul care aplica blur pe imaginea din modul de blur
enum BlurMode: CoreImageFunctionFilterType {
    var variableField: String {
        return kCIInputRadiusKey
    }
    
    var filterName: String {
        return "CIDiscBlur"
    }
    
    var displayName: String {
        "Blur"
    }
    
    case background
    
    var range: ClosedRange<Double>? {
        (0.0...25.0)
    }
}
