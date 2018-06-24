import UIKit
import Kingfisher
import Atributika
import SwipeCellKit
import EventKit

class EventDetailViewController: UIViewController, DocumentStoreDelegate, EventCellDelegate {
    @IBOutlet var tableView: UITableView!
    
    var documentStore: DocumentStore!
    
    var event: EventViewModel! {
        didSet {
            navigationItem.title = event.title
        }
    }
    
    var schedule: [EventScheduleViewModel]? {
        if event.groupScheduleByDay {
            return documentStore.getEventScheduleHappeningAfter(id: event.id, now: Settings.currentDate, showTimeOnly: true)
        }
        return documentStore.getEventScheduleHappeningAfter(id: event.id, now: Settings.currentDate)
    }
    
    var lecturer: LecturerViewModel?
    var scheduleGroupedByDay = [String: [EventScheduleViewModel]]()
    var sectionTitles = [String]()
    
    private func groupSchedule() {
        scheduleGroupedByDay.removeAll()
        sectionTitles = [String]()
        
        sectionTitles.append(event.title)
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if event == nil {
            return
        }
        
        documentStore.delegate = self
        
        documentStore.loadEventScheduleBy(id: event.id)
        
        if event.groupScheduleByDay {
            tableView.sectionIndexTrackingBackgroundColor = .clear
            tableView.sectionIndexBackgroundColor = .clear
            tableView.sectionIndexColor = Settings.Color.blue
            
            UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).font = Settings.Font.sectionHeaderFont
            
            tableView.tableHeaderView?.backgroundColor = UIColor.clear
        }
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if #available(iOS 11.0, *) {
            // table layout is fine
        }
        else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        tableView.dataSource = self
        
        if event.url != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(sender:)))
        }
        
        if schedule?.count == 0 {
            self.tableView.separatorStyle = .none
            self.tableView.tableFooterView = UIView()
        }
    }
    
    @objc func share(sender:UIView){
        guard let eventUrl = event.url else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [eventUrl], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    func documentsDidUpdate() {
        DispatchQueue.main.async {
            if self.event.groupScheduleByDay {
                self.groupSchedule()
            }
            self.tableView.reloadData()
        }
    }
    
    func reloadTableForEventCellChange() {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if event == nil {
            return
        }
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = self.splitViewController!.displayModeButtonItem
    }
}

// MARK: - UITableViewDataSource
extension EventDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if event.groupScheduleByDay {
            // the event description is always the first section
            if section == 0 {
                return 1
            }
            let sectionTitle = sectionTitles[section]
            let sessions = scheduleGroupedByDay[sectionTitle]
            return sessions!.count
        }
        
        // if the schedule is not grouped by day then there is only one section

        // the event description is at least the first cell
        guard let schedule = schedule, schedule.count > 0 else {
            return 1
        }
        
        return schedule.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if event.groupScheduleByDay {
            return scheduleGroupedByDay.count + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == IndexPath(item: 0, section: 0) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventCell {
                var limitEventDescription = true
                if schedule?.count == 0 || event.description.count < 700 {
                    limitEventDescription = false
                }
                cell.configureWith(event: event, lecturer: documentStore.getLecturerBy(id: event.lecturerId), showEventDescription: true, limitEventDescription: limitEventDescription)
                cell.delegate = self
                return cell
            }
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventScheduleCell", for: indexPath) as? EventScheduleCell, let schedule = schedule {
            
            var scheduleForCell: EventScheduleViewModel!
            if event.groupScheduleByDay {
                scheduleForCell = getSessionBy(section: indexPath.section, row: indexPath.row)
            }
            else {
                scheduleForCell = schedule[indexPath.row - 1]
            }
            cell.configureWith(schedule: scheduleForCell)
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        
        if event.groupScheduleByDay {
            return sectionTitles[section]
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border
        return options
    }
}

// MARK: - SwipeTableViewCellDelegate
extension EventDetailViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let calendarAction = SwipeAction(style: .default, title: "Add to Calendar") { action, indexPath in
            let eventStore = EKEventStore()
            
            eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
                if granted && error == nil, let eventCalendar = eventStore.defaultCalendarForNewEvents {
                    let eventToAdd = EKEvent(eventStore: eventStore)
                    
                    var scheduleForCell: EventScheduleViewModel!
                    if self.event.groupScheduleByDay {
                        scheduleForCell = self.getSessionBy(section: indexPath.section, row: indexPath.row)
                    }
                    else {
                        scheduleForCell = self.schedule![indexPath.row - 1]
                    }
                    
                    eventToAdd.title = self.event.title
                    if !self.event.isRecurring && self.event.title != scheduleForCell.title {
                        eventToAdd.title = eventToAdd.title + " " + scheduleForCell.title
                    }
                    eventToAdd.startDate = scheduleForCell.start
                    eventToAdd.endDate = scheduleForCell.end
                    eventToAdd.calendar = eventStore.defaultCalendarForNewEvents
                    
                    let alert = UIAlertController(title: "Confirm", message: "Add to your default calendar " + eventCalendar.title + "?", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        do {
                            try eventStore.save(eventToAdd, span: .thisEvent)
                            let alert = UIAlertController(title: "Added", message: "Added to your default calendar for new events: " + eventToAdd.calendar.title, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        catch let error as NSError {
                            print("json error: \(error.localizedDescription)")
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                        return
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    
        calendarAction.backgroundColor = Settings.Color.blue
        
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        
        return [calendarAction]
    }
}
