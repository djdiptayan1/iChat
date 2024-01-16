import Firebase
import SwiftUI


struct ChatLogView: View {
    let chatUser: ChatUser?

    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        vm = .init(chatUser: chatUser)
    }

    @ObservedObject var vm: ChatLogViewModel

    var body: some View {
        ZStack {
            messagesView
            VStack(spacing: 0) {
                Spacer()
                chatBottomBar
                    .background(Color(.systemGroupedBackground).ignoresSafeArea())
            }
        }
        .navigationTitle(chatUser?.username ?? "")
        .foregroundStyle(Color(.label))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var messagesView: some View {
        ScrollView {
            ForEach(vm.chatMessages){ message in
                VStack {
                    if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                        HStack {
                            Spacer()
                            HStack {
                                Text(message.text)
                                    .foregroundColor(.white)
                                    .id(message.id)
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                    } else {
                        HStack {
                            HStack {
                                Text(message.text)
                                    .foregroundColor(.white)
                                    .id(message.id)
                            }
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

            }
            HStack { Spacer() }
                .frame(height: 50)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)

            Button {
                vm.handleSend()
                vm.chatText = ""
            } label: {
                Text("Send")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

#Preview{
    MainMessagesView()
}
