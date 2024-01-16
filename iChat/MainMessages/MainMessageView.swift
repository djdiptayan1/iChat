import Firebase
import SDWebImageSwiftUI
import SwiftUI
struct MainMessagesView: View {
    @State var shouldShowNewMessageScreen = false
    @State var chatUser: ChatUser?
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = GetUserData()
    
    var body: some View {
        NavigationView {
            
            VStack {
                Navbar(vm: vm)
                messagesView
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
            }
            .overlay(
//                newMessageButton, alignment: .bottom)
                NewMessageButton(shouldShowNewMessageScreen: $shouldShowNewMessageScreen, shouldNavigateToChatLogView: $shouldNavigateToChatLogView, chatUser: $chatUser), alignment: .bottom)
            .navigationBarHidden(true)
        }
    }

    private var messagesView: some View {
        ScrollView {
            ForEach(0 ..< 10, id: \.self) { _ in
                VStack {
                    NavigationLink {
                        Text("Destination")
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(.label), lineWidth: 1)
                                )

                            VStack(alignment: .leading) {
                                Text("Username")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Message sent to user")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()

                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }

                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)

            }.padding(.bottom, 50)
        }
        .foregroundColor(Color(.label))
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
