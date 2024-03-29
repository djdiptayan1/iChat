import Firebase
import Foundation
import SwiftUI

struct LoginView: View {
    let generator = UIImpactFeedbackGenerator(style: .medium)
//    let didCompleteLogin: () -> ()
    var didCompleteLogin: () -> Void
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""

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
}
