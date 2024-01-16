//
//  ChatLogViewModel.swift
//  iChat
//
//  Created by Diptayan Jash on 17/01/24.
//

import Foundation
import SwiftUI
import Firebase

class ChatLogViewModel: ObservableObject {
    @Published var chatText = ""
    @Published var errorMessage = ""

    let chatUser: ChatUser?

    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
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
        let messageData = ["fromID": fromId, "toID": toId, "text": chatText, "timestamp": Timestamp()] as [String: Any]
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save msg in Firebase: \(error)"
            }
        }
    }
}
