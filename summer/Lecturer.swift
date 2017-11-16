import Mapper

struct Lecturer: Mappable {
    let id: String
    let firstName: String
    let lastName: String
    let imageUrl: URL?
    let bio: String?
    let videoUrl: URL?
    
    init(map: Mapper) throws {
        id = try map.from("id")
        firstName = try map.from("firstName")
        lastName = try map.from("lastName")
        imageUrl = map.optionalFrom("imageUrl")
        bio = map.optionalFrom("bio")
        videoUrl = map.optionalFrom("videoUrl")
    }
}
