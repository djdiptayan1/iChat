import Firebase
import SwiftUI
import FirebaseStorage

import Firebase

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
