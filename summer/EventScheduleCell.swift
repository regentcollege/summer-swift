import UIKit
import SwipeCellKit

class EventScheduleCell: SwipeTableViewCell {
    @IBOutlet var eventScheduleTitleLabel: UILabel!
    @IBOutlet var eventScheduleDateLabel: UILabel!
    
    func configureWith(schedule: EventScheduleViewModel) {
        eventScheduleTitleLabel?.text = schedule.title
        eventScheduleDateLabel?.text = schedule.dateDescription
        eventScheduleDateLabel?.textColor = Settings.Color.blue
    }
}
