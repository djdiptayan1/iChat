//
//  RegisterView.swift
//  iChat
//
//  Created by Diptayan Jash on 15/01/24.
//

import Firebase
import Foundation
import SwiftUI

struct RegisterView: View {
    let generator = UIImpactFeedbackGenerator(style: .medium)

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = ""
    
    @State private var shouldShowImagePicker = false
    @State private var selectedImage: Image?
    
    var body: some View {
        VStack {
            Button {
                    //display Image
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding()
                }

            TextField("Username", text: $email)
                .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(5)
            SecureField("Password", text: $password)
                .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(5)
            SecureField("Confirm Password", text: $confirmPassword)
                .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(5)
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button {
                registerUser()
            } label: {
                Text("Register")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(password != confirmPassword)
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        withAnimation {
                            generator.impactOccurred()
                        }
                    }
            )
            Text(self.errorMessage)
                .foregroundColor(.red)
        }
        .padding()
    }

    func registerUser() {
        print("Create Acc")
        Auth.auth().createUser(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("FAILED", err)
                self.errorMessage = "Failed to Create User: \(err)"
                return
            }
            print("SUCCESSFULLY CREATED \(result?.user.uid ?? "")")
            self.errorMessage = "Successfully Created User: \(result?.user.uid ?? "")"
        }
    }
}
