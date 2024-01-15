//
//  NavBar.swift
//  iChat
//
//  Created by Diptayan Jash on 15/01/24.
//

import Foundation
import SwiftUI

struct NavBar: View {
    @Binding var ShowLogOutOptions: Bool
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))
                .accessibilityLabel("Profile Image")
            VStack(alignment: .leading, spacing: 4) {
                Text("username")
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
        .actionSheet(isPresented: $ShowLogOutOptions){
            .init(title: Text("Settings"), message: Text("What do you want to do"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("Signing Out")
                }),
                .cancel()
            ])
        }
    }
}
