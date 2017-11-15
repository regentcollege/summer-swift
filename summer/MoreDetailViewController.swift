import UIKit

class MoreDetailViewController: UIViewController {
    @IBOutlet var moreDescriptionLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        moreDescriptionLabel.text = "Stay tuned!"
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = self.splitViewController!.displayModeButtonItem
    }
}
