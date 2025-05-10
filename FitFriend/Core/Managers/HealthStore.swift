import Foundation
import HealthKit

class HealthStore{
    var healthStore: HKHealthStore?

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false)
            return
        }
        
        // Health data you want to READ
        let healthTypesToRead: Set<HKObjectType> = [stepType, sleepType]
        
        healthStore?.requestAuthorization(toShare: [], read: healthTypesToRead) { success, error in
            completion(success)
        }
    }


    func fetchStepsToday(completion: @escaping (Double) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        healthStore?.execute(query)
    }
    
    func fetchWeeklySleep(completion: @escaping (Double) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(0)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Find Monday of the current week
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            completion(0)
            return
        }
        
        // Start 8PM on Monday
        guard let startOfMonday8PM = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: startOfWeek) else {
            completion(0)
            return
        }
        
        // End now (today at this moment or you can clamp it to today at 10 AM if you prefer)
        guard let endOfToday10AM = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now) else {
            completion(0)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startOfMonday8PM, end: endOfToday10AM, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            
            guard let samples = samples as? [HKCategorySample] else {
                completion(0)
                return
            }
            
            var totalSleepMinutes: Double = 0
            
            for sample in samples {
                if sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue {
                    let sleepDurationMinutes = sample.endDate.timeIntervalSince(sample.startDate) / 60
                    totalSleepMinutes += sleepDurationMinutes
                }
            }
            
            completion(totalSleepMinutes)
        }
        
        healthStore?.execute(query)
    }


}
