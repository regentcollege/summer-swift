import UIKit
import Atributika

protocol EventCellDelegate: class {
    func reloadTableForEventCellChange()
}

class EventCell: UITableViewCell {
    @IBOutlet var eventTitleLabel: UILabel!
    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet var eventDateLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    
    var delegate: EventCellDelegate?
    var eventDescription: AttributedLabel?
    
    func configureWith(event: EventViewModel, lecturer: LecturerViewModel?, showEventDescription: Bool = false, limitEventDescription: Bool = true) {
        eventTitleLabel?.text = event.title
        eventDateLabel?.text = event.dateDescription
        eventDateLabel?.textColor = Settings.Color.blue
        
        if let imageUrl = event.imageUrl {
            eventImageView.kf.setImage(with: imageUrl)
            eventImageView.isHidden = false
        }
        else {
            eventImageView.image = nil
            eventImageView.isHidden = true
        }
        
        // the cell can be reused, so don't lay this out more than once
        if showEventDescription && eventDescription == nil {
            let eventDescriptionBuilder = event.description.toAttributedLabel()
            eventDescriptionBuilder.textAlignment = NSTextAlignment.natural
            eventDescriptionBuilder.lineBreakMode = NSLineBreakMode.byTruncatingTail
            eventDescriptionBuilder.numberOfLines = 0
            if limitEventDescription {
                eventDescriptionBuilder.numberOfLines = 10
            }
            
            self.eventDescription = eventDescriptionBuilder
            
            stackView.addArrangedSubview(eventDescriptionBuilder)
            
            if limitEventDescription {
                let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
                button.setTitle("More", for: .normal)
                button.setTitleColor(Settings.Color.blue, for: .normal)
                button.contentHorizontalAlignment = .right
                button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                
                stackView.addArrangedSubview(button)
            }
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        eventDescription?.numberOfLines = 0
        eventDescription?.lineBreakMode = NSLineBreakMode.byWordWrapping
        delegate?.reloadTableForEventCellChange()
        sender.isHidden = true
    }
}
