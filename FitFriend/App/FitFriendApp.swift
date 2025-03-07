//
//  FitFriendApp.swift
//  FitFriend
//
//  Created by admin on 3/4/25.
//

import SwiftUI
import FatSecretSwift

@main
struct FitFriendApp: App {
    @StateObject var viewModel = FoodViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
