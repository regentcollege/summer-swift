import Foundation
import AFDateHelper

class EventViewModel {
    var id: String?
    let title: String
    let description: String
    var dateDescription: String?
    var dateDescriptionFullMonth: String?
    var imageUrl: URL?
    let season: Seasons
    var lecturerId: String?
    
    var schedule: [EventScheduleViewModel]?
    
    @objc var startDate: Date?
    @objc var endDate: Date?
    
    init(event: Event?) {
        if let event = event {
            self.id = event.id
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
                self.endDate = endDate
                self.dateDescription = format(startDate: startDate, endDate: endDate)
                self.dateDescriptionFullMonth = format(startDate: startDate, endDate: endDate, fullMonth: true)
            } else if let startDate = event.startDate {
                self.startDate = startDate
                self.dateDescription = format(date: startDate)
                self.dateDescriptionFullMonth = format(date: startDate, fullMonth: true)
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
    
    private func format(date: Date, fullMonth: Bool = false) -> String {
        if fullMonth {
            return date.toString(format: .custom("EEEE, MMMM d")) + " at " + date.toString(format: .custom("h:mma"))
        }
        
        return date.toString(format: .custom("EEEE, MMM d")) + " at " + date.toString(format: .custom("h:mma"))
    }
    
    private func format(startDate: Date, endDate: Date, fullMonth: Bool = false) -> String {
        if startDate.compare(.isSameDay(as: endDate)) {
            //TODO same AM/PM, same hour, without minutes
            return "\(startDate.toString(format: .custom("MMM d"))) at \(startDate.toString(format: .custom("h:mma"))) to \(endDate.toString(format: .custom("h:mma")))"
        }
        //TODO different month
        //return "\(startDate.toString(format: .custom("EEEE, MMM d"))) at \(startDate.toString(format: .custom("h:mma"))) - \(endDate.toString(format: .custom("EEEE, MMM d"))) at \(endDate.toString(format: .custom("h:mma")))"
        var startDateFormatted = startDate.toString(format: .custom("MMM d"))
        if fullMonth {
            startDateFormatted = startDate.toString(format: .custom("MMMM d"))
        }
        let endDateFormatted = endDate.toString(format: .custom("d"))
        let startTime = startDate.toString(format: .custom("h:mma"))
        let endTime = endDate.toString(format: .custom("h:mma"))
        return startDateFormatted + "-" + endDateFormatted + ", " + startTime + " to " + endTime
    }
}
