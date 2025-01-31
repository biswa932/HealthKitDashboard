//
//  HealthKitSwiftUIApp.swift
//  HealthKitSwiftUI
//
//  Created by Biswajyoti Saha on 29/01/25.
//

import SwiftUI

@main
struct HealthKitSwiftUIApp: App {
    @StateObject private var healthKit = HealthKitManager.shared
    var body: some Scene {
        WindowGroup {
            if !healthKit.isAuthorized {
                PermissionsView()
            } else {
                ContentView()
            }
        }
    }
}
