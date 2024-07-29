//
//  LoginView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 8/12/23.
//

import SwiftUI

//ecranul de login
struct LoginView: View {
    @Binding var userId: String?
    @State var errorMessage = ""
    @StateObject var viewModel: LoginViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Username", text: $viewModel.username)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                Text(errorMessage)
                    .font(.callout)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                
                Text("Login")
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                .onTapGesture {
                    Task {
                        do {
                            let user = try await viewModel.checkCredentials()
                            guard let user = user else { errorMessage = "Incorrect username or password"; return }
                            errorMessage = ""
                            userId = user.id
                            dismiss()
                        } catch (let error) {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .padding()
                
                NavigationLink {
                    RegisterView(viewModel: RegisterViewModel(db: viewModel.db))
                        .frame(maxWidth: .infinity)
                } label: {
                    Text("Register")
                }
            }
        }.padding()
        .navigationTitle("")
    }
}
