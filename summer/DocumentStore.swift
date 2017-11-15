import Foundation
import Firebase
import Kingfisher

protocol DocumentStoreDelegate: class {
    func documentsDidUpdate()
}

class DocumentStore {
    var db: Firestore!
    private var courses = [Course]()
    private var lecturers = [Lecturer]()
    
    var delegate: DocumentStoreDelegate?
    
    init() {
        FirebaseApp.configure()
        db = Firestore.firestore()
        loadData()
        checkForUpdates()
    }
    
    func allCourses() -> [CourseViewModel] {
        return courses.map { CourseViewModel(course: $0) }
    }
    
    func allLecturers() -> [LecturerViewModel] {
        return lecturers.map { LecturerViewModel(lecturer: $0) }
    }
    
    func loadData() {
        db.collection("courses").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                self.courses = querySnapshot!.documents.flatMap({
                    guard var course = Course.from($0.data() as NSDictionary) else {
                        return nil
                    }
                    course.id = $0.documentID
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
                    guard var lecturer = Lecturer.from($0.data() as NSDictionary) else {
                        return nil
                    }
                    lecturer.id = $0.documentID
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
    
    func checkForUpdates() {
        db.collection("courses").addSnapshotListener {
            querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach {
                diff in
                
                switch diff.type {
                case .added:
                    if let course = Course.from(diff.document.data() as NSDictionary) {
                        if self.courses.first(where: { $0.id == course.id }) != nil {
                            return
                        }
                        self.courses.append(course)
                    }
                case .modified:
                    return
                case .removed:
                    return
                }
            }
            //self.delegate?.documentsDidUpdate()
        }
        db.collection("lecturers").addSnapshotListener {
            querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach {
                diff in
                
                switch diff.type {
                case .added:
                    if let lecturer = Lecturer.from(diff.document.data() as NSDictionary) {
                        if self.lecturers.first(where: { $0.id == lecturer.id }) != nil {
                            return
                        }
                        self.lecturers.append(lecturer)
                    }
                case .modified:
                    return
                case .removed:
                    return
                }
            }
            //self.delegate?.documentsDidUpdate()
        }
    }
}
