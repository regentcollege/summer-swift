import UIKit
import Kingfisher

class CourseCell: UITableViewCell {
    @IBOutlet var courseTitleLabel: UILabel!
    @IBOutlet var courseDateLabel: UILabel!
    @IBOutlet var courseTimeLabel: UILabel!
    @IBOutlet var lecturerNameLabel: UILabel!
    @IBOutlet var lecturerImageView: UIImageView!
    @IBOutlet var roomLabel: UILabel!
    
    func configureWith(course: CourseViewModel, lecturer: LecturerViewModel, room: RoomViewModel) {
        courseTitleLabel?.text = course.title
        lecturerNameLabel?.text = lecturer.name
        lecturerNameLabel?.textColor = Settings.Color.blue
        
        if let imageUrl = lecturer.imageUrl {
            let cropProcessor = CroppingImageProcessor(size: CGSize(width: 240, height: 300), anchor: CGPoint(x: 0, y: 0))
            lecturerImageView.kf.setImage(with: imageUrl, options: [.processor(cropProcessor)])
        } else if let placeholderImageName = lecturer.placeholderImageName {
            lecturerImageView.image = UIImage(named: placeholderImageName)
        }
        
        courseDateLabel.text = course.dates
        courseTimeLabel.text = course.meetingTime
        
        roomLabel.text = room.title
        if !room.hasDetail && course.room != nil {
            roomLabel.text = course.room
        }
    }
}
