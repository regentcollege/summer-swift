import Foundation
import AFDateHelper

class EventViewModel {
    let title: String
    let description: String
    var dateDescription: String?
    var imageUrl: URL?
    let season: Seasons
    var lecturerId: String?
    
    @objc var startDate: Date?
    
    init(event: Event?) {
        if let event = event {
            self.title = event.title
            if let description = event.description {
                self.description = description
            }
            else {
                self.description = "Stay tuned!"
            }
            if let imageUrl = event.imageUrl {
                self.imageUrl = imageUrl
            }
            if let season = event.season {
                self.season = season
            }
            else {
                self.season = Seasons.Spring
            }
            if let startDate = event.startDate, let endDate = event.endDate {
                self.startDate = startDate
                self.dateDescription = format(startDate: startDate, endDate: endDate)
            } else if let startDate = event.startDate {
                self.startDate = startDate
                self.dateDescription = format(date: startDate)
            }
            self.lecturerId = event.lecturerId
        }
        else {
            self.title = "TBD"
            self.description = "Stay tuned!"
            self.dateDescription = "TBD"
            self.season = Seasons.Spring
        }
    }
    
    private func format(date: Date) -> String {
        return date.toString(format: .custom("EEEE, MMM d")) + " at " + date.toString(format: .custom("h:mma"))
    }
    
    private func format(startDate: Date, endDate: Date) -> String {
        if startDate.compare(.isSameDay(as: endDate)) {
            //TODO same AM/PM, same hour, without minutes
            return "\(startDate.toString(format: .custom("MMM d"))) at \(startDate.toString(format: .custom("h:mma"))) to \(endDate.toString(format: .custom("h:mma")))"
        }
        //TODO different month
        //return "\(startDate.toString(format: .custom("EEEE, MMM d"))) at \(startDate.toString(format: .custom("h:mma"))) - \(endDate.toString(format: .custom("EEEE, MMM d"))) at \(endDate.toString(format: .custom("h:mma")))"
        let startDateFormatted = startDate.toString(format: .custom("MMM d"))
        let endDateFormatted = endDate.toString(format: .custom("d"))
        let startTime = startDate.toString(format: .custom("h:mma"))
        let endTime = endDate.toString(format: .custom("h:mma"))
        return startDateFormatted + "-" + endDateFormatted + ", " + startTime + " to " + endTime
    }
}
