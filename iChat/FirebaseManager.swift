import Firebase
import FirebaseStorage
import SwiftUI

import Firebase

struct ChatUser {
    let username, email, uid: String
    let ProfilePic: String
}

class GetUserData: ObservableObject {
    @Published var errorMessage = ""
    @Published var username = ""
    @Published var email = ""
    @Published var uid = ""
    @Published var ProfilePic = ""
    
    init() {
        fetchCurrentUser()
    }

    private func fetchCurrentUser() {
        guard let
            email = FirebaseManager.shared.auth.currentUser?.email else {
            errorMessage = "FAILED TO FETCH USER"
            return
        }
        FirebaseManager.shared.firestore.collection("users")
            .document(email).getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = "FAILED TO FETCH USER"
                    print("FAILED TO FETCH USER", error)
                    return
                }
                guard let data = snapshot?.data() else { return }
                print(data)

                let username = data["name"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let uid = data["uid"] as? String ?? ""
                let ProfilePic = data["ProfilePic"] as? String ?? ""

                let chatuser = ChatUser(username: username, email: email, uid: uid, ProfilePic: ProfilePic)

                self.username = chatuser.username
                self.email = chatuser.email
                self.uid = chatuser.uid
                self.ProfilePic = chatuser.ProfilePic
            }
    }
}

struct FirebaseUserManager {
    static func saveImageToFirebaseStorage(uid: String, image: UIImage, completion: @escaping (URL?, String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil, "Failed to convert image to data.")
            return
        }

        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        ref.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                completion(nil, "Failed to push image to Storage: \(error)")
            } else {
                ref.downloadURL { url, error in
                    if let error = error {
                        completion(nil, "Failed to get download URL: \(error)")
                    } else if let downloadURL = url {
                        completion(downloadURL, nil)
                    }
                }
            }
        }
    }

    static func storeUserInfo(email: String, uid: String, profilePicURL: URL, completion: @escaping (String?) -> Void) {
        let userData = ["email": email, "uid": uid, "ProfilePic": profilePicURL.absoluteString]
        FirebaseManager.shared.firestore.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                completion("Failed to store user info: \(error)")
            } else {
                completion(nil) // Success
            }
        }
    }
}
