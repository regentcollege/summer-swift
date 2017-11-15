import UIKit

private func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

struct Config {
    static let baseURL = NSURL(string: "https://www.regent-college.edu/summer")!
    static let headerFont = UIFont(name: "Futura-Bol", size: 14)!
    static let paragraphFont = UIFont(name: "Futura-Lig", size: 12)!
    static let obliqueFont = UIFont(name: "Futura-LigObl", size: 12)!
}

struct Color {
    static let red = hexStringToUIColor(hex: "fa3737")
    static let orange = hexStringToUIColor(hex: "ff690e")
}
