import UIKit
import Kingfisher
import Atributika

class EventDetailViewController: UIViewController {
    @IBOutlet var eventImageView: UIImageView!
    //@IBOutlet var lecturerImageView: UIImageView!
    //@IBOutlet var lecturerNameLabel: UILabel!
    @IBOutlet var eventTitleLabel: UILabel!
    @IBOutlet var eventDateLabel: UILabel!
    @IBOutlet var eventDescriptionLabel: UILabel!
    @IBOutlet var descriptionToImageConstraint: NSLayoutConstraint!
    @IBOutlet var descriptionToDateConstraint: NSLayoutConstraint!
    
    var event: EventViewModel! {
        didSet {
            navigationItem.title = event.title
        }
    }
    var lecturer: LecturerViewModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if let lecturer = lecturer {
//            lecturerNameLabel.text = lecturer.name
//
//            if let imageUrl = lecturer.imageUrl {
//                lecturerImageView.kf.setImage(with: imageUrl)
//            } else if let placeholderImageName = lecturer.placeholderImageName {
//                lecturerImageView.image = UIImage(named: placeholderImageName)
//            }
//        }
        
        if event == nil {
            return
        }
        
        if let eventImageUrl = event.imageUrl {
            eventImageView.kf.setImage(with: eventImageUrl)
        }
        else {
            eventImageView.isHidden = true
            descriptionToImageConstraint.priority = UILayoutPriority(rawValue: 500)
            descriptionToDateConstraint.priority = UILayoutPriority(rawValue: 999)
        }
        
        eventTitleLabel.text = event.title
        eventDateLabel.text = event.dateDescriptionFullMonth
        eventDescriptionLabel.text = "Event Description"

        let str = event.description.style(tags: [Settings.Style.h1, Settings.Style.em, Settings.Style.strong], transformers: Settings.Style.transformers)
            .styleAll(Settings.Style.paragraph)
            .attributedString
        eventDescriptionLabel.attributedText = str
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = self.splitViewController!.displayModeButtonItem
    }
}
