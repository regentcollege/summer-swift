import Mapper

struct Event: Mappable {
    let id: String
    let title: String
    let description: String?
    let imageUrl: URL?
    let lecturerId: String?
    let room: String?
    let season: Seasons?
    let schedule: [EventSchedule]
    
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
        schedule = map.optionalFrom("schedule") ?? []
        
        startDate = map.optionalFrom("startDate", transformation: extractDate)
        endDate = map.optionalFrom("endDate", transformation: extractDate)
    }
}

struct EventSchedule: Mappable {
    let id: String
    let name: String
    var start: Date?
    var end: Date?
    
    init(map: Mapper) throws {
        id = try map.from("id")
        name = try map.from("name")
        start = map.optionalFrom("start", transformation: extractDate)
        end = map.optionalFrom("end", transformation: extractDate)
    }
}
