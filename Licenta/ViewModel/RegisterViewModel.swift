//
//  RegisterViewModel.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 8/12/23.
//

import Foundation
import Combine

class RegisterViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    var db: Database
    
    init(db: Database) {
        self.db = db
    }
    
    //validarea pentru username
    var isUsernameValid: Bool {
        return username.count >= 6 && !username.contains("[ ]+")
    }
    
    //validarea pentru parola
    var isPasswordValid: Bool {
        return password.count >= 6 && password.range(of: "[a-zA-z]+[0-9]+",  options: .regularExpression) != nil
    }
    
    // confirmare parola
    var isConfirmPasswordValid: Bool {
        return password == confirmPassword
    }
    
    //adauga utilizatorul in baza de date
    func registerUser() throws {
        try User(id: UUID().uuidString.lowercased(), username: username, password: password).save(to: db)
    }
    
    //validare in plus pentru a vedea daca un username exista
    func checkUsername() async throws -> User? {
        try await User(username: username, password: password).checkForUsername(in: db)
    }
}
