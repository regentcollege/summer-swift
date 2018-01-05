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
        
        documentStore?.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
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
                let event = eventsForToday[row - 1]
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return eventsForToday.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PromoCell", for: indexPath) as? PromoCell {
                cell.configureWith(event: nextEvent, course: nextCourse)
                return cell
            }
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventCell {
            let event = eventsForToday[indexPath.row - 1]
            
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
