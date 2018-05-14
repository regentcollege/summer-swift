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
    
    var coursesForToday: [CourseViewModel] {
        return documentStore.getCoursesHappening(now: Settings.currentDate)
    }
    
    var eventsCoursesForTodayIndex = [AnyObject]()
    
    var nextEvent: EventViewModel? {
        return documentStore.getNextEvent(from: Settings.currentDate)
    }
    
    var nextCourse: CourseViewModel? {
        return documentStore.getNextCourse(from: Settings.currentDate)
    }
    
    func getScheduleFor(eventId: String) -> [EventScheduleViewModel]? {
        return documentStore.getEventScheduleHappening(now: Settings.currentDate, id: eventId, showTimeOnly: true)
    }
    
    var isCollapsedView: Bool {
        return splitViewController?.isCollapsed ?? true
    }
    
    var hasSelectedCell = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentStore.delegate = self
        
        arrangeEventsAndCourses()
        
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
        self.arrangeEventsAndCourses()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !documentStore.hasLoadedEvents {
            return
        }
        self.styleTable()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            // if we collapse we need to recalculate which cells are shown
            self.arrangeEventsAndCourses()
            self.tableView.reloadData()
            
            // if we begin in portrait collapsed and rotate to not collapsed there is nothing selected
            if !self.hasSelectedCell && !self.isCollapsedView && (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight) {
                let initialIndexPath = IndexPath(row: 0, section: 0)
                self.tableView.selectRow(at: initialIndexPath, animated: true, scrollPosition:UITableViewScrollPosition.none)
                if self.eventsCoursesForTodayIndex[0] is EventViewModel {
                    self.performSegue(withIdentifier: "showEvent", sender: initialIndexPath)
                }
                else if self.eventsCoursesForTodayIndex[0] is CourseViewModel {
                    self.performSegue(withIdentifier: "showCourse", sender: initialIndexPath)
                }
            }
        })
    }
    
    func documentsDidUpdate() {
        DispatchQueue.main.async {
            self.arrangeEventsAndCourses()
            self.tableView.reloadData()
            
            self.styleTable()
        }
    }
    
    func styleTable() {
        if documentStore.hasLoadedEvents && eventsForToday.count == 0 && coursesForToday.count == 0 {
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
        
        if documentStore.hasLoadedEvents, !isCollapsedView {
            let initialIndexPath = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: initialIndexPath, animated: true, scrollPosition:UITableViewScrollPosition.none)
            if eventsForToday.count == 0 && coursesForToday.count == 0 {
                self.performSegue(withIdentifier: "showPromoDetail", sender: initialIndexPath)
                
                // the detail view for the promo cell is designed for full screen
                splitViewController?.preferredDisplayMode = .primaryHidden
            }
            else {
                if eventsCoursesForTodayIndex[0] is EventViewModel {
                    self.performSegue(withIdentifier: "showEvent", sender: initialIndexPath)
                }
                else if eventsCoursesForTodayIndex[0] is CourseViewModel {
                    self.performSegue(withIdentifier: "showCourse", sender: initialIndexPath)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        hasSelectedCell = true
        switch segue.identifier {
        case "showPromoDetail"?:
            if let promoDetailViewController = segue.destination as? PromoDetailViewController {
                promoDetailViewController.teaserTrailer = createTeaserTrailer(nextEvent: nextEvent, nextCourse: nextCourse)
            }
        case "showCourse"?:
            if let section = tableView.indexPathForSelectedRow?.section,
                let navViewController = segue.destination as? UINavigationController,
                let courseDetailViewController = navViewController.topViewController as? CourseDetailViewController {
                guard let course = eventsCoursesForTodayIndex[section] as? CourseViewModel else {
                    preconditionFailure("Unexpected segue identifer")
                }
                courseDetailViewController.course = course
                courseDetailViewController.lecturer = documentStore.getLecturerBy(id: course.lecturerId)
                courseDetailViewController.room = documentStore.getRoomBy(id: course.roomId)
            }
        case "showEvent"?:
            // eventdetail will steal the documentstore delegate
            // if meaningful updates to the todayview are needed you'll
            // have to reload its table on every appear
            if let section = tableView.indexPathForSelectedRow?.section,
                let navViewController = segue.destination as? UINavigationController,
                let eventDetailViewController = navViewController.topViewController as? EventDetailViewController {
                guard let event = eventsCoursesForTodayIndex[section] as? EventViewModel else {
                    preconditionFailure("Unexpected segue identifer")
                }
                eventDetailViewController.event = event
                eventDetailViewController.lecturer = documentStore.getLecturerBy(id: event.lecturerId)
            }
        default:
            preconditionFailure("Unexpected segue identifer")
        }
    }
    
    func arrangeEventsAndCourses() {
        eventsCoursesForTodayIndex.removeAll()
        
        let eventDates = eventsForToday.sorted(by: { $0.startDate! < $1.startDate! || ($0.startDate! == $1.startDate! && $0.endDate! < $1.endDate!)})
        
        let courseDates = coursesForToday.sorted(by: { $0.startDate! < $1.startDate! || ($0.startDate! == $1.startDate! && $0.endDate! < $1.endDate!)})
        
        let eventsCourses = eventDates as [AnyObject] + courseDates as [AnyObject]
        
        eventsCoursesForTodayIndex = eventsCourses.sorted(by: { (dictOne, dictTwo) -> Bool in
            var d1Start = Date()
            var d1End = Date()
            var d2Start = Date()
            var d2End = Date()
            
            if let event = dictOne as? EventViewModel {
                d1Start = event.startDate!
                d1End = event.endDate!
            }
            else if let course = dictOne as? CourseViewModel {
                d1Start = course.startDate!
                d1End = course.endDate!
            }
            if let event = dictTwo as? EventViewModel {
                d2Start = event.startDate!
                d2End = event.endDate!
            }
            else if let course = dictTwo as? CourseViewModel {
                d2Start = course.startDate!
                d2End = course.endDate!
            }
            
            return d1Start < d2Start || (d1Start == d2Start && d1End < d2End)
        })
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
        
        if (eventsForToday.count == 0 && coursesForToday.count == 0) || !isCollapsedView {
            return 1
        }

        if eventsCoursesForTodayIndex[section] is EventViewModel {
            let event = eventsCoursesForTodayIndex[section] as! EventViewModel
            guard let schedule = getScheduleFor(eventId: event.id), schedule.count > 0 else {
                return 1
                }
            
            if event.isRecurring && schedule.count == 1 {
                return 1
            }
            return schedule.count + 1
        }
        
        // course sections only have one row
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if eventsForToday.count == 0 && coursesForToday.count == 0 {
            return 1
        }
        
        return eventsForToday.count + coursesForToday.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if eventsForToday.count == 0 && coursesForToday.count == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PromoCell", for: indexPath) as? PromoCell {
                cell.configureWith(teaserTrailer: createTeaserTrailer(nextEvent: nextEvent, nextCourse: nextCourse))
                return cell
            }
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            if let event = eventsCoursesForTodayIndex[indexPath.section] as? EventViewModel {
                // recurring events have one session per day, so no need to show the schedule cell
                if event.isRecurring, let scheduleForCell = self.getScheduleFor(eventId: event.id), scheduleForCell.count == 1 {
                    event.title = scheduleForCell[0].title
                }
                if let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventCell {
                    cell.configureWith(event: event, lecturer: documentStore.getLecturerBy(id: event.lecturerId))
                    return cell
                }
            }
            else if let course = eventsCoursesForTodayIndex[indexPath.section] as? CourseViewModel {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as? CourseCell {
                    cell.configureWith(course: course, lecturer: documentStore.getLecturerBy(id: course.lecturerId), room: documentStore.getRoomBy(id: course.roomId))
                    return cell
                }
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventScheduleCell", for: indexPath) as? EventScheduleCell {
            guard let event = eventsCoursesForTodayIndex[indexPath.section] as? EventViewModel, let schedule = getScheduleFor(eventId: event.id) else {
                return UITableViewCell()
            }
            let scheduleForCell = schedule[indexPath.row - 1]
            cell.configureWith(schedule: scheduleForCell)
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (eventsForToday.count == 0 && coursesForToday.count == 0) || indexPath.row != 0 {
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
        if eventsForToday.count == 0 && coursesForToday.count == 0 {
            performSegue(withIdentifier: "showPromoDetail", sender: TodayViewController())
        }
        else if indexPath.row == 0 {
            if eventsCoursesForTodayIndex[indexPath.section] is EventViewModel {
                performSegue(withIdentifier: "showEvent", sender: EventsViewController())
            }
            else if eventsCoursesForTodayIndex[indexPath.section] is CourseViewModel {
                performSegue(withIdentifier: "showCourse", sender: EventsViewController())
            }
        }
        if isCollapsedView {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// todo: this is a straight copy from EventDetailViewController. DRY ASAP.
// MARK: - SwipeTableViewCellDelegate
extension TodayViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        guard let event = eventsCoursesForTodayIndex[indexPath.section] as? EventViewModel else { return nil }
        
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
                    
                    let scheduleForCell = self.getScheduleFor(eventId: event.id)![indexPath.row]
                    
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
