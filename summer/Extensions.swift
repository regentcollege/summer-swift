import UIKit
import Mapper
import AFDateHelper
import Atributika

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

extension String {
    func toAttributedLabel() -> AttributedLabel {
        let link = Style
            .foregroundColor(Settings.Color.blue, .normal)
            .foregroundColor(.brown, .highlighted)
        
        let attributedLabel = AttributedLabel()
        attributedLabel.attributedText = self
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .style(tags: [Settings.Style.h1, Settings.Style.h3, Settings.Style.em, Settings.Style.strong], transformers: Settings.Style.transformers)
            .styleHashtags(link)
            .styleMentions(link)
            .styleLinks(link)
            .styleAll(Settings.Style.paragraph)
        
        attributedLabel.onClick = { label, detection in
            switch detection.type {
            case .hashtag(let tag):
                if let url = URL(string: "https://twitter.com/hashtag/\(tag)") {
                    UIApplication.shared.open(url)
                }
            case .mention(let name):
                if let url = URL(string: "https://twitter.com/\(name)") {
                    UIApplication.shared.open(url)
                }
            case .link(let url):
                UIApplication.shared.open(url)
            default:
                break
            }
        }
        
        return attributedLabel
    }
}

// Mapper does not have String to Date OOB
extension Mappable {
    func extractDate(object: Any?) throws -> Date {
        if let date = object as? Date {
            return date
        }
        if let dateString = object as? String,
            !dateString.isEmpty,
            let extractedDate = Date(fromString: dateString, format: .isoDate)
            {
                return extractedDate
        }
        throw MapperError.convertibleError(value: object, type: Date.self)
    }
}

class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        
        theLayer.colors = [UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.black.cgColor]
        theLayer.locations = [0.3, 0.9, 1.0]
        theLayer.frame = self.bounds
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
}
