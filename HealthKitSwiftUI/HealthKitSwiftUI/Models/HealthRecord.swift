//
//  HealthRecord.swift
//  HealthKitSwiftUI
//
//  Created by Biswajyoti Saha on 29/01/25.
//

import Foundation

struct HealthRecord: Identifiable {
    let id = UUID()
    var date: Date
    var value: Double
}
