//
//  UIImage.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 6/15/23.
//

import Foundation
import UIKit
import FirebaseStorage
import Combine

//Extensii pentru UIIMage din UIKit
public extension UIImage {
    //initializeaza o imagine de o anumita dimensiune umpluta cu o culoare
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIImage {
    //calculeaza dimensunea imaginii relativa la un proxy in functite de dimensiunea maximas
    public func getScaledSize(relativeTo proxy: CGSize) -> CGSize {
        let scale = size.getScale(relativeTo: proxy)
        return size.height > size.width ? CGSize(width: size.width * scale, height: proxy.height) : CGSize(width: proxy.width, height: size.height * scale)
    }
    
    //calculeaza dimensiunile imaginii daca dimensiunea maxima a acesteia ar fi numarul dat ca parametru
    public func scaledToMaxSize(sizeValue: CGFloat) -> CGSize {
        let scale = sizeValue / max(size.height, size.width)
        return CGSize(width: size.width * scale, height: size.height * scale) 
    }
}

extension UIImage {
    //incarca imaginea pe storage-ul din Firebase la un anumit url
    func upload(to url: String, on storageRef: StorageReference, fileExtension: String) -> StorageUploadTask {
        do {
            let ref = storageRef.child(url)
            let metadata = StorageMetadata()
            metadata.setValue("image/\(fileExtension)", forKeyPath: "contentType")
            let data = fileExtension == "png" ? pngData() : jpegData(compressionQuality: 0.85)
            let uploadTask = ref.putData(data!, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else { print("Upload error \(error)"); return }
            }
            return uploadTask
        } catch {
            print("Couldn't upload photo to server: \(error)")
        }
    }
}
