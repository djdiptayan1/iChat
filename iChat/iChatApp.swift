//
//  iChatApp.swift
//  iChat
//
//  Created by Diptayan Jash on 14/01/24.
//

import Firebase
import FirebaseStorage
import SwiftUI

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

@main
struct iChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
