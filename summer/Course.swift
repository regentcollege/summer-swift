import Mapper

enum Seasons: String {
    case Spring = "spring"
    case Summer = "summer"
}

struct Course: Mappable {
    let id: String
    let name: String
    let title: String
    let description: String?
    let lecturerId: String?
    let auditHours: String?
    let creditHours: String?
    let meetingTime: String?
    let room: String?
    let roomId: String?
    let term: String?
    let reportingTerm: String?
    let season: Seasons?
    
    // extending Mappable to let us extract dates requires mutable var
    var startDate: Date?
    var endDate: Date?
    
    init(map: Mapper) throws {
        id = try map.from("id")
        name = try map.from("name")
        title = try map.from("title")
        description = map.optionalFrom("description")
        lecturerId = map.optionalFrom("lecturerId")
        auditHours = map.optionalFrom("auditHours")
        creditHours = map.optionalFrom("creditHours")
        meetingTime = map.optionalFrom("meetingTime")
        room = map.optionalFrom("room")
        roomId = map.optionalFrom("roomId")
        term = map.optionalFrom("term")
        reportingTerm = map.optionalFrom("reportingTerm")
        season = map.optionalFrom("season")
        startDate = map.optionalFrom("startDate", transformation: extractDate)
        endDate = map.optionalFrom("endDate", transformation: extractDate)
    }
}
