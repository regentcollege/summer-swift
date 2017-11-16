import UIKit

class CourseCell: UITableViewCell {
    @IBOutlet var courseTitleLabel: UILabel!
    @IBOutlet var lecturerNameLabel: UILabel!
    @IBOutlet var lecturerImageView: UIImageView!
    
    func configureWith(course: CourseViewModel, lecturer: LecturerViewModel) {
        courseTitleLabel?.text = course.title
        lecturerNameLabel?.text = lecturer.name
        
        if let imageUrl = lecturer.imageUrl {
            lecturerImageView.kf.setImage(with: imageUrl)
        } else if let placeholderImageName = lecturer.placeholderImageName {
            lecturerImageView.image = UIImage(named: placeholderImageName)
        }
    }
}
