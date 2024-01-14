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

            self.saveImgtoFirebase()
        }
    }

    private func saveImgtoFirebase() {
        guard let uid = Auth.auth().currentUser?.uid, let imageData = selectedImage?.jpegData(compressionQuality: 0.5) else { return }

        let ref = Storage.storage().reference(withPath: uid)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        ref.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to push image to Storage: \(error)"
                }
            } else {
                ref.downloadURL { url, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.errorMessage = "Failed to get download URL: \(error)"
                        }
                    } else if let downloadURL = url {
                        DispatchQueue.main.async {
                            self.errorMessage = "Successfully stored image with URL: \(downloadURL)"
                            print(downloadURL)
                        }
                    }
                }
            }
        }
    }
}
