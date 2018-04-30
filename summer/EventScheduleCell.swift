import UIKit
import SwipeCellKit

class EventScheduleCell: SwipeTableViewCell {
    @IBOutlet var eventScheduleTitleLabel: UILabel!
    @IBOutlet var eventScheduleDateLabel: UILabel!
    @IBOutlet var eventScheduleSubtitleLabel: UILabel!
    @IBOutlet var eventScheduleSpeakerLabel: UILabel!
    
    func configureWith(schedule: EventScheduleViewModel) {
        eventScheduleTitleLabel?.text = schedule.title
        eventScheduleDateLabel?.text = schedule.dateDescription
        eventScheduleDateLabel?.textColor = Settings.Color.blue
        
        eventScheduleSubtitleLabel?.isHidden = true
        if let subtitle = schedule.subtitle {
            eventScheduleSubtitleLabel?.text = subtitle
            eventScheduleSubtitleLabel?.isHidden = false
        }
        
        eventScheduleSpeakerLabel?.isHidden = true
        if let speaker = schedule.speaker {
            eventScheduleSpeakerLabel?.text = speaker
            eventScheduleSpeakerLabel?.isHidden = false
        }
    }
}
