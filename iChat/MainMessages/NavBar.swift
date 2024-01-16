// CustomNavBarView.swift

import SwiftUI
import SDWebImageSwiftUI

struct Navbar: View {
    @ObservedObject private var vm: GetUserData
    
    init(vm: GetUserData) {
        self.vm = vm
    }

    var body: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: vm.chatUser?.ProfilePic ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                            .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)

            VStack(alignment: .leading, spacing: 4) {
                let user = vm.chatUser?.username ?? "null"
                Text(user)
                    .font(.system(size: 24, weight: .bold))

                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }

            Spacer()

            Button {
                vm.shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $vm.shouldShowLogOutOptions) {
            ActionSheet(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isLoggedOut, onDismiss: nil) {
            Welcomepage(didCompleteLogin: {
                vm.isLoggedOut = false
                vm.fetchCurrentUser()
            })
        }
    }
}
