//
//  LoginViewModel.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 8/12/23.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    
    var db: Database
    
    init(db: Database) {
        self.db = db
    }
    
    //realizeaza logarea prin verificarea daca exista un user cu username-ul si parola introduse
    func checkCredentials() async throws -> User? {
        try await User(username: username, password: password).checkCredentials(in: db)
    }
}
