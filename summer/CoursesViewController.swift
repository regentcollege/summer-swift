import UIKit

class CoursesViewController: UIViewController, DocumentStoreDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var springSummerSegmentedControl: UISegmentedControl!
    
    var documentStore: DocumentStore!
    
    var coursesBySegment: [CourseViewModel] {
        switch springSummerSegmentedControl.selectedSegmentIndex {
        case 0:
            return documentStore.getCoursesBy(season: Seasons.Spring)
        case 1:
            return documentStore.getCoursesBy(season: Seasons.Summer)
        default:
            return documentStore.getCoursesBy(season: Seasons.Spring)
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentStore.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if #available(iOS 11.0, *) {
            // table layout is fine
        }
        else {
            self.automaticallyAdjustsScrollViewInsets = false
            springSummerSegmentedControl.setWidth(CGFloat(170), forSegmentAt: 0)
            springSummerSegmentedControl.setWidth(CGFloat(170), forSegmentAt: 1)
        }
        
        springSummerSegmentedControl.tintColor = Settings.Color.blue
        let font: [AnyHashable : Any] = [NSAttributedStringKey.font : Settings.Font.subHeaderFont]
        springSummerSegmentedControl.setTitleTextAttributes(font, for: .normal)
        
        if let splitViewController = self.splitViewController, !splitViewController.isCollapsed {
            let initialIndexPath = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: initialIndexPath, animated: true, scrollPosition:UITableViewScrollPosition.none)
            self.performSegue(withIdentifier: "showCourse", sender: initialIndexPath)
            self.tableView.deselectRow(at: initialIndexPath, animated: false)
        }
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
                courseDetailViewController.lecturer = documentStore.getLecturerBy(id: course.lecturerId)
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
            cell.configureWith(course: course, lecturer: documentStore.getLecturerBy(id: course.lecturerId))
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
