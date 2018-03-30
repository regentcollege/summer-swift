import Foundation

class CourseViewModel {
    let title: String
    let description: String
    let season: Seasons
    var lecturerId: String?
    var dates: String
    var startDate: Date?
    var endDate: Date?
    var meetingTime: String
    var room: String?
    var roomId: String?
    
    init(course: Course?) {
        if let course = course {
            self.title = course.title
            if let description = course.description {
                self.description = description
            }
            else {
                self.description = "Stay tuned!"
            }
            if let season = course.season {
                self.season = season
            }
            else {
                self.season = Seasons.Spring
            }
            self.lecturerId = course.lecturerId
            
            if let room = course.room {
                self.room = room
            }
            if let roomId = course.roomId {
                self.roomId = roomId
            }
            
            self.startDate = course.startDate
            self.endDate = course.endDate
            
            self.dates = "Dates TBD"
            if let startDate = course.startDate {
                var dateText = startDate.toString(format: .custom("MMM d"))
                if let endDate = course.endDate {
                    dateText += "-"+endDate.toString(format: .custom("MMM d"))
                }
                self.dates = dateText
            }
            self.meetingTime = ""
            if let meetingTime = course.meetingTime {
                self.meetingTime = meetingTime
            }
        }
        else {
            self.title = "TBD"
            self.description = "Stay tuned!"
            self.dates = "Dates TBD"
            self.meetingTime = ""
            self.season = Seasons.Spring
        }
    }
}
