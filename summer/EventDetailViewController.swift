import UIKit
import Kingfisher
import Atributika

class EventDetailViewController: UIViewController {
    @IBOutlet var eventImageView: UIImageView!
    //@IBOutlet var lecturerImageView: UIImageView!
    //@IBOutlet var lecturerNameLabel: UILabel!
    @IBOutlet var eventTitleLabel: UILabel!
    @IBOutlet var eventDateLabel: UILabel!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var scheduleTableContainerView: UIView!
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
        
        eventTitleLabel.text = event.title
        eventDateLabel.text = event.dateDescriptionFullMonth
        eventDateLabel.textColor = Settings.Color.blue
        
        let eventDescription = event.description.toAttributedLabel()
        
        eventDescription.textAlignment = NSTextAlignment.natural
        
        contentView.addSubview(eventDescription)
        
        let marginGuide = contentView.layoutMarginsGuide
        
        eventDescription.translatesAutoresizingMaskIntoConstraints = false
        eventDescription.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        eventDescription.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        eventDescription.bottomAnchor.constraint(equalTo: scheduleTableContainerView.topAnchor, constant: 8).isActive = true
        eventDescription.numberOfLines = 0
        
        if let eventImageUrl = event.imageUrl {
            eventImageView.kf.setImage(with: eventImageUrl)
            eventDescription.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 15).isActive = true
        }
        else {
            eventImageView.isHidden = true
            eventDescription.topAnchor.constraint(equalTo: eventDateLabel.bottomAnchor, constant: 15).isActive = true
        }
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = self.splitViewController!.displayModeButtonItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventScheduleViewSegue" {
            let eventScheduleViewController = segue.destination as! EventScheduleViewController
            eventScheduleViewController.eventId = event.id
        }
    }
}
