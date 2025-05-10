//
//  ContentView.swift
//  FitFriend
//
//  Created by admin on 3/4/25.
//

import SwiftUI

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
                    // Homepage tab
                    DashboardView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(0)
                    
                    // Exercise Log tab
                    ExerciseTabView()
                        .tabItem {
                            Label("Exercise", systemImage: "figure.run")
                        }
                        .tag(1)
                    
                    // Food Log tab
                    FoodLogView()
                        .tabItem {
                            Label("Diary", systemImage: "fork.knife")
                        }
                        .tag(2)
                    // Hydration Log Tab
                    HydrationLogView()
                        .tabItem {
                            Label("Hydration", systemImage: "waterbottle")
                        }
                        .tag(3)
                    // Profile tab
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.circle")
                        }
                        .tag(4)
                }
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
