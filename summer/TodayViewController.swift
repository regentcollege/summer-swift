import UIKit
import AFDateHelper
import SwipeCellKit
import EventKit

class TodayViewController: UIViewController, DocumentStoreDelegate, EventCellDelegate {
    @IBOutlet var tableView: UITableView!
    
    var documentStore: DocumentStore!
    
    var eventsForToday: [EventViewModel] {
        return documentStore.getEventsHappening(now: Settings.currentDate)
    }
    
    var nextEvent: EventViewModel? {
        return documentStore.getNextEvent(from: Settings.currentDate)
    }
    
    var nextCourse: CourseViewModel? {
        return documentStore.getNextCourse(from: Settings.currentDate)
    }
    
    func getScheduleFor(event: EventViewModel) -> [EventScheduleViewModel]? {
        return documentStore.getEventScheduleHappening(now: Settings.currentDate, id: event.id, showTimeOnly: true)
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
        
        styleTable()
    }
    
    func reloadTableForEventCellChange() {
        tableView.reloadData()
    }
    
    // provide the initial detail view for iPad
    // must go here and not viewDidLoad because iPhone begins not collapsed
    override func viewWillAppear(_ animated: Bool) {
        if !documentStore.hasLoadedEvents {
            return
        }
        self.styleTable()
    }
    
    func documentsDidUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
            self.styleTable()
        }
    }
    
    func styleTable() {
        if documentStore.hasLoadedEvents && eventsForToday.count == 0 {
            self.tableView.backgroundColor = UIColor.black
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            self.tableView.isScrollEnabled = false
        }
        else {
            self.tableView.backgroundColor = UIColor.white
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            self.tableView.isScrollEnabled = true
            self.tableView.tableFooterView = UIView()
        }
        
        if documentStore.hasLoadedEvents, let splitViewController = self.splitViewController, !splitViewController.isCollapsed, splitViewController.displayMode == .allVisible {
            let initialIndexPath = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: initialIndexPath, animated: true, scrollPosition:UITableViewScrollPosition.none)
            if eventsForToday.count == 0 {
                self.performSegue(withIdentifier: "showPromoDetail", sender: initialIndexPath)
                
                // the detail view for the promo cell is designed for full screen
                splitViewController.preferredDisplayMode = .primaryHidden
            }
            else {
                self.performSegue(withIdentifier: "showEvent", sender: initialIndexPath)
            }
            self.tableView.deselectRow(at: initialIndexPath, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPromoDetail"?:
            if let promoDetailViewController = segue.destination as? PromoDetailViewController {
                promoDetailViewController.teaserTrailer = createTeaserTrailer(nextEvent: nextEvent, nextCourse: nextCourse)
            }
        case "showEvent"?:
            // eventdetail will steal the documentstore delegate
            // if meaningful updates to the todayview are needed you'll
            // have to reload its table on every appear
            if let section = tableView.indexPathForSelectedRow?.section,
                let navViewController = segue.destination as? UINavigationController,
                let eventDetailViewController = navViewController.topViewController as? EventDetailViewController {
                let event = eventsForToday[section]
                eventDetailViewController.event = event
                eventDetailViewController.lecturer = documentStore.getLecturerBy(id: event.lecturerId)
            }
        default:
            preconditionFailure("Unexpected segue identifer")
        }
    }
    
    func createTeaserTrailer(nextEvent: EventViewModel?, nextCourse: CourseViewModel?) -> String {
        var teaserTrailer = String()
        if let event = nextEvent, let eventStartDate = event.startDate {
            let daysUntilNextEvent = eventStartDate.since(Settings.currentDate, in: .day)
            if daysUntilNextEvent <= 1 {
                teaserTrailer = "Our next event starts tomorrow"
            }
            else if daysUntilNextEvent < 7 {
                teaserTrailer = "\(daysUntilNextEvent) days until our next event"
            }
            else if eventStartDate.compare(.isNextWeek) {
                teaserTrailer = "One week until our next event"
            }
            else {
                teaserTrailer = "\(eventStartDate.since(Settings.currentDate, in: .week)) weeks until our next event"
            }
        }
        if teaserTrailer != "" {
            teaserTrailer += "\n"
        }
        if let course = nextCourse, let courseStartDate = course.startDate {
            let daysUntilNextCourse = courseStartDate.since(Settings.currentDate, in: .day)
            if daysUntilNextCourse <= 1 {
                teaserTrailer += "Our next course starts tomorrow"
            }
            else if daysUntilNextCourse < 7 {
                teaserTrailer += "\(daysUntilNextCourse) days until our next course"
            }
            else if courseStartDate.compare(.isNextWeek) {
                teaserTrailer += "One week until our next course"
            }
            else {
                teaserTrailer += "\(courseStartDate.since(Settings.currentDate, in: .week)) weeks until our next course"
            }
        }
        return teaserTrailer
    }
}

// MARK: - UITableViewDataSource
extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !documentStore.hasLoadedEvents {
            return 0
        }
        
        if eventsForToday.count == 0 {
            return 1
        }

        // the event description is at least the first cell
        guard let schedule = getScheduleFor(event: eventsForToday[section]), schedule.count > 0 else {
            return 1
        }
        
        return schedule.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if eventsForToday.count == 0 {
            return 1
        }
        
        // todo: must count the number of events with schedule today
        return eventsForToday.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if eventsForToday.count == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PromoCell", for: indexPath) as? PromoCell {
                cell.configureWith(teaserTrailer: createTeaserTrailer(nextEvent: nextEvent, nextCourse: nextCourse))
                return cell
            }
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventCell {
                let event = eventsForToday[indexPath.section]
                
                cell.configureWith(event: event, lecturer: documentStore.getLecturerBy(id: event.lecturerId))
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventScheduleCell", for: indexPath) as? EventScheduleCell, let schedule = getScheduleFor(event: eventsForToday[0]) {
            
            let scheduleForCell = schedule[indexPath.row - 1]
            cell.configureWith(schedule: scheduleForCell)
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if eventsForToday.count == 0 || indexPath.row != 0 {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border
        return options
    }
}

// MARK: - UITableViewDelegate
extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if eventsForToday.count == 0 {
            performSegue(withIdentifier: "showPromoDetail", sender: TodayViewController())
        }
        else if indexPath.row == 0 {
            performSegue(withIdentifier: "showEvent", sender: EventsViewController())
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// todo: this is a straight copy from EventDetailViewController. DRY ASAP.
// MARK: - SwipeTableViewCellDelegate
extension TodayViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let calendarAction = SwipeAction(style: .default, title: "Add to Calendar") { action, indexPath in
            let eventStore = EKEventStore()
            
            eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
                if granted && error == nil, let eventCalendar = eventStore.defaultCalendarForNewEvents {
                    let alert = UIAlertController(title: "Confirm", message: "Add to your default calendar " + eventCalendar.title + "?", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                        return
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                    let eventToAdd = EKEvent(eventStore: eventStore)
                    
                    let scheduleForCell = self.getScheduleFor(event: self.eventsForToday[0])![indexPath.row]
                    
                    eventToAdd.title = self.eventsForToday[0].title + " " + scheduleForCell.title
                    eventToAdd.startDate = scheduleForCell.start
                    eventToAdd.endDate = scheduleForCell.end
                    eventToAdd.calendar = eventStore.defaultCalendarForNewEvents
                    
                    do {
                        try eventStore.save(eventToAdd, span: .thisEvent)
                        let alert = UIAlertController(title: "Added", message: "Added to your default calendar for new events: " + eventToAdd.calendar.title, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    catch let error as NSError {
                        print("json error: \(error.localizedDescription)")
                    }
                }
            })
        }
        
        calendarAction.backgroundColor = Settings.Color.blue
        
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        
        return [calendarAction]
    }
}
