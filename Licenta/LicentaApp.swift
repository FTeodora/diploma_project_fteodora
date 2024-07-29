//
//  LicentaApp.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 5/10/23.
//

import SwiftUI

//endpoint-ul principal prin care e expusa aplicatia
@main
struct LicentaApp: App {
    @State var isEditing = true
    var body: some Scene {
        WindowGroup {
            WelcomePage()
        }
    }
}

let darkGray = Color("backgroundGray")
