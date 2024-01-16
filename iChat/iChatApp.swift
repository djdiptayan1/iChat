//
//  iChatApp.swift
//  iChat
//
//  Created by Diptayan Jash on 14/01/24.
//

import Firebase
import FirebaseStorage
import SwiftUI

@main
struct iChatApp: App {
    var body: some Scene {
        WindowGroup {
            Welcomepage(didCompleteLogin: {})
        }
    }
}
