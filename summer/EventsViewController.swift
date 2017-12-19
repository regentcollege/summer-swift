import UIKit
import AFDateHelper

class EventsViewController: UIViewController, DocumentStoreDelegate {
    @IBOutlet var tableView: UITableView!
    
    var documentStore: DocumentStore!
    
    var events: [EventViewModel] {
        return documentStore.getEvents()
    }
    
    var eventsWithSections = [String : [EventViewModel]]()
    var sectionTitles = [String]()
    var sectionTitlesDate = [Date]()
    
    let collation = UILocalizedIndexedCollation.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentStore?.delegate = self
        
        groupEvents()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
        
        tableView.sectionIndexTrackingBackgroundColor = .clear
        tableView.sectionIndexBackgroundColor = .clear
    }
    
    func documentsDidUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showEvent"?:
            if let section = tableView.indexPathForSelectedRow?.section,
                let row = tableView.indexPathForSelectedRow?.row,
                let navViewController = segue.destination as? UINavigationController,
                let eventDetailViewController = navViewController.topViewController as? EventDetailViewController {
                let event = getEventBy(section: section, row: row)
                eventDetailViewController.event = event
                eventDetailViewController.lecturer = documentStore.getLecturerBy(id: event.lecturerId)
            }
        default:
            preconditionFailure("Unexpected segue identifer")
        }
    }
    
    private func groupEvents() {
        var sectionTitle = ""
        
        for event in events {
            if let startDate = event.startDate {
                let thisSectionTitle = startDate.toString(format: .custom("MMM d"))
                if thisSectionTitle != sectionTitle {
                    sectionTitle = thisSectionTitle
                    eventsWithSections[sectionTitle] = [EventViewModel]()
                    sectionTitles.append(sectionTitle)
                    sectionTitlesDate.append(startDate)
                }
                eventsWithSections[thisSectionTitle]?.append(event)
            }
            else {
                eventsWithSections["_"]?.append(event)
            }
        }
    }
    
    private func getEventBy(section: Int, row: Int) -> EventViewModel {
        let sectionTitle = sectionTitles[section]
        let events = eventsWithSections[sectionTitle]
        return events![row]
    }
}

// MARK: - UITableViewDataSource
extension EventsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sectionTitles[section]
        let events = eventsWithSections[sectionTitle]
        return events!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventCell {
            let event = getEventBy(section: indexPath.section, row: indexPath.row)
            
            cell.configureWith(event: event, lecturer: documentStore.getLecturerBy(id: event.lecturerId))
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitlesDate[section].toString(format: .custom("EEEE MMMM d"))
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
}

// MARK: - UITableViewDelegate
extension EventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showEvent", sender: EventsViewController())
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
