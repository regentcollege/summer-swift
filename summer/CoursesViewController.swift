import UIKit
import Kingfisher

class CoursesViewController: UIViewController, DocumentStoreDelegate {
    @IBOutlet var tableView: UITableView!
    
    var documentStore: DocumentStore?
    
    var coursesBySegment: [CourseViewModel] {
        switch springSummerSegmentedControl.selectedSegmentIndex {
        case 0:
            return documentStore!.allCourses().filter { $0.season == Seasons.Spring }
        case 1:
            return documentStore!.allCourses().filter { $0.season == Seasons.Summer }
        default:
            return documentStore!.allCourses().filter { $0.season == Seasons.Spring }
        }
    }
    
    @IBOutlet var springSummerSegmentedControl: UISegmentedControl!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentStore?.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
        
        springSummerSegmentedControl.tintColor = Color.red
    }
    
    func documentsDidUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showCourse"?:
            if let row = tableView.indexPathForSelectedRow?.row,
                let navViewController = segue.destination as? UINavigationController,
                let courseDetailViewController = navViewController.topViewController as? CourseDetailViewController {
                let course = coursesBySegment[row]
                courseDetailViewController.course = course
                if let lecturer = documentStore?.allLecturers().first(where: { $0.id == course.lecturerId }) {
                    courseDetailViewController.lecturer = lecturer
                }
                else {
                    courseDetailViewController.lecturer = LecturerViewModel(lecturer: nil)
                }
            }
        default:
            preconditionFailure("Unexpected segue identifer")
        }
    }
}

// MARK: - UITableViewDataSource
extension CoursesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coursesBySegment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as? CourseCell {
            let course = coursesBySegment[indexPath.row]
            guard let lecturer = documentStore!.allLecturers().first(where: { $0.id == course.lecturerId })
                else {
                    cell.configureWith(course: course, lecturer: LecturerViewModel(lecturer: nil))
                    return cell
            }
            cell.configureWith(course: course, lecturer: lecturer)
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension CoursesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showCourse", sender: CoursesViewController())
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
