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
        fromId = data[FirebaseConstants.fromId] as? String ?? ""
        toId = data[FirebaseConstants.toId] as? String ?? ""
        text = data[FirebaseConstants.text] as? String ?? ""
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

    private func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
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
                DispatchQueue.main.async{
                    self.count+=1
                }
            }
    }

    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()

        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: chatText, "timestamp": Timestamp()] as [String: Any]

        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save msg in Firebase: \(error)"
                print("Failed to save msg in Firebase: \(error)")
                return
            }
            print("sender Successfull saved msg")
//            self.chatText = ""
//            self.count+=1
        }
        let recipientMsgDocument = FirebaseManager.shared.firestore
            .collection("messages")
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
    
    @Published var count = 0
}
