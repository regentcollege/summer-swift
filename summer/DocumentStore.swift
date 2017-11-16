import Foundation
import Firebase
import Kingfisher

protocol DocumentStoreDelegate: class {
    func documentsDidUpdate()
}

class DocumentStore {
    private var courses = [Course]()
    private var lecturers = [Lecturer]()
    
    var delegate: DocumentStoreDelegate?
    
    init() {
        FirebaseApp.configure()
        loadData()
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
        Firestore.firestore().collection("courses").getDocuments() {
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
        Firestore.firestore().collection("lecturers").getDocuments() {
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
    
    private func checkForUpdates() {
        Firestore.firestore().collection("courses").addSnapshotListener {
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
                        self.delegate?.documentsDidUpdate()
                    }
                case .modified:
                    return
                case .removed:
                    return
                }
            }
        }
        Firestore.firestore().collection("lecturers").addSnapshotListener {
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
