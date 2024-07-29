//
//  VisionModel.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/29/23.
//

import Foundation
import CoreML
import Vision
import Combine

//Modelul de CoreML incarcat in aplicatie
class VisionModel {
    var modelRequest: VNCoreMLRequest?
    var handler: VNImageRequestHandler?
    
    init(with model: VNCoreMLModel?, onPrediction: @escaping (MLMultiArray) -> Void = { _ in }) {
        guard let model = model else { return }
        //request-ul pentru predictii la model
        //functia cu care se initializata va fi apelata la predictie
        modelRequest = VNCoreMLRequest(model: model) { request, error in
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
               let segmentationmap = observations.first?.featureValue.multiArrayValue {
                onPrediction(segmentationmap)
            }
        }
        modelRequest?.imageCropAndScaleOption = .scaleFill
    }
    
    //apeleaza request-ul de predictie
    func predict(on image: CGImage) {
        //spune modelului cu ce orientare este trimisa imaginea si lanseaza request-ul in executie
        handler = VNImageRequestHandler(cgImage: image, orientation: .up)
        guard let modelRequest = modelRequest else { return }
        do {
            try handler?.perform([modelRequest])
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
}
