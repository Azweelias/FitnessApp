//
//  ContentView.swift
//  FitFriend
//
//  Created by admin on 3/4/25.
//

import SwiftUI
import FatSecretSwift

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State var selectedTab = 0
    @State private var hasAppeared = false
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = .gray
        UITabBar.appearance().barTintColor = .black
    }
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                TabView (selection: $selectedTab) {
                    VStack {
                        Button {
                            viewModel.signOut()
                        } label : {
                            Text("sign out")
                        }
                    }
                    // Homepage tab
//                    Homepage()
//                        .environmentObject(locationManager)
//                        .onAppear {
//                            if !hasAppeared {
//                                locationManager.requestLocation()
//                                hasAppeared = true
//                            }
//                        }
//                        .tabItem {
//                            Label("Home", systemImage: "house")
//                        }
//                        .tag(0)
//                    
//                    // Add new tab
//                    AddNewView()
//                        .tabItem {
//                            Label("New Device", systemImage: "plus.rectangle")
//                                
//                        }
//                        .tag(1)
//                    
//                    // Profile tab
//                    ProfileView()
//                        .tabItem {
//                            Label("Profile", systemImage: "person.circle")
//                        }
//                        .tag(2)
                }
                .accentColor(.black)
            } else {
                SignInEmailView()
                    .onAppear {
                        selectedTab = 0
                    }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
