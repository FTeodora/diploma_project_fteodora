//
//  FilterViewModel.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/20/23.
//

import Foundation
import Combine
import Vision
import CoreImage
import UIKit
import FirebaseStorage

//ViewModel-ul pentru ecranul de editare de imagine. @MainActor indica faptul ca functiile sale sunt executate in fundal si
//rezultatul lor este transmis mai departe pe thread-ul principal
@MainActor
class FilterViewModel: ObservableObject {
    //initializarea filtrelor posibile
    //pentru restul de filtre, se va face initializarea in init-ul corespunzator
    @Published var filterGroups: [FilterCategory: any FilterGroup] = [.color: EveryFilterGroup<OneValueFilter<ColorFilters>>(type: .color),
                                                                      .light: EveryFilterGroup<OneValueFilter<LightFilters>>(type: .light),
                                                                      .filters: SingleFilterGroup<OneValueFilter<ImageFilterFilters>>(type: .filters),
                                                                      .grad: GradientGroup()]
    
    //pastrarea separata a dreptunghiului de decupare
    @Published var cropGroup: CropGroup {
        didSet {
            (filterGroups[.paint] as? DrawingsGroup)?.updateBounds(with: cropGroup.filters[0].cropRect)
        }
    }
    
    //filtrul curent selectat
    @Published var selectedCategory: FilterCategory? {
        didSet {
            (filterGroups[.paint] as? DrawingsGroup)?.isDrawing = selectedCategory == .paint
        }
    }
    
    @Published var imageLoader: ImageLoader?
    @Published var annotationLoader: ImageLoader?
    @Published var isLoading = false
    
    weak var baseImage: CIImage?
    var imageProject: CloudImage?
    var storage: Storage
    var db: Database
    
    var isLoadingPublisher: AnyCancellable?
    var imagePublisher: AnyCancellable?
    var imageSubscriptions = Set<AnyCancellable?>()
    var currentUser: String?
    
    //initializarea pentru imagini locale
    init(for currentUser: String?, with image: CIImage?, orientation: UIImage.Orientation, model: VNCoreMLModel?, storage: Storage, db: Database) {
        
        self.db = db
        self.storage = storage
        self.currentUser = currentUser
        
        
        let orientationFix = OrientationFilter()
        switch orientation {
        case .up:
            orientationFix.currentOrientation = 0
        case .right:
            orientationFix.currentOrientation = 1
        case .down:
            orientationFix.currentOrientation = 2
        case .left:
            orientationFix.currentOrientation = 4
        case .upMirrored:
            orientationFix.currentOrientation = 5
        case .rightMirrored:
            orientationFix.currentOrientation = 6
        case .downMirrored:
            orientationFix.currentOrientation = 7
        case .leftMirrored:
            orientationFix.currentOrientation = 8
        @unknown default:
            orientationFix.currentOrientation = 0
        }
        
        if let image = image {
            baseImage = orientationFix.apply(input: image)
        } else {
            baseImage = image
        }
        cropGroup = CropGroup(with: baseImage)
        
        filterGroups[.crop] = AffineGroup()
        filterGroups[.object] = ObjectsGroup(with: model, for: image?.uIImage)
        filterGroups[.effects] = EffectFilterGroup(with: image)
        filterGroups[.paint] = DrawingsGroup(with: image?.extent)
    }
    
    //initializarea pentru o imagine din cloud
    init(with storage: Storage, db: Database, loading image: CloudImage) {
        self.imageProject = image
        self.db = db
        self.storage = storage
        self.currentUser = image.user
        cropGroup = CropGroup(with: nil)
        imageLoader = ImageLoader(storage: storage, url: image.generateUrl(for: .image))
        annotationLoader = ImageLoader(storage: storage, url: image.generateUrl(for: .annotation))
        setupBindings()
    }
    
    //o functie care stabileste handling-ul pentru primirea de rezultate de la anumite task-uri de fundal
    func setupBindings() {
        isLoadingPublisher = imageLoader?.$isLoading.combineLatest(annotationLoader!.$isLoading)
            .sink { isLoadingImage, isLoadingAnnotations in
                self.isLoading = isLoadingImage || isLoadingAnnotations
        }
        
        imagePublisher = imageLoader?.$uiImage.combineLatest(annotationLoader!.$uiImage)
            .sink { [weak self] image, annotationMap in
                guard let image = image, let annotationMap = annotationMap else { return }
                let ciImage = CIImage(image: image)
                self?.filterGroups[.effects] = EffectFilterGroup(with: ciImage)
                self?.filterGroups[.paint] = DrawingsGroup(with: ciImage?.extent)
                self?.cropGroup = CropGroup(with: ciImage)
                self?.filterGroups[.crop] = AffineGroup()
                self?.baseImage = ciImage
                self?.filterGroups[.object] = ObjectsGroup(with: annotationMap.cgImage, for: image)
                self?.objectWillChange.send()
            }
    }
    
    //toate filtrele aplicate pe imagine
    var currentFilters: [any FilterGroup] {
        filterGroups.sorted { lhs, rhs in
            lhs.key.applyIndex < rhs.key.applyIndex
        }.map { $0.value } + [cropGroup]
    }
    
    func makePreview() -> UIImage? {
        currentFilters
            .flatMap { $0.appliableFilters }
            .reduce(baseImage) { partialResult, filter in
                guard let partialResult = partialResult, let output = filter.apply(input: partialResult) else { return partialResult }
                return output
            }?.uIImage
    }
    
    //initializarea hartii de predictie din cloud sau din model
    func initializePrediction(with image: CIImage) {
        guard let annotationLoader = annotationLoader else { (filterGroups[.object] as? ObjectsGroup)?.initializePrediction(with: image); return }
        annotationLoader.loadImage()
    }
    
    //incarcarea imaginii din cloud
    func loadBaseImage() {
        imageLoader?.loadImage()
        annotationLoader?.loadImage()
    }
    
    //incarcarea imaginii pe cloud
    func saveImageToCloud() {
        let storageRef = storage.reference()
        if imageProject != nil {
            //daca imaginea exista deja pe cloud, doar se actualizeaza data la care a fost modificata
            self.imageProject?.lastUpdated = Date()
        } else {
            //daca nu, se incarca thumbnail-ul si imaginea originala pe langa adnotari
            guard let currentUser = currentUser else { return }
            imageProject = CloudImage(name: "\(Int(Date().timeIntervalSince1970))", fileExtension: "jpg", lastUpdated: Date(), user: currentUser)
            baseImage?.uIImage?.upload(to: imageProject!.generateUrl(for: .image), on: storageRef, fileExtension: "jpeg")
            let thumbnail = UIImage(ciImage: (baseImage?.scaleFill(to: (baseImage?.uIImage?.scaledToMaxSize(sizeValue: 300))!))!)
            thumbnail.upload(to: imageProject!.generateUrl(for: .thumbnail), on: storageRef, fileExtension: "jpeg")
        }
        do {
            try imageProject?.save(to: db)
            UIImage(cgImage: (filterGroups[.object] as! ObjectsGroup).predictionMask!).upload(to: imageProject!.generateUrl(for: .annotation), on: storageRef, fileExtension: "png")
        } catch {
            print("Couldn't upload photo to server: \(error)")
        }
    }
}
