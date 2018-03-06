import Mapper

struct Event: Mappable {
    let id: String
    let title: String
    let description: String?
    let imageUrl: URL?
    let lecturerId: String?
    let room: String?
    let season: Seasons?
    
    var startDate: Date?
    var endDate: Date?
    
    init(map: Mapper) throws {
        id = try map.from("id")
        title = try map.from("title")
        description = map.optionalFrom("description")
        imageUrl = map.optionalFrom("imageUrl")
        lecturerId = map.optionalFrom("lecturerId")
        room = map.optionalFrom("room")
        season = map.optionalFrom("season")
        
        startDate = map.optionalFrom("startDate", transformation: extractDate)
        endDate = map.optionalFrom("endDate", transformation: extractDate)
    }
}
