//
//  CloudImage.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 7/30/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum Folders: String {
    case image, annotation, thumbnail
    
    var defaultExtension: String {
        switch self {
        case .image, .thumbnail:
            return "jpg"
        case .annotation:
            return "png"
        }
    }
}


struct CloudImage: Codable {
    @DocumentID var id: String? = UUID().uuidString.lowercased()
    var name: String
    var fileExtension: String
    var lastUpdated: Date
    var user: String
}

extension CloudImage: Comparable, Identifiable {
    static func < (lhs: CloudImage, rhs: CloudImage) -> Bool {
        return lhs.lastUpdated < rhs.lastUpdated
    }
    
    
    func save(to db: Database) throws {
        try db.add(in: "images", item: self)
    }
    
    static func images(from db: Database, for user: String) async throws -> [CloudImage]? {
        return try await db.getRecords(from: "images", having: ["user": user])?.sorted()
    }
    
    func generateUrl(for folder: Folders = .image) -> String {
        guard let id = id else { return ""}
        return "\(folder.rawValue)/\(id).\(folder == .image ? fileExtension : folder.defaultExtension)"
    }
}
