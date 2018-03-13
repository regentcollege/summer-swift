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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [
            Section(type: .FAQ, items: [.Payment, .Transportation, .Wifi]),
            Section(type: .Other, items: [.Settings, .About])
        ]
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 25
    }
    
    // provide the initial detail view for iPad
    // must go here and not viewDidLoad because iPhone begins not collapsed
    override func viewWillAppear(_ animated: Bool) {
        if let splitViewController = self.splitViewController, !splitViewController.isCollapsed {
            
            // the wifi row is most used
            let initialIndexPath = IndexPath(row: 2, section: 0)
            self.tableView.selectRow(at: initialIndexPath, animated: true, scrollPosition:UITableViewScrollPosition.none)
            self.performSegue(withIdentifier: "showWifiDetail", sender: initialIndexPath)
            self.tableView.deselectRow(at: initialIndexPath, animated: false)
        }
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
            UIApplication.shared.open(URL(string: "https://www.regent-college.edu/current-students/pay-your-tuition-and-fees")!)
        case .Transportation:
            UIApplication.shared.open(URL(string: "https://www.regent-college.edu/current-students/living-in-vancouver/transit")!)
        case .Wifi:
            performSegue(withIdentifier: "showWifiDetail", sender: moreViewController)
        case .Settings:
            performSegue(withIdentifier: "showDetail", sender: moreViewController)
        case .About:
            performSegue(withIdentifier: "showAboutDetail", sender: moreViewController)
        }
    }
}
