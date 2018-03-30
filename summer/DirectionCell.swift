import UIKit
import Kingfisher

class DirectionCell: UICollectionViewCell {
    @IBOutlet var directionImageView: UIImageView!
    func configureWith(directionImageUrl: URL?) {
        if let directionImageUrl = directionImageUrl {
            directionImageView.kf.setImage(with: directionImageUrl)
        }
    }
}
