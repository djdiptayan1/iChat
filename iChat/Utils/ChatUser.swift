//
//  ChatUser.swift
//  iChat
//
//  Created by Diptayan Jash on 15/01/24.
//

import Foundation
import SwiftUI

struct ChatUser: Identifiable {
    var id: String {uid}
    let username, email, uid, ProfilePic: String
    
    init(data: [String: Any]){
        self.username = data["name"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.uid = data["uid"] as? String ?? ""
        self.ProfilePic = data["ProfilePic"] as? String ?? ""
    }
}
