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
    
    var delegate: DocumentStoreDelegate?
    
    init() {
        FirebaseApp.configure()
        db = Firestore.firestore()
        
        // Is this required? Listening for updates pulls everything down anyway
        //loadData()
        checkForUpdates()
    }
    
    func getCourses() -> [CourseViewModel] {
        return courses.map { CourseViewModel(course: $0) }
    }
    
    func getCoursesBy(season: Seasons) -> [CourseViewModel] {
        return courses.filter { $0.season == season }.map { CourseViewModel(course: $0) }
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
                
                let urls = self.lecturers
                    .map { $0.imageUrl! }
                let prefetcher = ImagePrefetcher(urls: urls) {
                    skippedResources, failedResources, completedResources in
                    print("These resources are prefetched: \(completedResources)")
                }
                prefetcher.start()
                
                self.delegate?.documentsDidUpdate()
            }
        }
    }
    
    private func checkForUpdates() {
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
