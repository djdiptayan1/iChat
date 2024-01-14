//
//  iChatApp.swift
//  iChat
//
//  Created by Diptayan Jash on 14/01/24.
//

import SwiftUI
import Firebase
@main
struct iChatApp: App {
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
