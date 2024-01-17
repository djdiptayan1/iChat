// NewMessageButtonView.swift

import SwiftUI

struct NewMessageButton: View {
    @Binding var shouldShowNewMessageScreen: Bool
    @Binding var shouldNavigateToChatLogView: Bool
    @Binding var chatUser: ChatUser?

    var body: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        .sheet(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMsg(didSelectUser: { user in
                print(user.email)
                shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            })
        }
    }
}
