import Foundation

class LecturerViewModel {
    var id: String?
    let name: String
    let bio: String
    var imageUrl: URL?
    var placeholderImageName: String?
    var videoUrl: URL?
    let hasDetail: Bool
    
    init(lecturer: Lecturer?) {
        if let lecturer = lecturer {
            id = lecturer.id
            name = "\(lecturer.firstName) \(lecturer.lastName)"
            if let bio = lecturer.bio {
                self.bio = bio
            }
            else {
                bio = "Stay tuned!"
            }
            if let imageUrl = lecturer.imageUrl {
                self.imageUrl = imageUrl
            }
            else {
                placeholderImageName = "lecturer_240"
            }
            
            videoUrl = lecturer.videoUrl
            hasDetail = true
        }
        else {
            name = "TBD"
            bio = "Stay tuned!"
            hasDetail = false
            placeholderImageName = "lecturer_240"
        }
    }
}
