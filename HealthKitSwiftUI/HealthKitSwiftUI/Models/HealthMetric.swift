//
//  HealthMetric.swift
//  HealthKitSwiftUI
//
//  Created by Biswajyoti Saha on 29/01/25.
//

import Foundation
import SwiftUI
import HealthKit

enum HealthMetric: String, CaseIterable {
    case calories = "Calories"
    case steps = "Steps"
    case standHours = "Stand Hours"
    case exerciseMinutes = "Exercise Minutes"
    case heartRate = "Heart Rate"
    case flightsClimbed = "Flights Climbed"
    
    var systemImage: String {
        switch self {
        case .calories:
            return "flame.fill"
        case .steps:
            return "figure.walk"
        case .standHours:
            return "figure.stand"
        case .exerciseMinutes:
            return "heart.circle.fill"
        case .heartRate:
            return "waveform.path.ecg"
        case .flightsClimbed:
            return "figure.stairs"
        }
    }
    
    var color: Color {
        switch self {
        case .calories:
            return .orange
        case .steps:
            return .blue
        case .standHours:
            return .green
        case .exerciseMinutes:
            return .red
        case .heartRate:
            return .pink
        case .flightsClimbed:
            return .indigo
        }
    }
    
    var unit: String {
        switch self {
        case .calories:
            return "cal"
        case .steps:
            return "steps"
        case .standHours:
            return "hrs"
        case .exerciseMinutes:
            return "min"
        case .heartRate:
            return "bpm"
        case .flightsClimbed:
            return "flights"
        }
    }
    
    var healthKitType: HKQuantityType {
        switch self {
        case .calories:
            return HKQuantityType(.activeEnergyBurned)
        case .steps:
            return HKQuantityType(.stepCount)
        case .standHours:
            return HKQuantityType(.appleStandTime)
        case .exerciseMinutes:
            return HKQuantityType(.appleExerciseTime)
        case .heartRate:
            return HKQuantityType(.heartRate)
        case .flightsClimbed:
            return HKQuantityType(.flightsClimbed)
        }
    }
    
    var healthKitUnit: HKUnit {
        switch self {
        case .calories:
            return .kilocalorie()
        case .steps:
            return .count()
        case .standHours:
            return .hour()
        case .exerciseMinutes:
            return .minute()
        case .heartRate:
            return HKUnit.count().unitDivided(by: .minute())
        case .flightsClimbed:
            return .count()
        }
    }
    
    var statisticsOption: HKStatisticsOptions {
        switch self {
        case .heartRate:
            return .discreteAverage
        default:
            return .cumulativeSum
        }
    }
}
