//
//  WelcomePageViewModel.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/16/23.
//

import SwiftUI
import Combine
import Vision
import Firebase
import FirebaseStorage

class WelcomePageViewModel: ObservableObject {
    @Published var clipboardImage: UIImage?
    @Published var pickedImage: UIImage? {
        didSet {
            guard pickedImage != nil else { return }
            didPickImage = true
        }
    }
    @Published var didPickImage = false
    @Published var didSelectImage = false
    @Published var selectedImage: CloudImage? {
        didSet {
            guard selectedImage != nil else { return }
            didSelectImage = true
        }
    }
    @Published var userId: String?
    
    var model: VNCoreMLModel?
    
    init() {
        //incarcarea modelului in prima pagina a aplicatiei pentru a nu fi reincarcat la fiecare imagine deschisa
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndGPU
        let imageClassifierWrapper = try? DeepLab(configuration: config)
        let imageClassifierModel = imageClassifierWrapper?.model
        guard let imageClassifierModel = imageClassifierModel else { return }
        model = try? VNCoreMLModel(for: imageClassifierModel)
    }
}
