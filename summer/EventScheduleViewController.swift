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
        if groupScheduleByDay {
            return documentStore.getEventScheduleBy(id: eventId, showTimeOnly: true)
        }
        return documentStore.getEventScheduleBy(id: eventId)
    }
    
    var scheduleGroupedByDay = [String: [EventScheduleViewModel]]()
    var sectionTitles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentStore.delegate = self
        
        documentStore.loadEventScheduleBy(id: eventId)
        
        if groupScheduleByDay {
            tableView.sectionIndexTrackingBackgroundColor = .clear
            tableView.sectionIndexBackgroundColor = .clear
            tableView.sectionIndexColor = Settings.Color.blue
        }
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.dataSource = self
    }
    
    func documentsDidUpdate() {
        DispatchQueue.main.async {
            if let schedule = self.schedule {
                self.tableViewHeight.constant = CGFloat(80 * schedule.count)
            }
            if self.groupScheduleByDay {
                self.groupSchedule()
                self.tableViewHeight.constant += CGFloat(25 * self.scheduleGroupedByDay.count)
            }
            self.tableView.reloadData()
        }
    }
    
    private func groupSchedule() {
        scheduleGroupedByDay.removeAll()
        
        guard let schedule = schedule else {
            return
        }
        
        var sectionTitle = ""
        for session in schedule {
            if let start = session.start {
                let thisSectionTitle = start.toString(format: .custom("EEEE, MMM d"))
                if thisSectionTitle != sectionTitle {
                    sectionTitle = thisSectionTitle
                    scheduleGroupedByDay[sectionTitle] = [EventScheduleViewModel]()
                    sectionTitles.append(sectionTitle)
                }
                scheduleGroupedByDay[thisSectionTitle]?.append(session)
            }
            else {
                var existingItems = scheduleGroupedByDay["_"] ?? [EventScheduleViewModel]()
                existingItems.append(session)
                scheduleGroupedByDay["_"] = existingItems
            }
        }
    }
    
    private func getSessionBy(section: Int, row: Int) -> EventScheduleViewModel {
        let sectionTitle = sectionTitles[section]
        let sessions = scheduleGroupedByDay[sectionTitle]
        return sessions![row]
    }
}

// MARK: - UITableViewDataSource
extension EventScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupScheduleByDay {
            let sectionTitle = sectionTitles[section]
            let sessions = scheduleGroupedByDay[sectionTitle]
            return sessions!.count
        }
        
        guard let schedule = schedule else {
            return 0
        }
        
        return schedule.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if groupScheduleByDay {
            return scheduleGroupedByDay.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventScheduleCell", for: indexPath) as? EventScheduleCell, let schedule = schedule {
            if groupScheduleByDay {
                let session = getSessionBy(section: indexPath.section, row: indexPath.row)
                cell.configureWith(schedule: session)
                return cell
            }
            
            let session = schedule[indexPath.row]
            cell.configureWith(schedule: session)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if groupScheduleByDay {
            return sectionTitles[section]
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
}
