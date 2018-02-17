import UIKit
import Atributika

class Settings {
    struct Url {
        static let baseURL = NSURL(string: "https://www.regent-college.edu/summer")!
    }

    struct Font {
        static let headerFont = UIFont(name: "Futura-Bol", size: 18)!
        static let paragraphFont = UIFont(name: "Futura-Lig", size: 16)!
        static let obliqueFont = UIFont(name: "Futura-LigObl", size: 16)!
    }
    
    struct Style {
        static let h1 = Atributika.Style("h1").font(Settings.Font.headerFont)
        static let h3 = Atributika.Style("h3").font(Settings.Font.headerFont)
        static let em = Atributika.Style("em").font(.italicSystemFont(ofSize: 16))
        static let strong = Atributika.Style("strong").font(.boldSystemFont(ofSize: 16))
        static let paragraph = Atributika.Style.font(.systemFont(ofSize: 16))
        static let transformers: [TagTransformer] = [
            TagTransformer(tagName: "h3", tagType: .end, replaceValue: "\n"),
            TagTransformer(tagName: "p", tagType: .end, replaceValue: "\n"),
            TagTransformer(tagName: "ul", tagType: .start, replaceValue: "\n"),
            TagTransformer(tagName: "li", tagType: .start, replaceValue: "- "),
            TagTransformer(tagName: "li", tagType: .end, replaceValue: "\n")
        ]
    }
    
    struct Color {
        static let red = "fa3737".hexColor
        static let orange = "ff690e".hexColor
    }
}
