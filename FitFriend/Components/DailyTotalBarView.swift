//
//  DailyTotalBarView.swift
//  FitFriend
//
//  Created by admin on 3/12/25.
//

import SwiftUI

struct DailyTotalBarView: View {
    var gCals: Int
    var tCals: Int
    @State var diff = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("Calories Remaining")
                    .font(.headline)
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal)
            HStack(alignment: .center, spacing: 20) {
                VStack {
                    Text("\(gCals)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Goal")
                        .font(.caption)
                }
                VStack {
                    Text("-")
                        .font(.subheadline)
                    Text("")
                }
                VStack {
                    Text("\(tCals)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Food")
                        .font(.caption)
                }
                VStack {
                    Text("=")
                        .font(.subheadline)
                    Text("")
                }
                VStack {
                    Text("\(gCals - tCals)")
                        .foregroundColor(Color.blue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Remained")
                        .font(.caption2)
                        
                }
            }
            .padding(.bottom)
            .padding(.top, 2)
        }
        .background(Color.gray.opacity(0.2))
    }
}

#Preview {
    DailyTotalBarView(gCals: 1600, tCals: 1000)
}
