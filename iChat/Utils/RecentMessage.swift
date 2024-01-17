//
//  RecentMessage.swift
//  iChat
//
//  Created by Diptayan Jash on 17/01/24.
//

import Firebase
import Foundation
import SwiftUI

struct RecentMessage: Identifiable {
    var id: String { documentId }
    var documentId: String
    var username, text, fromId, toId, email, ProfilePic: String
    var timestamp: Date

    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.username = data["displayName"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Date ?? Date()
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.ProfilePic = data["photoURL"] as? String ?? ""
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated

        formatter.calendar = Calendar.current
        formatter.calendar.timeZone = TimeZone.current

        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }

}
