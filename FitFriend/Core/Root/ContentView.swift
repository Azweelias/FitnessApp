//
//  ContentView.swift
//  FitFriend
//
//  Created by admin on 3/4/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State var selectedTab = 2
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
                    
                    // Homepage tab
                    DashboardView()
//                        .environmentObject(locationManager)
//                        .onAppear {
//                            if !hasAppeared {
//                                locationManager.requestLocation()
//                                hasAppeared = true
//                            }
//                        }
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(0)
                    
                    // Food Log tab
                    FoodLogView()
                        .tabItem {
                            Label("Diary", systemImage: "fork.knife")
                        }
                        .tag(1)
//
//                    // Add new tab
//                    FoodLogView()
//                        .tabItem {
//                            Label("Food Log", systemImage: "fork.knife")
//
//                        }
//                        .tag(1)
//
                    // Profile tab
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.circle")
                        }
                        .tag(2)
                }
                .accentColor(.white)
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
