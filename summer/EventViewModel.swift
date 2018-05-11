import Foundation
import AFDateHelper

class EventViewModel {
    var id: String
    let title: String
    let description: String
    var dateDescription: String?
    var dateDescriptionFullMonth: String?
    var url: URL?
    var imageUrl: URL?
    var room: String?
    let season: Seasons
    var lecturerId: String?
    var groupScheduleByDay: Bool = false
    var isEPL: Bool = false
    
    @objc var startDate: Date?
    @objc var endDate: Date?
    
    init(event: Event?, showTimeOnly: Bool = false) {
        if let event = event {
            self.id = event.id
            self.title = event.title
            if let groupScheduleByDay = event.groupScheduleByDay {
                self.groupScheduleByDay = groupScheduleByDay
            }
            if let isEPL = event.isEPL {
                self.isEPL = isEPL
            }
            if let description = event.description {
                self.description = description
            }
            else {
                self.description = "Stay tuned!"
            }
            
            self.url = event.url
            self.imageUrl = event.imageUrl
            
            if let season = event.season {
                self.season = season
            }
            else {
                self.season = Seasons.Spring
            }
            if let startDate = event.startDate, let endDate = event.endDate {
                self.startDate = startDate
                self.endDate = endDate
                self.dateDescription = format(startDate: startDate, endDate: endDate, showTimeOnly: showTimeOnly)
                self.dateDescriptionFullMonth = format(startDate: startDate, endDate: endDate, fullMonth: true, showTimeOnly: showTimeOnly)
            } else if let startDate = event.startDate {
                self.startDate = startDate
                self.dateDescription = format(date: startDate)
                self.dateDescriptionFullMonth = format(date: startDate, fullMonth: true)
            }
            self.lecturerId = event.lecturerId
            self.room = event.room
        }
        else {
            self.id = UUID().uuidString
            self.title = "TBD"
            self.description = "Stay tuned!"
            self.dateDescription = "TBD"
            self.season = Seasons.Spring
        }
    }
    
    private func format(date: Date, fullMonth: Bool = false, showTimeOnly: Bool = false) -> String {
        if showTimeOnly {
            return date.toString(format: .custom("h:mma"))
        }
        if fullMonth {
            return date.toString(format: .custom("EEEE, MMMM d")) + " at " + date.toString(format: .custom("h:mma"))
        }
        
        return date.toString(format: .custom("EEEE, MMM d")) + " at " + date.toString(format: .custom("h:mma"))
    }
    
    private func format(startDate: Date, endDate: Date, fullMonth: Bool = false, showTimeOnly: Bool = false) -> String {
        if showTimeOnly {
            return "\(startDate.toString(format: .custom("h:mma"))) to \(endDate.toString(format: .custom("h:mma")))"
        }
        if startDate.compare(.isSameDay(as: endDate)) {
            return "\(startDate.toString(format: .custom("MMM d"))), \(startDate.toString(format: .custom("h:mma"))) to \(endDate.toString(format: .custom("h:mma")))"
        }

        var startDateFormatted = startDate.toString(format: .custom("MMM d"))
        if fullMonth {
            startDateFormatted = startDate.toString(format: .custom("MMMM d"))
        }
        var endDateFormatted = endDate.toString(format: .custom("d"))
        if !startDate.compare(.isSameMonth(as: endDate)) {
            endDateFormatted = endDate.toString(format: .custom("MMM d"))
            if fullMonth {
                endDateFormatted = endDate.toString(format: .custom("MMMM d"))
            }
        }
        let startTime = startDate.toString(format: .custom("h:mma"))
        let endTime = endDate.toString(format: .custom("h:mma"))
        return startDateFormatted + "-" + endDateFormatted + ", " + startTime + " to " + endTime
    }
}
