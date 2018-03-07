import UIKit

class EventScheduleViewController: UIViewController, DocumentStoreDelegate {
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.addConstraint(tableViewHeight)
        }
    }
    
    // https://stackoverflow.com/a/38019636
    private lazy var tableViewHeight: NSLayoutConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
    
    var documentStore: DocumentStore!
    
    var eventId: String!
    var groupScheduleByDay: Bool!
    
    var schedule: [EventScheduleViewModel]? {
        return documentStore.getEventScheduleBy(id: eventId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentStore.delegate = self
        
        documentStore.loadEventScheduleBy(id: eventId)
        
        if groupScheduleByDay {
            // stuff
        }
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.dataSource = self
    }
    
    func documentsDidUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if let schedule = self.schedule {
                self.tableViewHeight.constant = CGFloat(80 * schedule.count)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension EventScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let schedule = schedule else {
            return 0
        }
        
        return schedule.count
    }
    
    /*func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }*/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventScheduleCell", for: indexPath) as? EventScheduleCell, let schedule = schedule {
            let session = schedule[indexPath.row]
            cell.configureWith(schedule: session)
            return cell
        }
        
        return UITableViewCell()
    }
}
