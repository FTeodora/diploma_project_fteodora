//
//  Database.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 7/30/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Clasa pentru interogarile pe baza de date de Firebases
class Database: ObservableObject {
    var db: Firestore
    init(db: Firestore) {
        self.db = db
    }
    
    //cauta un singur document dupa id
    func getRecord<T: Decodable>(from collection: String, with id: String) async throws -> T? {
        try await db.collection(collection).document(id).getDocument(as: T.self, decoder: Firestore.Decoder())
    }
    
    //cauta un singur document dupa filtre legate de campurile documentului. filtrele sunt filtre de egalitate
    //intre care exista relatie logica de si
    func getRecord<T:Decodable>(from collection: String, having filters: [String: Any]) async throws -> T? {
        try await filters.reduce(db.collection(collection)) { partialResult, field in
            partialResult.whereField(field.key, isEqualTo: field.value)
        }.getDocuments().documents.compactMap { document in
            try? document.data(as: T.self, decoder: Firestore.Decoder())
        }.first
    }
    
    //la fel ca si functia anterioara, doar ca pentru o lista de documente. filtrele au aceeasi logica(egal si and)s
    func getRecords<T:Decodable>(from collection: String, having filters: [String: Any]) async throws -> [T]? {
        try await filters.reduce(db.collection(collection)) { partialResult, field in
            partialResult.whereField(field.key, isEqualTo: field.value)
        }.getDocuments().documents.compactMap { document in
            try? document.data(as: T.self, decoder: Firestore.Decoder())
        }
    }
    
    //toate documentele dintr-o colectie
    func getRecords<T: Decodable>(from collection: String) async throws -> [T]? {
        try await db.collection(collection).getDocuments().documents.compactMap { document in
            try? document.data(as: T.self, decoder: Firestore.Decoder())
        }
    }
    
    //toate documentele unde un singur field este egal cu o valoare
    func getRecords<T: Decodable>(from collection: String, with field: String, equalTo value: Any) async throws -> [T]? {
        try await db.collection(collection).whereField(field, isEqualTo: value).getDocuments().documents.compactMap { document in
            try? document.data(as: T.self, decoder: Firestore.Decoder()) }
    }
    
    //insereaza un document in baza de date
    func add<T: Encodable&Identifiable>(in collection: String, item: T) throws {
        try db.collection(collection).document(item.id as! String).setData(Firestore.Encoder().encode(item))
    }
}
