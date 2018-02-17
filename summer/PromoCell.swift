import UIKit
import AFDateHelper

class PromoCell: UITableViewCell {
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var promoImage: UIImageView!
    
    @IBOutlet var gradientView: UIView!
    func configureWith(event: EventViewModel?, course: CourseViewModel?) {
        if let event = event, let eventStartDate = event.startDate {
            let daysUntilNextEvent = eventStartDate.since(Date(), in: .day)
            if daysUntilNextEvent <= 1 {
                startDateLabel?.text = "Our next event starts tomorrow"
            }
            else if daysUntilNextEvent < 7 {
                startDateLabel?.text = "\(daysUntilNextEvent) days until our next event"
            }
            else if eventStartDate.compare(.isNextWeek) {
                startDateLabel?.text = "One week until our next event"
            }
            else {
                startDateLabel?.text = "\(eventStartDate.since(Date(), in: .week)) weeks until our next event"
            }
        }
        if let course = course, let courseStartDate = course.startDate {
            let daysUntilNextCourse = courseStartDate.since(Date(), in: .day)
            var courseStartDateLabel = ""
            if daysUntilNextCourse <= 1 {
                courseStartDateLabel = "Our next course starts tomorrow"
            }
            else if daysUntilNextCourse < 7 {
                courseStartDateLabel = "\(daysUntilNextCourse) days until our next course"
            }
            else if courseStartDate.compare(.isNextWeek) {
                courseStartDateLabel = "One week until our next course"
            }
            else {
                courseStartDateLabel = "\(courseStartDate.since(Date(), in: .week)) weeks until our next course"
            }
            
            if startDateLabel?.text != nil {
                courseStartDateLabel = "\n" + courseStartDateLabel
            }
            startDateLabel?.text = startDateLabel.text! + courseStartDateLabel
        }
        let gradient = GradientView(frame: self.bounds)
        gradientView.insertSubview(gradient, at: 0)
    }
}
