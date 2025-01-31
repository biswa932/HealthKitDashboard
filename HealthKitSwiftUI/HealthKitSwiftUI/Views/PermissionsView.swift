//
//  PermissionsView.swift
//  HealthKitSwiftUI
//
//  Created by Biswajyoti Saha on 29/01/25.
//

import SwiftUI
import HealthKit

struct PermissionsView: View {
    @StateObject private var healthKit = HealthKitManager.shared
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.raised.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Health Data Access")
            
            Text("We need access to your health data to track calories burned and other details like heart rate etc.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
            Text("This app will:")
                .font(.headline)
            VStack(alignment: .leading, spacing: 10) {
                Label("Read active energy burned", systemImage: "flame.fill")
                Label("Show daily statistics", systemImage: "chart.bar.fill")
                Label("Track your progress", systemImage: "charrt.line.uptrend.xyaxis")
            }
            .padding()
            
            Button("Allow Access"){
                Task {
                    await healthKit.checkAndRequestAuthorization()
                    print("ask permission")
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    PermissionsView()
}
