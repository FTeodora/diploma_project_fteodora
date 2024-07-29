//
//  User.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 8/12/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

//entitatea pentru un document din colectia de user
struct User: Codable {
    @DocumentID var id: String? = UUID().uuidString.lowercased()
    var username: String
    var password: String
}

extension User: Identifiable {
    //cautarea unui user cu username-ul si parola pt logare
    func checkCredentials(in db: Database) async throws -> User? {
        try await db.getRecord(from: "users", having: ["username": username, "password": password])
    }
    
    //verificarea daca username-ul exista la inregistrare
    func checkForUsername(in db: Database) async throws -> User? {
        try await db.getRecord(from: "users", having: ["username": username])
    }
    
    //inregistrarea unui user in baza de date
    func save(to db: Database) throws {
        try db.add(in: "users", item: self)
    }
}
