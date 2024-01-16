//
//  ContentView.swift
//  iChat
//
//  Created by Diptayan Jash on 14/01/24.
//

import SwiftUI

struct Welcomepage: View {
    let didCompleteLogin: () -> ()
    @State var isLogin = true
    @ObservedObject private var vm = GetUserData()
    @State private var isShowingMainMessageView = false

    var body: some View {
        NavigationView {
            ScrollView {
                Picker(selection: $isLogin, label:
                        Text("Picker")) {
                    Text("Login")
                        .tag(true)
                    Text("Register")
                        .tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if isLogin {
                    LoginView(didCompleteLogin: {
                        self.vm.isLoggedOut = false
                        self.isShowingMainMessageView = true
                    })
                } else {
                    RegisterView()
                }
            }
            .navigationTitle(isLogin ? "Login" : "Create Account")
            .navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $isShowingMainMessageView) {
                MainMessagesView()
            }
        }
    }
}

#Preview {
    Welcomepage(didCompleteLogin: {})
}
