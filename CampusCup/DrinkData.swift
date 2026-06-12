import Foundation

final class DrinkData {
    static let drinks: [Drink] = [
        Drink(name: "아메리카노", caffeineAmount: 150),
        Drink(name: "카페라떼", caffeineAmount: 75),
        Drink(name: "에스프레소", caffeineAmount: 63),
        Drink(name: "콜드브루", caffeineAmount: 200),
        Drink(name: "레드불", caffeineAmount: 80),
        Drink(name: "몬스터", caffeineAmount: 100),
        Drink(name: "콜라", caffeineAmount: 34),
        Drink(name: "녹차", caffeineAmount: 30)
    ]
    
    private static let RECORD_KEY = "caffeine_records_key"
    private static let USER_KEY = "user_profile_key"
    
    static func saveCaffeineRecord(name: String, amount: Int) {
        guard let data = UserDefaults.standard.data(forKey: RECORD_KEY),
              var allRecords = try? JSONDecoder().decode([CaffeineRecord].self, from: data) else {
            let newRecord = CaffeineRecord(drinkName: name, caffeineAmount: amount, intakeDate: Date())
            if let encoded = try? JSONEncoder().encode([newRecord]) {
                UserDefaults.standard.set(encoded, forKey: RECORD_KEY)
            }
            return
        }
        
        let newRecord = CaffeineRecord(drinkName: name, caffeineAmount: amount, intakeDate: Date())
        allRecords.append(newRecord)
        
        if let data = try? JSONEncoder().encode(allRecords) {
            UserDefaults.standard.set(data, forKey: RECORD_KEY)
        }
    }
    
    static func loadCaffeineRecords() -> [CaffeineRecord] {
        guard let data = UserDefaults.standard.data(forKey: RECORD_KEY),
              let allRecords = try? JSONDecoder().decode([CaffeineRecord].self, from: data) else {
            return []
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        let todayRecords = allRecords.filter { $0.intakeDate >= startOfToday && $0.intakeDate <= now }
        return todayRecords
    }
    
    static func saveUser(user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: USER_KEY)
        }
    }
    
    static func loadUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: USER_KEY),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
}
