import UIKit

class PromoDetailViewController: UIViewController {
    @IBOutlet var gradientView: UIView!
    @IBOutlet var promoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = PromoDetailGradientView(frame: self.view.bounds)
        gradientView.insertSubview(gradient, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = self.splitViewController!.displayModeButtonItem
    }
}
