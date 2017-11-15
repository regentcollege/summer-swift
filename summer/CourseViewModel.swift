import Foundation

class CourseViewModel {
    let title: String
    let description: String
    let season: Seasons
    var lecturerId: String?
    
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
        }
        else {
            self.title = "TBD"
            self.description = "Stay tuned!"
            self.season = Seasons.Spring
        }
    }
}
