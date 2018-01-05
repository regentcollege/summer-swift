import UIKit
import AFDateHelper

class PromoCell: UITableViewCell {
    @IBOutlet var startDateLabel: UILabel!
    
    func configureWith(event: EventViewModel?, course: CourseViewModel?) {
        if let event = event, let eventStartDate = event.startDate {
            startDateLabel?.text = "\(eventStartDate.since(Date(), in: .week)) weeks until our first event"
        }
        if let course = course, let courseStartDate = course.startDate {
            var courseStartDateLabel = "\(courseStartDate.since(Date(), in: .week)) weeks until our first course"
            if startDateLabel?.text != nil {
                courseStartDateLabel = "\n" + courseStartDateLabel
            }
            startDateLabel?.text = startDateLabel.text! + courseStartDateLabel
        }
    }
}
