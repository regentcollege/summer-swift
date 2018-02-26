import UIKit

class AboutDetailViewController: UIViewController {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    var detailTableViewController: UITableViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = self.splitViewController!.displayModeButtonItem
        
        subTitleLabel.textColor = Settings.Color.blue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "aboutDetailTableSegue" {
            detailTableViewController = segue.destination as? UITableViewController
            detailTableViewController?.tableView.delegate = self
        }
    }
}

// MARK: - UITableViewDelegate
extension AboutDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            UIApplication.shared.open(URL(string: "https://github.com/RegentCollege/summer-swift")!)
        }
        if indexPath.row == 1 {
            UIApplication.shared.open(URL(string: "https://regentcollege.uservoice.com/forums/907291-summer-mobile-app")!)
        }
        detailTableViewController?.tableView.deselectRow(at: indexPath, animated: true)
    }
}
