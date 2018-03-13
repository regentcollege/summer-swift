import UIKit
import AFDateHelper

class PromoCell: UITableViewCell {
    @IBOutlet var teaserTrailerLabel: UILabel!
    @IBOutlet var promoImage: UIImageView!
    @IBOutlet var gradientView: UIView!
    
    func configureWith(teaserTrailer: String?) {
        if let teaserTrailer = teaserTrailer {
            teaserTrailerLabel?.text = teaserTrailer
        }
        
        let gradient = PromoCellGradientView(frame: self.bounds)
        gradientView.insertSubview(gradient, at: 0)
    }
}
