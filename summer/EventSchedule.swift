import Mapper

struct EventSchedule: Mappable {
    let id: String
    let title: String
    var start: Date?
    var end: Date?
    
    init(map: Mapper) throws {
        id = try map.from("id")
        title = try map.from("title")
        start = map.optionalFrom("start", transformation: extractDate)
        end = map.optionalFrom("end", transformation: extractDate)
    }
}
