//
//  RegisterView.swift
//  Licenta
//
//  Created by Fariseu, Teodora on 8/12/23.
//

import SwiftUI

//o componenta de textfield cu validate
struct ValidatedField: View {
    @FocusState private var isFocused: Bool
    @Binding var text: String
    @State var errorMessage: String = ""
    var label: String
    var isPassword: Bool = false
    var validateField: () -> String
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(label):")
                    .font(.callout)
                Spacer()
            }
            Group {
                if isPassword {
                    SecureField(label, text: $text)
                } else {
                    TextField(label, text: $text)
                        .autocorrectionDisabled()
                }
            }.focused($isFocused)
            .onChange(of: isFocused) { isFocused in
                guard !isFocused else { return }
                errorMessage = validateField()
            }.frame(maxWidth: .infinity)
            .textFieldStyle(.roundedBorder)
            
            //afisarea mesajului de eroare sub textfield-ul corespunzator
            Text(errorMessage)
                .lineLimit(nil)
                .foregroundColor(.red)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.leading)
        }.padding()
    }
}

//ecranul de creare cont
struct RegisterView: View {
    @StateObject var viewModel: RegisterViewModel
    @State private var errorMsg = ""
    
    var body: some View {
        VStack {
            ValidatedField(text: $viewModel.username, label: "Username") {
                viewModel.isUsernameValid ? "" : "Username must be at least 6 characters long and not contain spaces"
            }
            ValidatedField(text: $viewModel.password, label: "Password", isPassword: true) {
                viewModel.isPasswordValid ? "" : "Password must be at least 6 characters long and must contain at least a digit and a character"
            }
            ValidatedField(text: $viewModel.confirmPassword, label: "Confirm password", isPassword: true) {
                viewModel.isConfirmPasswordValid ? "" : "Passwords do not match"
            }
            
            Spacer()
            Text(errorMsg)
                .foregroundColor(.red)
                .font(.callout)
                .lineLimit(nil)
            Button("Register") {
                guard viewModel.isUsernameValid && viewModel.isPasswordValid && viewModel.isConfirmPasswordValid else { return }
                Task {
                    do {
                        let user = try await viewModel.checkUsername()
                        guard user == nil else { errorMsg = "Username already exists" ; return }
                        try viewModel.registerUser()
                        errorMsg = "Account created"
                    } catch (let error) {
                        errorMsg = error.localizedDescription
                    }
                }
            }.padding()
            
        }
        .navigationTitle("Create account")
    }
}
