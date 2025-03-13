//
//  NutrInfoRowView.swift
//  FitFriend
//
//  Created by admin on 3/10/25.
//

import SwiftUI

struct NutrInfoRowView: View {
    let label: String
    let nutrInfo: String
    let unit: String
    var body: some View {
        HStack {
            Text("\(label)")
            Spacer()
            Text("\(nutrInfo) \(unit)")
            
        }
        .padding(.vertical, 3)
        Divider()
            .background(Color.black)
    }
}

#Preview {
    NutrInfoRowView(label: "Potassium", nutrInfo: "12.1", unit: "mg")
}
