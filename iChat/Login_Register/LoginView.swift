import Firebase
import Foundation
import SwiftUI
import Supabase

struct LoginView: View {
    let generator = UIImpactFeedbackGenerator(style: .medium)
//    let didCompleteLogin: () -> ()
    var didCompleteLogin: () -> Void
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var date = Date()

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
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

//            Button(action: loginUser) {
//                Text("Login")
//            }
            Button(action: {
                Task {
                    do {
                        loginUser()
                        try await login_SUPA()
                    } catch {
                        print("Failed to fetch user: \(error)")
                    }
                }
            }) {
                Text("LogIn")
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
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){ result, err in
            if let err = err {
                print("Error While Login", err)
                self.errorMessage = "Failed to Login"
                return
            }
            print("SUCCESSFULLY LOGIN \(result?.user.uid ?? "")")
            self.errorMessage = "Successfully Logged In: \(result?.user.uid ?? "")"
            self.didCompleteLogin()
        }
    }
    
    func login_SUPA() async throws {
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // ISO 8601 format
            let currentDateString = dateFormatter.string(from: Date()) // Format the current date

            try await supabase.database
                .from("authentication_log")
                .insert([
                    "user_id": FirebaseManager.shared.auth.currentUser?.uid,
                    "timestamp": currentDateString,
                    "log_type": "login",
                ])
                .execute()
            print("INSERTED INTO SUPABSE DB")
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
}
