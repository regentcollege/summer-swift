import UIKit

class EventCell: UITableViewCell {
    @IBOutlet var eventTitleLabel: UILabel!
    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet var eventDateLabel: UILabel!
    
    func configureWith(event: EventViewModel, lecturer: LecturerViewModel?) {
        eventTitleLabel?.text = event.title
        eventDateLabel?.text = event.dateDescription
        if let imageUrl = event.imageUrl {
            eventImageView.kf.setImage(with: imageUrl)
            eventImageView.isHidden = false
        }
        else {
            eventImageView.image = nil
            eventImageView.isHidden = true
        }
    }
}
