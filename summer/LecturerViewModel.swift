import Foundation

class LecturerViewModel {
    var id: String?
    let name: String
    let bio: String
    var imageUrl: URL?
    var videoUrl: URL?
    let hasDetail: Bool
    
    init(lecturer: Lecturer?) {
        if let lecturer = lecturer {
            self.id = lecturer.id
            self.name = "\(lecturer.firstName) \(lecturer.lastName)"
            if let bio = lecturer.bio {
                self.bio = bio
            }
            else {
                self.bio = "Stay tuned!"
            }
            self.imageUrl = lecturer.imageUrl
            self.videoUrl = lecturer.videoUrl
            self.hasDetail = true
        }
        else {
            self.name = "TBD"
            self.bio = "Stay tuned!"
            self.hasDetail = false
        }
    }
}
