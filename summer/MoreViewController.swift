import UIKit

// https://swiftwithjustin.co/2016/02/05/enumified-tableview-with-dynamic-prototype-cells-in-swift/
private enum SectionType {
    case FAQ
    case Other
}

private enum Item {
    case Payment
    case Transportation
    case Wifi
    case Settings
    case About
}

private struct Section {
    var type: SectionType
    var items: [Item]
}

class MoreViewController: UITableViewController {
    private var sections = [Section]()
    
    let SectionHeaderHeight: CGFloat = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [
            Section(type: .FAQ, items: [.Payment, .Transportation, .Wifi]),
            Section(type: .Other, items: [.Settings, .About])
        ]
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 25
        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section].type {
        case .FAQ:
            return "Frequently Asked Questions"
        case .Other:
            return "Other"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch sections[indexPath.section].items[indexPath.row] {
        case .Payment:
            cell.textLabel?.text = "Payment"
        case .Transportation:
            cell.textLabel?.text = "Transportation"
        case .Wifi:
            cell.textLabel?.text = "Wifi"
        case .Settings:
            cell.textLabel?.text = "Settings"
        case .About:
            cell.textLabel?.text = "About"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let moreViewController = MoreViewController()
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section].items[indexPath.row] {
        case .Payment:
            performSegue(withIdentifier: "showDetail", sender: moreViewController)
        case .Transportation:
            performSegue(withIdentifier: "showDetail", sender: moreViewController)
        case .Wifi:
            performSegue(withIdentifier: "showDetail", sender: moreViewController)
        case .Settings:
            performSegue(withIdentifier: "showDetail", sender: moreViewController)
        case .About:
            performSegue(withIdentifier: "showAboutDetail", sender: moreViewController)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDetail"?:
            if let row = tableView.indexPathForSelectedRow?.row {
                //let moreDetailViewController = segue.destination as! MoreDetailViewController
                
                // inject item
            }
        case "showAboutDetail"?:
            if let row = tableView.indexPathForSelectedRow?.row {
                //let moreDetailViewController = segue.destination as! MoreDetailViewController
                
                // inject item
            }
        default:
            preconditionFailure("Unexpected segue identifer")
        }
    }
}
