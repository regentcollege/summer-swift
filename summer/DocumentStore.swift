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
    
    var delegate: DocumentStoreDelegate?
    
    init() {
        FirebaseApp.configure()
        db = Firestore.firestore()
        
        loadData()
        checkForUpdates()
    }

    func getEvents() -> [EventViewModel] {
        return events.map { EventViewModel(event: $0) }
    }
    
    func getEventsHappening(now: Date) -> [EventViewModel] {
        let eventsWithDates = events.filter { $0.startDate != nil && $0.endDate != nil }
        return eventsWithDates.filter { $0.startDate!.compare(.isSameDay(as: now)) ||
            $0.endDate!.compare(.isSameDay(as: now)) ||
            $0.startDate!.compare(.isEarlier(than: now)) && $0.endDate!.compare(.isLater(than: now)) }.map { EventViewModel(event: $0) }
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
    
    private func loadData() {
        db.collection("events").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                var eventsToSort = [Event]()
                eventsToSort = querySnapshot!.documents.flatMap({
                    var eventDictionary = $0.data()
                    eventDictionary["id"] = $0.documentID
                    guard let event = Event.from(eventDictionary as NSDictionary) else {
                        return nil
                    }
                    return event
                })
                
                let eventsWithoutStartDates = eventsToSort.filter {$0.startDate == nil }
                let eventsWithStartDates = eventsToSort.filter { $0.startDate != nil }.sorted(by: { $0.startDate! < $1.startDate! })
                self.events = eventsWithoutStartDates + eventsWithStartDates
                
                self.prefetchImageUrls(urls: self.events.filter({ $0.imageUrl != nil }).map({ $0.imageUrl! }))
                
                self.delegate?.documentsDidUpdate()
            }
        }
        db.collection("courses").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                self.courses = querySnapshot!.documents.flatMap({
                    var courseDictionary = $0.data()
                    courseDictionary["id"] = $0.documentID
                    guard let course = Course.from(courseDictionary as NSDictionary) else {
                        return nil
                    }
                    return course
                })
                self.delegate?.documentsDidUpdate()
            }
        }
        db.collection("lecturers").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                self.lecturers = querySnapshot!.documents.flatMap({
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
                
                switch diff.type {
                case .added:
                    var eventDictionary = diff.document.data()
                    eventDictionary["id"] = diff.document.documentID
                    if let event = Event.from(eventDictionary as NSDictionary) {
                        if self.events.first(where: { $0.id == event.id }) != nil {
                            return
                        }
                        self.events.append(event)
                        self.delegate?.documentsDidUpdate()
                    }
                case .modified:
                    return
                case .removed:
                    return
                }
            }
        }
        db.collection("courses").addSnapshotListener {
            querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach {
                diff in
                
                switch diff.type {
                case .added:
                    var courseDictionary = diff.document.data()
                    courseDictionary["id"] = diff.document.documentID
                    if let course = Course.from(courseDictionary as NSDictionary) {
                        if self.courses.first(where: { $0.id == course.id }) != nil {
                            return
                        }
                        self.courses.append(course)
                        self.delegate?.documentsDidUpdate()
                    }
                case .modified:
                    return
                case .removed:
                    return
                }
            }
        }
        db.collection("lecturers").addSnapshotListener {
            querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach {
                diff in
                
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
                    return
                case .removed:
                    return
                }
            }
        }
    }
}
