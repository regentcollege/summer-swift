import Mapper

enum Seasons: String {
    case Spring = "spring"
    case Summer = "summer"
}

// Mapper does not have String to Date OOB
private func extractDate(object: Any?) throws -> Date {
    guard let date = object as? Date else {
        throw MapperError.convertibleError(value: object, type: Date.self)
    }
    return date
}

struct Course: Mappable {
    var id: String
    let name: String
    let title: String
    let description: String?
    let lecturerId: String?
    let auditHours: Double?
    let creditHours: Double?
    let room: String?
    let term: String?
    let reportingTerm: String?
    let season: Seasons?
    let startDate: Date?
    let endDate: Date?
    
    init(map: Mapper) throws {
        id = try map.from("id")
        name = try map.from("name")
        title = try map.from("title")
        description = map.optionalFrom("description")
        lecturerId = map.optionalFrom("lecturerId")
        auditHours = map.optionalFrom("auditHours")
        creditHours = map.optionalFrom("creditHours")
        room = map.optionalFrom("room")
        term = map.optionalFrom("term")
        reportingTerm = map.optionalFrom("reportingTerm")
        season = map.optionalFrom("season")
        startDate = map.optionalFrom("startDate", transformation: extractDate)
        endDate = map.optionalFrom("endDate", transformation: extractDate)
    }
}
