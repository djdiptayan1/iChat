//
//  RegisterView.swift
//  iChat
//
//  Created by Diptayan Jash on 15/01/24.
//

import Firebase
import FirebaseStorage
import Foundation
import SwiftUI

struct RegisterView: View {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    @State private var displayName: String = ""
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
        }
        .padding()
    }

    func registerUser() {
        if self.selectedImage == nil {
            self.errorMessage = "select Profile Picture"
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
        guard let imageData = self.selectedImage?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
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
        let userData = [FirebaseConstants.displayName: self.displayName, FirebaseConstants.email: self.email, FirebaseConstants.uid: uid, FirebaseConstants.photoURL: ProfilePic.absoluteString]
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
}
