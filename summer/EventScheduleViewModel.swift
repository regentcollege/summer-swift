import Foundation
import AFDateHelper

class EventScheduleViewModel {
    var id: String
    let title: String
    var subtitle: String?
    var speaker: String?
    var dateDescription: String?
    
    @objc var start: Date?
    @objc var end: Date?
    
    init(schedule: EventSchedule?, showTimeOnly: Bool = false) {
        if let schedule = schedule {
            self.id = schedule.id
            self.title = schedule.title
            self.subtitle = schedule.subtitle
            self.speaker = schedule.speaker
            if let start = schedule.start, let end = schedule.end {
                self.start = start
                self.end = end
                if showTimeOnly {
                    self.dateDescription = formatTimeOnly(start: start, end: end)
                }
                else {
                    self.dateDescription = format(start: start, end: end)
                }
            } else if let start = schedule.start {
                self.start = start
                if showTimeOnly {
                    self.dateDescription = formatTimeOnly(date: start)
                }
                else {
                    self.dateDescription = format(date: start)
                }
            }
        }
        else {
            self.id = UUID().uuidString
            self.title = "TBD"
            self.dateDescription = "TBD"
        }
    }
    
    private func format(date: Date) -> String {
        return date.toString(format: .custom("EEE, MMM d")) + " at " + date.toString(format: .custom("h:mma"))
    }
    
    private func formatTimeOnly(date: Date) -> String {
        return date.toString(format: .custom("h:mma"))
    }
    
    private func format(start: Date, end: Date) -> String {
        return "\(start.toString(format: .custom("EEE, MMM d h:mma"))) to \(end.toString(format: .custom("h:mma")))"
    }
    
    private func formatTimeOnly(start: Date, end: Date) -> String {
        return "\(start.toString(format: .custom("h:mma"))) to \(end.toString(format: .custom("h:mma")))"
    }
}
