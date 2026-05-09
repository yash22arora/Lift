// HealthKitService.swift
// Lift — HealthKit integration for Daily Steps

import Foundation
import HealthKit

@MainActor
final class HealthKitService {
    static let shared = HealthKitService()
    
    private let healthStore: HKHealthStore?
    
    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            healthStore = nil
        }
    }
    
    func requestAuthorization() async throws {
        guard let healthStore = healthStore else {
            return // HealthData not available
        }
        
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let typesToRead: Set<HKObjectType> = [stepType]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }

    /// Returns actual step count for today
    func todayStepCount() async -> Int {
        guard let healthStore = healthStore,
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                continuation.resume(returning: steps)
            }
            healthStore.execute(query)
        }
    }
}
