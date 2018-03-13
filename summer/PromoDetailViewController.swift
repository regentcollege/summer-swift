import UIKit

class PromoDetailViewController: UIViewController {
    @IBOutlet var gradientView: UIView!
    @IBOutlet var promoImageView: UIImageView!
    @IBOutlet var teaserTrailerLabel: UILabel!
    
    var teaserTrailer: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iPad launching in landscape breaks gradient
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let teaserTrailer = teaserTrailer {
            teaserTrailerLabel.text = teaserTrailer
        }
        else {
            teaserTrailerLabel.text = ""
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // only load gradient once
        if gradientView.subviews.count > 0 {
            return
        }
        
        // draw the gradient after forced rotation to portrait
        let gradient = PromoDetailGradientView(frame: self.view.bounds)
        gradientView.insertSubview(gradient, at: 0)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        switch UIDevice.current.orientation {
        case .faceDown:
            print("Face down")
        case .faceUp:
            print("Face up")
        case .unknown:
            print("Unknown")
        case .landscapeLeft, .landscapeRight:
            promoImageView.image = UIImage(named: "promoWide")
        case .portrait, .portraitUpsideDown:
            promoImageView.image = UIImage(named: "promoPortrait")
        }
    }
}
