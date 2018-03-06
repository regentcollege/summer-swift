import Foundation
import AFDateHelper

class EventScheduleViewModel {
    let title: String
    var dateDescription: String?
    
    @objc var start: Date?
    @objc var end: Date?
    
    init(schedule: EventSchedule?) {
        if let schedule = schedule {
            self.title = schedule.title
            if let start = schedule.start, let end = schedule.end {
                self.start = start
                self.end = end
                self.dateDescription = format(start: start, end: end)
            } else if let start = schedule.start {
                self.start = start
                self.dateDescription = format(date: start)
            }
        }
        else {
            self.title = "TBD"
            self.dateDescription = "TBD"
        }
    }
    
    private func format(date: Date) -> String {
        return date.toString(format: .custom("EEE, MMM d")) + " at " + date.toString(format: .custom("h:mma"))
    }
    
    private func format(start: Date, end: Date) -> String {
        return "\(start.toString(format: .custom("EEE, MMM d h:mma"))) to \(end.toString(format: .custom("h:mma")))"
    }
}
