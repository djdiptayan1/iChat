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
    
    static let emptyScrollToString = "Empty"

    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in

                        MessageView(message: message)
                    }
                    HStack { Spacer() }
                        .frame(height: 50)
                        .id(Self.emptyScrollToString)
                        .onReceive(vm.$count) { _ in
//                            withAnimation(.easeOut(duration: 0.5)) // IF I use animation, I cannot change the background. Weird bug need to fix it.
                            scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                        }
                }
            }
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

            Button(action: {
                Task {
                    do {
                        vm.handleSend()
                        try await supa_msg()
                    } catch {
                        print("Failed to fetch user: \(error)")
                    }
                }
            }) {
                Text("Send")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    func supa_msg() async throws{
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // ISO 8601 format
            let currentDateString = dateFormatter.string(from: Date()) // Format the current date

            try await supabase.database
                .from("message")
                .insert([
                    "sender_time": currentDateString,
                    "receiver_time": currentDateString,
                    "message_size": String(vm.chatText.count), // Convert Int to String
                    "timestamp": currentDateString
                ])
                .execute()
            print("INSERTED INTO SUPABSE DB")
        } catch {
            print("Failed to fetch user: \(error)")
        }
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

#Preview {
    MainMessagesView()
}

struct MessageView: View {
    let message: ChatMessage
    var body: some View {
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
}
