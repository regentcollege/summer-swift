import Foundation
import Firebase
import Kingfisher

protocol DocumentStoreDelegate: class {
    func documentsDidUpdate()
}

class DocumentStore {
    private var db: Firestore!
    private var courses = [Course]()
    private var lecturers = [Lecturer]()
    private var events = [Event]()
    private var eventSchedule = [String: [EventSchedule]]()
    private var rooms = [Room]()
    var delegate: DocumentStoreDelegate?
    
    var hasLoadedEvents = false
    
    init() {
        FirebaseApp.configure()
        db = Firestore.firestore()
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        loadData()
        checkForUpdates()
    }

    func getEvents() -> [EventViewModel] {
        return events.map { EventViewModel(event: $0) }
    }
    
    func getEventScheduleBy(id: String, showTimeOnly: Bool = false) -> [EventScheduleViewModel]? {
        guard let schedule = eventSchedule[id] else {
            return nil
        }
        return schedule.map { EventScheduleViewModel(schedule: $0, showTimeOnly: showTimeOnly) }
    }
    
    func getEventScheduleHappening(now: Date, id: String, showTimeOnly: Bool = false) -> [EventScheduleViewModel]? {
        guard let schedule = eventSchedule[id] else {
            return nil
        }
        
        return schedule.filter { $0.start!.compare(.isSameDay(as: now)) ||
            $0.end!.compare(.isSameDay(as: now)) ||
            $0.start!.compare(.isEarlier(than: now)) && $0.end!.compare(.isLater(than: now)) }.map { EventScheduleViewModel(schedule: $0, showTimeOnly: showTimeOnly) }
    }
    
    //todo could return a tuple with schedule as well
    func getEventsHappening(now: Date) -> [EventViewModel] {
        let eventsWithDates = events.filter { $0.startDate != nil && $0.endDate != nil }
        let eventViewModels = eventsWithDates.filter { $0.startDate!.compare(.isSameDay(as: now)) ||
            $0.endDate!.compare(.isSameDay(as: now)) ||
            $0.startDate!.compare(.isEarlier(than: now)) && $0.endDate!.compare(.isLater(than: now)) }.map { EventViewModel(event: $0, showTimeOnly: true) }
        
        var eventsToReturn = [EventViewModel]()
        // events that span multiple days but don't have anything scheduled for this particular day aren't returned
        for event in eventViewModels {
            if let schedule = getEventScheduleHappening(now: now, id: event.id), schedule.count > 0 {
                eventsToReturn.append(event)
            }
            else if let schedule = getEventScheduleBy(id: event.id), schedule.count == 0 {
                // however events that don't have any schedule at all can be included
                eventsToReturn.append(event)
            }
        }
        return eventsToReturn
    }
    
    func getNextEvent(from: Date) -> EventViewModel? {
        let eventsWithDates = events.filter { $0.startDate != nil }
        let nextEvents = eventsWithDates.filter { $0.startDate!.compare(.isSameDay(as: from)) ||
            $0.startDate!.compare(.isLater(than: from)) }.map { EventViewModel(event: $0) }.sorted(by: { $0.startDate! < $1.startDate! })
        
        if nextEvents.count > 0 {
            return nextEvents.first
        }
        
        return nil
    }
    
    func getCourses() -> [CourseViewModel] {
        return courses.map { CourseViewModel(course: $0) }
    }
    
    func getCoursesBy(season: Seasons) -> [CourseViewModel] {
        return courses.filter { $0.season == season }.map { CourseViewModel(course: $0) }
    }
    
    func getCoursesHappening(now: Date) -> [CourseViewModel] {
        let coursesWithDates = courses.filter { $0.startDate != nil && $0.endDate != nil }
        return coursesWithDates.filter { $0.startDate!.compare(.isSameDay(as: now)) ||
            $0.endDate!.compare(.isSameDay(as: now)) ||
            $0.startDate!.compare(.isEarlier(than: now)) && $0.endDate!.compare(.isLater(than: now)) }.map { CourseViewModel(course: $0) }
    }
    
    func getNextCourse(from: Date) -> CourseViewModel? {
        let coursesWithDates = courses.filter { $0.startDate != nil }
        let nextCourses = coursesWithDates.filter { $0.startDate!.compare(.isSameDay(as: from)) ||
            $0.startDate!.compare(.isLater(than: from)) }.map { CourseViewModel(course: $0) }.sorted(by: { $0.startDate! < $1.startDate! })
        
        if nextCourses.count > 0 {
            return nextCourses.first
        }
        
        return nil
    }
    
    func getLecturers() -> [LecturerViewModel] {
        return lecturers.map { LecturerViewModel(lecturer: $0) }
    }
    
    func getLecturerBy(id: String?) -> LecturerViewModel {
        if let id = id, let lecturer = lecturers.first(where: { $0.id == id }) {
            return LecturerViewModel(lecturer: lecturer)
        }
        return LecturerViewModel(lecturer: nil)
    }
    
    func getRoomBy(id: String?) -> RoomViewModel {
        if let id = id, let room = rooms.first(where: { $0.id == id }) {
            return RoomViewModel(room: room)
        }
        return RoomViewModel(room: nil)
    }
    
    private func sort(events: [Event]) -> [Event] {
        let eventsWithoutStartDates = events.filter {$0.startDate == nil }
        let eventsWithStartDates = events.filter { $0.startDate != nil }.sorted(by: { $0.startDate! < $1.startDate! })
        return eventsWithoutStartDates + eventsWithStartDates
    }
    
    private func sort(eventSchedules: [EventSchedule]) -> [EventSchedule] {
        let eventSchedulesWithoutStart = eventSchedules.filter {$0.start == nil }
        let eventSchedulesWithStart = eventSchedules.filter { $0.start != nil }.sorted(by: { $0.start! < $1.start! })
        return eventSchedulesWithoutStart + eventSchedulesWithStart
    }
    
    private func sort(courses: [Course]) -> [Course] {
        let coursesWithoutDates = courses.filter {$0.startDate == nil || $0.endDate == nil}
        let coursesWithDates = courses.filter { $0.startDate != nil && $0.endDate != nil}.sorted(by: { $0.startDate! < $1.startDate! || ($0.startDate! == $1.startDate! && $0.endDate! < $1.endDate!)})
        return coursesWithoutDates + coursesWithDates
    }
    
    // firestore does not support returning subcollections as part of the parent document
    // and we can't iterate 'events' reliably until they're all loaded
    // so differ until someone actually views a particular event
    func loadEventScheduleBy(id: String) {
        self.db.collection("events").document(id).collection("schedule").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                self.eventSchedule[id] = [EventSchedule]()
                self.eventSchedule[id] = self.sort(eventSchedules: querySnapshot!.documents.compactMap({
                    var scheduleDictionary = $0.data()
                    scheduleDictionary["id"] = $0.documentID
                    guard let schedule = EventSchedule.from(scheduleDictionary as NSDictionary) else {
                        return nil
                    }
                    return schedule
                }))
                
                self.delegate?.documentsDidUpdate()
            }
        }
        db.collection("events").document(id).collection("schedule").addSnapshotListener {
            querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            guard var eventToSchedule = self.eventSchedule[id] else { return }
            
            snapshot.documentChanges.forEach {
                diff in
                switch diff.type {
                case .added:
                    var scheduleDictionary = diff.document.data()
                    scheduleDictionary["id"] = diff.document.documentID
                    if let eventSchedule = EventSchedule.from(scheduleDictionary as NSDictionary) {
                        if eventToSchedule.first(where: { $0.id == eventSchedule.id }) != nil {
                            return
                        }
                        eventToSchedule.append(eventSchedule)
                        self.eventSchedule[id] = self.sort(eventSchedules: eventToSchedule)
                        self.delegate?.documentsDidUpdate()
                    }
                case .modified:
                    var scheduleDictionary = diff.document.data()
                    scheduleDictionary["id"] = diff.document.documentID
                    if let eventSchedule = EventSchedule.from(scheduleDictionary as NSDictionary) {
                        if let updatedEventScheduleIndex = eventToSchedule.index(where: { $0.id == eventSchedule.id }) {
                            eventToSchedule[updatedEventScheduleIndex] = eventSchedule
                        }
                        else {
                            eventToSchedule.append(eventSchedule)
                        }
                        self.eventSchedule[id] = self.sort(eventSchedules: eventToSchedule)
                        self.delegate?.documentsDidUpdate()
                    }
                case .removed:
                    var scheduleDictionary = diff.document.data()
                    scheduleDictionary["id"] = diff.document.documentID
                    if let eventSchedule = EventSchedule.from(scheduleDictionary as NSDictionary) {
                        if let updatedEventScheduleIndex = eventToSchedule.index(where: { $0.id == eventSchedule.id }) {
                            eventToSchedule.remove(at: updatedEventScheduleIndex)
                            self.eventSchedule[id] = self.sort(eventSchedules: eventToSchedule)
                            self.delegate?.documentsDidUpdate()
                        }
                    }
                }
            }
        }
    }
    
    private func loadData() {
        db.collection("events").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                self.events = self.sort(events: querySnapshot!.documents.compactMap({
                    var eventDictionary = $0.data()
                    eventDictionary["id"] = $0.documentID
                    guard let event = Event.from(eventDictionary as NSDictionary) else {
                        return nil
                    }
                    
                    // this async load will fire delegate updates on each event
                    // this is overkill as we don't need all the schedules immediately
                    self.loadEventScheduleBy(id: event.id)
                    
                    return event
                }))
                
                self.prefetchImageUrls(urls: self.events.filter({ $0.imageUrl != nil }).map({ $0.imageUrl! }))
                
                self.hasLoadedEvents = true
                
                self.delegate?.documentsDidUpdate()
            }
        }
        db.collection("courses").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                self.courses = self.sort(courses: querySnapshot!.documents.compactMap({
                    var courseDictionary = $0.data()
                    courseDictionary["id"] = $0.documentID
                    guard let course = Course.from(courseDictionary as NSDictionary) else {
                        return nil
                    }
                    return course
                }))
                self.delegate?.documentsDidUpdate()
            }
        }
        db.collection("lecturers").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                self.lecturers = querySnapshot!.documents.compactMap({
                    var lecturerDictionary = $0.data()
                    lecturerDictionary["id"] = $0.documentID
                    guard let lecturer = Lecturer.from(lecturerDictionary as NSDictionary) else {
                        return nil
                    }
                    return lecturer
                })
                
                self.prefetchImageUrls(urls: self.lecturers.map { $0.imageUrl! })
                
                self.delegate?.documentsDidUpdate()
            }
        }
        db.collection("rooms").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                self.rooms = querySnapshot!.documents.compactMap({
                    var roomDictionary = $0.data()
                    roomDictionary["id"] = $0.documentID
                    guard let room = Room.from(roomDictionary as NSDictionary) else {
                        return nil
                    }
                    return room
                })
                
                // could prefetch direction images
                
                self.delegate?.documentsDidUpdate()
            }
        }
    }
    
    private func prefetchImageUrls(urls: [URL]) {
        let prefetcher = ImagePrefetcher(urls: urls) {
            skippedResources, failedResources, completedResources in
            print("These resources are prefetched: \(completedResources)")
        }
        prefetcher.start()
    }
    
    private func checkForUpdates() {
        db.collection("events").addSnapshotListener {
            querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach {
                diff in
                
                //TODO DRY depending on how similar the added, modified, and removed response are
                switch diff.type {
                case .added:
                    var eventDictionary = diff.document.data()
                    eventDictionary["id"] = diff.document.documentID
                    if let event = Event.from(eventDictionary as NSDictionary) {
                        if self.events.first(where: { $0.id == event.id }) != nil {
                            return
                        }
                        self.events.append(event)
                        self.events = self.sort(events: self.events)
                        self.delegate?.documentsDidUpdate()
                    }
                case .modified:
                    var eventDictionary = diff.document.data()
                    eventDictionary["id"] = diff.document.documentID
                    if let event = Event.from(eventDictionary as NSDictionary) {
                        if let updatedEventIndex = self.events.index(where: { $0.id == event.id }) {
                            self.events[updatedEventIndex] = event
                        }
                        else {
                            self.events.append(event)
                        }
                        self.events = self.sort(events: self.events)
                        self.delegate?.documentsDidUpdate()
                    }
                case .removed:
                    var eventDictionary = diff.document.data()
                    eventDictionary["id"] = diff.document.documentID
                    if let event = Event.from(eventDictionary as NSDictionary) {
                        if let updatedEventIndex = self.events.index(where: { $0.id == event.id }) {
                            self.events.remove(at: updatedEventIndex)
                            self.events = self.sort(events: self.events)
                            self.delegate?.documentsDidUpdate()
                        }
                    }
                }
            }
        }
        db.collection("courses").addSnapshotListener {
            querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach {
                diff in
                
                //TODO DRY depending on how similar the added, modified, and removed response are
                switch diff.type {
                case .added:
                    var courseDictionary = diff.document.data()
                    courseDictionary["id"] = diff.document.documentID
                    if let course = Course.from(courseDictionary as NSDictionary) {
                        if self.courses.first(where: { $0.id == course.id }) != nil {
                            return
                        }
                        self.courses.append(course)
                        self.courses = self.sort(courses: self.courses)
                        self.delegate?.documentsDidUpdate()
                    }
                case .modified:
                    var courseDictionary = diff.document.data()
                    courseDictionary["id"] = diff.document.documentID
                    if let course = Course.from(courseDictionary as NSDictionary) {
                        if let updatedCourseIndex = self.courses.index(where: { $0.id == course.id }) {
                            self.courses[updatedCourseIndex] = course
                        }
                        else {
                            self.courses.append(course)
                        }
                        self.courses = self.sort(courses: self.courses)
                        self.delegate?.documentsDidUpdate()
                    }
                case .removed:
                    var courseDictionary = diff.document.data()
                    courseDictionary["id"] = diff.document.documentID
                    if let course = Course.from(courseDictionary as NSDictionary) {
                        if let updatedCourseIndex = self.courses.index(where: { $0.id == course.id }) {
                            self.courses.remove(at: updatedCourseIndex)
                            self.courses = self.sort(courses: self.courses)
                            self.delegate?.documentsDidUpdate()
                        }
                    }
                }
            }
        }
        db.collection("lecturers").addSnapshotListener {
            querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach {
                diff in
                
                //TODO DRY depending on how similar the added, modified, and removed response are
                switch diff.type {
                case .added:
                    var lecturerDictionary = diff.document.data()
                    lecturerDictionary["id"] = diff.document.documentID
                    if let lecturer = Lecturer.from(lecturerDictionary as NSDictionary) {
                        if self.lecturers.first(where: { $0.id == lecturer.id }) != nil {
                            return
                        }
                        self.lecturers.append(lecturer)
                        self.delegate?.documentsDidUpdate()
                    }
                case .modified:
                    var lecturerDictionary = diff.document.data()
                    lecturerDictionary["id"] = diff.document.documentID
                    if let lecturer = Lecturer.from(lecturerDictionary as NSDictionary) {
                        if let updatedLecturerIndex = self.lecturers.index(where: { $0.id == lecturer.id }) {
                            self.lecturers[updatedLecturerIndex] = lecturer
                        }
                        else {
                            self.lecturers.append(lecturer)
                        }
                        self.delegate?.documentsDidUpdate()
                    }
                case .removed:
                    var lecturerDictionary = diff.document.data()
                    lecturerDictionary["id"] = diff.document.documentID
                    if let lecturer = Lecturer.from(lecturerDictionary as NSDictionary) {
                        if let updatedLecturerIndex = self.lecturers.index(where: { $0.id == lecturer.id }) {
                            self.lecturers.remove(at: updatedLecturerIndex)
                            self.delegate?.documentsDidUpdate()
                        }
                    }
                }
            }
        }
        db.collection("rooms").addSnapshotListener {
            querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach {
                diff in
                
                //TODO DRY depending on how similar the added, modified, and removed response are
                switch diff.type {
                case .added:
                    var roomDictionary = diff.document.data()
                    roomDictionary["id"] = diff.document.documentID
                    if let room = Room.from(roomDictionary as NSDictionary) {
                        if self.rooms.first(where: { $0.id == room.id }) != nil {
                            return
                        }
                        self.rooms.append(room)
                        self.delegate?.documentsDidUpdate()
                    }
                case .modified:
                    var roomDictionary = diff.document.data()
                    roomDictionary["id"] = diff.document.documentID
                    if let room = Room.from(roomDictionary as NSDictionary) {
                        if let updatedRoomIndex = self.rooms.index(where: { $0.id == room.id }) {
                            self.rooms[updatedRoomIndex] = room
                        }
                        else {
                            self.rooms.append(room)
                        }
                        self.delegate?.documentsDidUpdate()
                    }
                case .removed:
                    var roomDictionary = diff.document.data()
                    roomDictionary["id"] = diff.document.documentID
                    if let room = Room.from(roomDictionary as NSDictionary) {
                        if let updatedRoomIndex = self.rooms.index(where: { $0.id == room.id }) {
                            self.rooms.remove(at: updatedRoomIndex)
                            self.delegate?.documentsDidUpdate()
                        }
                    }
                }
            }
        }
    }
}
