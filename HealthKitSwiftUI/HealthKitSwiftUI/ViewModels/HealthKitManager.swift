//
//  HealthKitManager.swift
//  HealthKitSwiftUI
//
//  Created by Biswajyoti Saha on 29/01/25.
//

import SwiftUI
import HealthKit

final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    @Published var isAuthorized: Bool = false
    @Published var healthData: [HealthMetric: [HealthRecord]] = [:]
    @Published var isLoading: Bool = false
    
//    init() {
//        Task {
//            await checkAndRequestAuthorization()
//        }
//    }
    
    func checkAndRequestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        let typesToread = Set(HealthMetric.allCases.map { $0.healthKitType})
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToread)
            await MainActor.run {
                isAuthorized = true
                Task {
                    await fetchAllData()
                }
            }
        } catch {
            print("Auth failed: \(error.localizedDescription)")
        }
    }
    
    func fetchAllData() async {
        await MainActor.run {
            isLoading = true
        }
        
        await withTaskGroup(of: Void.self) { group in
            for metric in HealthMetric.allCases {
                group.addTask {
                    await self.fetchData(for: metric)
                }
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    func fetchData(for metric: HealthMetric, day: Int = 7) async {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -day, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let records: [HealthRecord] = await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: metric.healthKitType,
                quantitySamplePredicate: predicate,
                options: metric.statisticsOption,
                anchorDate: startDate,
                intervalComponents: DateComponents(day: 1)
            )
            
            query.initialResultsHandler = { query, results, error in
                guard let collection = results else {
                    continuation.resume(returning: [])
                    return
                }
                
                var records: [HealthRecord] = []
                collection.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                    let value: Double
                    switch metric.statisticsOption {
                        case .discreteAverage:
                        value = statistics.averageQuantity()?.doubleValue(for: metric.healthKitUnit) ?? 0
                    default:
                        value = statistics.sumQuantity()?.doubleValue(for: metric.healthKitUnit) ?? 0
                    }
                    
                    records.append(HealthRecord(date: statistics.startDate, value: value))
                }
                continuation.resume(returning: records)
            }
            self.healthStore.execute(query)
        }
        await MainActor.run {
            self.healthData[metric] = records
        }
    }
}
