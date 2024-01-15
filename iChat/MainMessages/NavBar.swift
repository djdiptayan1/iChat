import Foundation
import SDWebImageSwiftUI
import SwiftUI

struct NavBar: View {
    @ObservedObject private var vm = GetUserData()
    @Binding var username: String
    @Binding var profilePicture: String
    @Binding var ShowLogOutOptions: Bool

    var body: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: profilePicture))
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .accessibilityLabel("Profile Image")
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.username)
                    .font(.system(size: 20, weight: .bold))
                HStack {
                    Circle()
                        .foregroundStyle(.green)
                        .frame(width: 14, height: 14)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            Button {
                ShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(.label))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .actionSheet(isPresented: $ShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("Signing Out")
                }),
                .cancel(),
            ])
        }
    }
}
