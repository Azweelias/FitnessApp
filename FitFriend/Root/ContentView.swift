//
//  ContentView.swift
//  FitFriend
//
//  Created by admin on 3/4/25.
//

import SwiftUI
import FatSecretSwift

struct ContentView: View {
    @EnvironmentObject var viewModel: FoodViewModel
    @State private var searchQuery = ""

    var body: some View {
        SearchFoodView()
    }
}

#Preview {
    ContentView()
        .environmentObject(FoodViewModel())
}
