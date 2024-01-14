//
//  ContentView.swift
//  iChat
//
//  Created by Diptayan Jash on 14/01/24.
//

import SwiftUI

struct ContentView: View {
    @State var isLogin = true
    
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

                    if isLogin{
                        LoginView()
                    }
                    else{
                        RegisterView()
                    }
                }
            .navigationTitle(isLogin ? "Login" : "Create Account")
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

#Preview {
    ContentView()
}
