import Firebase
import FirebaseStorage
import SwiftUI

import Firebase

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp"
    static let photoURL = "photoURL"
    static let email = "email"
    static let displayName = "displayName"
    static let uid = "uid"
    static let users = "users"
    static let recentMessages = "recent_messages"
    static let messages = "messages"
}

class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore

    static let shared = FirebaseManager()

    override init() {
        FirebaseApp.configure()

        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()

        super.init()
    }
}

class GetUserData: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isLoggedOut = false
    @Published var shouldShowLogOutOptions = false
    @Published var shouldNavigateToChatLogView = false

    init() {
        DispatchQueue.main.async {
            self.isLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()

        fetchRecentMessages()
    }

    @Published var recentMessages = [RecentMessage]()

    private var firestoreListener: ListenerRegistration?

    private func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent msgs \(error)"
                    print(error)
                    return
                }
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID

                    if let index = self.recentMessages.firstIndex(where: { rm in
                        rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }

                    self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                })
            }
    }

    func fetchCurrentUser() {
        guard let email = FirebaseManager.shared.auth.currentUser?.email else {
            errorMessage = "Could not find firebase email"
            return
        }

        FirebaseManager.shared.firestore
            .collection("users")
            .document(email)
            .getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch current user: \(error)"
                    print("Failed to fetch current user:", error)
                    return
                }

                guard let data = snapshot?.data() else {
                    self.errorMessage = "No data found"
                    return
                }

                self.chatUser = .init(data: data)
            }
    }

    func handleSignOut() {
        isLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
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

    static func storeUserInfo(name: String, email: String, uid: String, ProfilePic: URL, completion: @escaping (String?) -> Void) {
        let userData = ["displayName": name, "email": email, "uid": uid, "photoURL": ProfilePic.absoluteString]
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid).setData(userData) { error in
            if let error = error {
                completion("Failed to store user info: \(error)")
            } else {
                completion(nil) // Success
            }
        }
    }
 }
