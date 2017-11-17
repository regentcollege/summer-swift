import UIKit

// https://gist.github.com/arshad/de147c42d7b3063ef7bc
extension String {
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

struct Config {
    static let baseURL = NSURL(string: "https://www.regent-college.edu/summer")!
    static let headerFont = UIFont(name: "Futura-Bol", size: 14)!
    static let paragraphFont = UIFont(name: "Futura-Lig", size: 12)!
    static let obliqueFont = UIFont(name: "Futura-LigObl", size: 12)!
}

struct Color {
    static let red = "fa3737".hexColor
    static let orange = "ff690e".hexColor
}
