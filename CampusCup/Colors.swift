import UIKit

struct Colors {
    static let text = UIColor(hex: "#11181C")
    static let background = UIColor(hex: "#FAFAFA")
    static let icon = UIColor(hex: "#007AFF")
    static let tabIconDefault = UIColor(hex: "#35B3F2")
    static let tabIconSelected = UIColor(hex: "#3055C1")
    
    static let brandDark = UIColor(hex: "#1D1D5A")
    static let brandMain = UIColor(hex: "#3055C1")
    static let brandDanger = UIColor(hex: "#A57373")
    static let border = UIColor(hex: "#EEEEEE")
    static let description = UIColor(hex: "#999999")
    
    static let brandBrown = UIColor(hex: "#6F4E37")
    static let brandSuccess = UIColor(hex: "#2ECC71")
    static let brandWarning = UIColor(hex: "#E67E22")
}

extension UIColor {
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            self.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
