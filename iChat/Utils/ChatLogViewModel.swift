//
//  ChatLogViewModel.swift
//  iChat
//
//  Created by Diptayan Jash on 17/01/24.
//

import Firebase
import Foundation
import SwiftUI

struct ChatMessage: Identifiable {
    var id: String { documentID }
    let documentID: String
    let fromId, toId, text: String

    init(documentID: String, data: [String: Any]) {
        self.documentID = documentID
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

class ChatLogViewModel: ObservableObject {
    @Published var chatText = ""
    @Published var errorMessage = ""

    @Published var chatMessages = [ChatMessage]()

    let chatUser: ChatUser?

    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?

    private func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        firestoreListener?.remove()
        chatMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { QuerySnapshot, error in
                if let error = error {
                    self.errorMessage = "Error fetching new msg\(error)"
                    print(error)
                    return
                }

                QuerySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentID: change.document.documentID, data: data))
                    }
                })
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }

    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()

        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: chatText, FirebaseConstants.timestamp: Timestamp()] as [String: Any]

        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save msg in Firebase: \(error)"
                print("Failed to save msg in Firebase: \(error)")
                return
            }
            print("sender Successfull saved msg")

            self.persistRecentMsg()
            self.chatText = ""
            self.count += 1
        }
        let recipientMsgDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(toId)
            .collection(fromId)
            .document()

        recipientMsgDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save msg in Firebase: \(error)"
                print("Failed to save msg in Firebase: \(error)")
                return
            }
            print("recipient Successfull saved msg too")
        }
    }

    private func persistRecentMsg() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)

        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.photoURL: chatUser?.ProfilePic ?? "",
            FirebaseConstants.email: chatUser?.email ?? "",
            FirebaseConstants.displayName: chatUser?.username ?? "",
        ] as [String: Any]

        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "failed to see recent msg \(error)"
                print(error)
                return
            }
        }

        guard let currentUser = FirebaseManager.shared.auth.currentUser else {return}
                
        let recipientRecentMessageDictionary = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.photoURL: currentUser.photoURL ?? "",
            FirebaseConstants.email: currentUser.email ?? "",
            FirebaseConstants.displayName: currentUser.displayName ?? ""
        ] as [String: Any]

        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }

    @Published var count = 0
}
