// CustomNavBarView.swift

import SDWebImageSwiftUI
import SwiftUI

struct Navbar: View {
    @ObservedObject private var vm: GetUserData
    @State var chatUser: ChatUser?
    @State private var date = Date()
    @State private var showProfileInput = false // State variable to control navigation to profile input screen

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
                .default(Text("Profile"), action: {
                    // Navigate to profile input screen
                    showProfileInput = true
                }),
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    vm.handleSignOut()
                    Task{
                        await logToSupabase()
                    }
                }),
                .cancel(),
            ])
        }
        .sheet(isPresented: $showProfileInput) {
            // Profile input view as a sheet
            ProfileInputView()
        }
        .fullScreenCover(isPresented: $vm.isLoggedOut, onDismiss: nil) {
            Welcomepage(didCompleteLogin: {
                vm.isLoggedOut = false
                vm.fetchCurrentUser()
            })
        }
    }
    func logToSupabase() async {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // ISO 8601 format
            let currentDateString = dateFormatter.string(from: Date()) // Format the current date

            do {
                try await supabase.database
                    .from("authentication_log")
                    .insert([
                        "user_id": FirebaseManager.shared.auth.currentUser?.uid,
                        "timestamp": currentDateString,
                        "log_type": "logout",
                    ])
                    .execute()
                print("INSERTED INTO SUPABSE DB")
            } catch {
                print("Failed to insert into Supabase DB: \(error)")
            }
        }
}
