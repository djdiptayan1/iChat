import Firebase
import SwiftUI
import SDWebImageSwiftUI

struct MainMessageView: View {
    @State var ShowLogOutOptions = false
    @ObservedObject private var vm = GetUserData()

    var body: some View {
        NavigationView {
            VStack {
                // Navbar
                NavBar(username: $vm.username, profilePicture: $vm.ProfilePic, ShowLogOutOptions: $ShowLogOutOptions)
                ScrollView {
                    ForEach(0 ..< 10, id: \.self) { _ in
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .accessibilityLabel("Profile Image")
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth: 1)
                                )
                            VStack(alignment: .leading) {
                                Text("Username")
                                    .font(.system(size: 14, weight: .bold))
                                Text("msg sent")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color(.lightGray))
                            }
                            Spacer()
                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Divider()
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
            }
            .overlay(
                NewMsgButton(), alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MainMessageView()
}

struct NewMsgButton: View {
    var body: some View {
        Button {
        } label: {
            HStack {
                Spacer()
                Text("New Message")
                    .font(.system(size: 16, weight: .bold))
                    .padding()
                Spacer()
            }
            .foregroundStyle(.white)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
    }
}
