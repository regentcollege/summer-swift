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

        let link = Style
            .foregroundColor(.blue, .normal)
            .foregroundColor(.brown, .highlighted)
        
        let eventDescription = AttributedLabel()
        eventDescription.attributedText = event.description
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .style(tags: [Settings.Style.h1, Settings.Style.h3, Settings.Style.em, Settings.Style.strong], transformers: Settings.Style.transformers)
            .styleLinks(link)
            .styleAll(Settings.Style.paragraph)
        
        eventDescription.onClick = { label, detection in
            switch detection.type {
            case .link(let url):
                UIApplication.shared.open(url)
            default:
                break
            }
        }
        
        eventDescription.textAlignment = NSTextAlignment.natural
        
        contentView.addSubview(eventDescription)
        
        let marginGuide = contentView.layoutMarginsGuide
        
        eventDescription.translatesAutoresizingMaskIntoConstraints = false
        eventDescription.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        eventDescription.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        eventDescription.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
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
}
