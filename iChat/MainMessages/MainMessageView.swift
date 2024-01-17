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
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    NavigationLink {
                        ChatLogView(chatUser: self.chatUser)
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: recentMessage.ProfilePic))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(64)
                                .overlay(RoundedRectangle(cornerRadius: 64)
                                            .stroke(Color.black, lineWidth: 1))
                                .shadow(radius: 5)

                            VStack(alignment: .leading) {
                                Text(recentMessage.email)
                                    .font(.system(size: 16, weight: .bold))
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()

                            Text(recentMessage.timestamp.description)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(.label))
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
