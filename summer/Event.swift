import Mapper

struct Event: Mappable {
    let id: String
    let title: String
    let description: String?
    let url: URL?
    let imageUrl: URL?
    let lecturerId: String?
    let room: String?
    let season: Seasons?
    let groupScheduleByDay: Bool?
    
    var startDate: Date?
    var endDate: Date?
    
    init(map: Mapper) throws {
        id = try map.from("id")
        title = try map.from("title")
        description = map.optionalFrom("description")
        url = map.optionalFrom("url")
        imageUrl = map.optionalFrom("imageUrl")
        lecturerId = map.optionalFrom("lecturerId")
        room = map.optionalFrom("room")
        season = map.optionalFrom("season")
        groupScheduleByDay = map.optionalFrom("groupScheduleByDay")
        
        startDate = map.optionalFrom("startDate", transformation: extractDate)
        endDate = map.optionalFrom("endDate", transformation: extractDate)
    }
}
