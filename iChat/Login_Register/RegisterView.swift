//
//  RegisterView.swift
//  iChat
//
//  Created by Diptayan Jash on 15/01/24.
//

import CommonCrypto
import Firebase
import FirebaseStorage
import Foundation
import Supabase
import SwiftUI

struct RegisterView: View {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    @State private var displayName: String = ""
    @State private var date = Date()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = ""

    @State private var shouldShowImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            Button {
                shouldShowImagePicker.toggle()
            } label: {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .cornerRadius(50)
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding()
                }
            }
            .sheet(isPresented: $shouldShowImagePicker) {
                ImagePicker(image: $selectedImage, showImagePicker: $shouldShowImagePicker, sourceType: .photoLibrary)
            }

            TextField("Name", text: $displayName)
                .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(5)
            DatePicker(
                "Date of birth",
                selection: $date,
                displayedComponents: [.date]
            )
            .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
            .padding()
            .background(.gray.opacity(0.1))
            .cornerRadius(5)
            TextField("Email", text: $email)
                .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                .keyboardType(.emailAddress)
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
                Task {
                    do {
                        await registerUser() // Wait for the registration to complete
                        try await RegisterUSER_supa() // Then try to register with Supabase
                    } catch {
                        print("Failed to create user: \(error)")
                    }
                }
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
        }
        .padding()
    }

    func registerUser() {
        if selectedImage == nil {
            errorMessage = "select Profile Picture"
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                let authError = err as NSError
                if authError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.errorMessage = "Account already in use. Please use a different email or login."
                } else {
                    self.errorMessage = "Failed to Create User: \(err.localizedDescription)"
                    print(err.localizedDescription)
                }
                return
            }
            print("SUCCESSFULLY CREATED \(result?.user.uid ?? "")")
            self.errorMessage = "Successfully Created User: \(result?.user.uid ?? "")"

            self.saveImgtoFirebase()
        }
    }

    private func saveImgtoFirebase() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { _, err in
            if let err = err {
                self.errorMessage = "Failed to push image to Storage: \(err)"
                return
            }

            ref.downloadURL { url, err in
                if let err = err {
                    self.errorMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                }

                self.errorMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                print(url?.absoluteString ?? "")

                guard let url = url else { return }
                self.StoreUserInfo(ProfilePic: url)
            }
        }
    }

    private func StoreUserInfo(ProfilePic: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = [FirebaseConstants.displayName: displayName, FirebaseConstants.email: email, FirebaseConstants.uid: uid, FirebaseConstants.photoURL: ProfilePic.absoluteString]
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(email)
            .setData(userData) { err in
                if let err = err {
                    print(err)
                    self.errorMessage = "\(err)"
                    return
                }

                print("Success")
            }
    }

    func sha256(data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }

    func hashPassword(password: String) -> String {
        let data = Data(password.utf8)
        let hashedData = sha256(data: data)
        let hashString = hashedData.map { String(format: "%02hhx", $0) }.joined()
        return hashString
    }

    func RegisterUSER_supa() async throws {
        do {
            try await supabase.auth.signUp(email: email, password: password)
            print("SUPABASE AUTH DONE")
            let hashedPassword = hashPassword(password: password)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // ISO 8601 format
            let currentDateString = dateFormatter.string(from: Date()) // Format the current date
            
            dateFormatter.dateFormat = "yyyy-MM-dd" // Format for 'date_of_birth'
            let dateString = dateFormatter.string(from: date) // Convert user provided date to string
            
            try await supabase.database
                .from("USER")
                .insert([
                    "username": displayName,
                    "email": email,
                    "password": hashedPassword, // Assuming you want to store hashed passwords
                    "created_at": currentDateString, // Now correctly formatted
                    "date_of_birth": dateString, // Assuming this was correctly formatted already
                ])
                .execute()
            print("INSERTED INTO SUPABSE DB")
        } catch {
            print("Failed to create user: \(error)")
        }
    }
}
