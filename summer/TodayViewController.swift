import UIKit
import AFDateHelper

class TodayViewController: UIViewController, DocumentStoreDelegate {
    @IBOutlet var tableView: UITableView!
    
    var documentStore: DocumentStore!
    
    var eventsForToday: [EventViewModel] {
        return documentStore.getEventsHappening(now: Date())
    }
    
    var nextEvent: EventViewModel? {
        return documentStore.getNextEvent(from: Date())
    }
    
    var nextCourse: CourseViewModel? {
        return documentStore.getNextCourse(from: Date())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentStore.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
        
        if #available(iOS 11.0, *) {
            // table layout is fine
        }
        else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        if eventsForToday.count == 0 {
            self.tableView.backgroundColor = UIColor.black
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            self.tableView.isScrollEnabled = false
        }
    }
    
    func documentsDidUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showEvent"?:
            if let row = tableView.indexPathForSelectedRow?.row,
                let navViewController = segue.destination as? UINavigationController,
                let eventDetailViewController = navViewController.topViewController as? EventDetailViewController {
                let event = eventsForToday[row]
                eventDetailViewController.event = event
                eventDetailViewController.lecturer = documentStore.getLecturerBy(id: event.lecturerId)
            }
        default:
            preconditionFailure("Unexpected segue identifer")
        }
    }
}

// MARK: - UITableViewDataSource
extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if eventsForToday.count == 0 {
            return 1
        }
        
        return eventsForToday.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if eventsForToday.count == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PromoCell", for: indexPath) as? PromoCell {
                cell.configureWith(event: nextEvent, course: nextCourse)
                return cell
            }
            return UITableViewCell()
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventCell {
            let event = eventsForToday[indexPath.row]
            
            cell.configureWith(event: event, lecturer: documentStore.getLecturerBy(id: event.lecturerId))
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showEvent", sender: EventsViewController())
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
