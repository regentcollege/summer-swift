import UIKit
import Kingfisher
import Atributika

class CourseDetailViewController: UIViewController {
    
    @IBOutlet var lecturerImageView: UIImageView!
    @IBOutlet var lecturerNameLabel: UILabel!
    @IBOutlet var courseDescriptionTitleLabel: UILabel!
    @IBOutlet var courseDescriptionLabel: UILabel!
    @IBOutlet var detailChevronImage: UIImageView!
    
    var course: CourseViewModel! {
        didSet {
            navigationItem.title = course.title
        }
    }
    var lecturer: LecturerViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lecturerNameLabel.text = lecturer.name

        if let imageUrl = lecturer.imageUrl {
            lecturerImageView.kf.setImage(with: imageUrl)
        } else if let placeholderImageName = lecturer.placeholderImageName {
            lecturerImageView.image = UIImage(named: placeholderImageName)
        }
        
        if !lecturer.hasDetail {
            detailChevronImage.isHidden = true
        }
        
        courseDescriptionTitleLabel.text = "Course Description"

        let h1 = Style("h1").font(Config.headerFont)
        let em = Style("em").font(Config.obliqueFont)
        let str = course.description.style(tags: h1, em)
            .styleAll(Style.font(Config.paragraphFont))
            .attributedString
        courseDescriptionLabel.attributedText = str
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = self.splitViewController!.displayModeButtonItem
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if !lecturer.hasDetail { return false }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showLecturer"?:
            if lecturer.hasDetail {
                let lecturerDetailViewController = segue.destination as! LecturerDetailViewController
                lecturerDetailViewController.lecturer = lecturer
            }
        default:
            preconditionFailure("Unexpected segue identifer")
        }
    }
}
