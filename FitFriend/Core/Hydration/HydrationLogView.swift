import SwiftUI

struct HydrationLogView: View {
    @StateObject private var vm = HydrationViewModel()
    private let cupOunces = 8
    private let dailyGoalCups = 8

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 32) {
                Text("Current Hydration")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .padding(.top, 20)

                // MARK: - Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 250, height: 250)

                    Circle()
                        .trim(from: 0,
                              to: min(CGFloat(vm.cups) / CGFloat(dailyGoalCups), 1.0))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 250, height: 250)

                    VStack(spacing: 8) {
                        let consumedOz = vm.cups * cupOunces
                        let remainingOz = max(0, (dailyGoalCups - vm.cups) * cupOunces)
                        let percent = Int((Double(consumedOz) / Double(dailyGoalCups * cupOunces)) * 100)

                        Text("\(percent)%")
                            .font(.title2)
                            .foregroundColor(.black)
                        Text("\(consumedOz) oz")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Text("-\(remainingOz) oz")
                            .font(.footnote)
                            .foregroundColor(.black.opacity(0.7))
                    }
                }

                // MARK: - Add/Remove Buttons
                HStack(spacing: 40) {
                    Button {
                        Task { await vm.removeCup() }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                    }

                    Button {
                        Task { await vm.addCup() }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            vm.startListening(for: Date())
        }
    }
}

#Preview {
    HydrationLogView()
}
