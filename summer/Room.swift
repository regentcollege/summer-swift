import Mapper

struct Room: Mappable {
    let id: String
    let title: String
    var directionImageUrls: [String]?
    
    init(map: Mapper) throws {
        id = try map.from("id")
        title = try map.from("title")
        directionImageUrls = map.optionalFrom("directionImageUrls")
    }
}
