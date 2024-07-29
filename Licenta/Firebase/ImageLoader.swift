//
//  ImageLoader.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 7/30/23.
//

import Foundation
import UIKit
import FirebaseStorage

//Clasa care incarca imaginile din Firebase Storage
class ImageLoader: ObservableObject {
    @Published var uiImage: UIImage?
    @Published var isLoading = false
    var storage: Storage
    var url: String
    
    init(storage: Storage, url: String) {
        self.storage = storage
        self.url = url
    }
    
    //incarca imaginea de la url-ul indicat in variabilele instanta
    func loadImage() {
        isLoading = true
        let pathReference = storage.reference(withPath: url)
        
        pathReference.getData(maxSize: 1024 * 1024 * 1024) { [weak self] data, error in
        if let error = error {
            print("Error occured while downloading image \(error)")
        } else {
            guard let data = data else { return }
            self?.uiImage = UIImage(data: data)
        }
            self?.isLoading = false
        }
    }
}
