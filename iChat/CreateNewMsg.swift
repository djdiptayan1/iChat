//
//  CreateNewMsg.swift
//  iChat
//
//  Created by Diptayan Jash on 15/01/24.
//

import Firebase
import Foundation
import SDWebImageSwiftUI
import SwiftUI

class CreateNewMsgModel: ObservableObject {
    @Published var users = [ChatUser]()
    private var listener: ListenerRegistration?
    @Published var errorMessage = ""
    init() {
        fetchAllUsers()
    }

    deinit {
        // Remove the listener when the object is deinitialized
        listener?.remove()
    }

    private func fetchAllUsers() {
        // Add a snapshot listener to get real-time updates
        listener = FirebaseManager.shared.firestore.collection("users")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "\(error)"
                    print("Failed to parse users \(error)")
                    return
                }

                // Clear the existing users before updating
                self.users.removeAll()

                querySnapshot?.documents.forEach { snapshot in
                    let data = snapshot.data()
                    self.users.append(.init(data: data))
                }
            }
    }
}

struct CreateNewMsg: View {
    
    let didSelectUser:(ChatUser) ->()
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMsgModel()
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                ForEach(vm.users) { user in
                    Button {
                        presentationMode.wrappedValue
                            .dismiss()
                        didSelectUser(user)
                    } label: {
                        HStack {
                            WebImage(url: URL(string: user.ProfilePic))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .accessibilityLabel("Profile Image")
                                .overlay(
                                    RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth: 1)
                                )
                            Text(user.username)
                                .foregroundStyle(Color(.label))
                            Spacer()
                        }.padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical)
                }
            }
            .navigationTitle("new Message")
            .toolbar {
                ToolbarItemGroup(placement:
                    .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue
                                .dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
            }
        }
    }
}

#Preview {
    MainMessagesView()
}
