//
//  LoginView.swift
//  iChat
//
//  Created by Diptayan Jash on 15/01/24.
//

import Firebase
import Foundation
import SwiftUI

struct LoginView: View {
    let generator = UIImpactFeedbackGenerator(style: .medium)

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        VStack {
            TextField("Username", text: $email)
                .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(5)

            SecureField("Password", text: $password)
                .autocapitalization(.none)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(5)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: loginUser) {
                Text("Login")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        withAnimation {
                            generator.impactOccurred()
                        }
                    }
            )
        }
        .padding()
    }

    func loginUser() {
        print("Login")
        Auth.auth().signIn(withEmail: email, password: password){
            result, err in
            if let err = err {
                print("Error While Login", err)
                self.errorMessage = "Failed to Create User: \(err)"
                return
            }
            print("SUCCESSFULLY LOGIN \(result?.user.uid ?? "")")
            self.errorMessage = "Successfully Logged In: \(result?.user.uid ?? "")"
        }
    }
}
