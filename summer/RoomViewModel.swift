import Foundation

class RoomViewModel {
    var id: String?
    let title: String
    var directionImageUrls: [URL]?
    
    init(room: Room?) {
        if let room = room {
            id = room.id
            title = room.title
            if let directionImageUrlStrings = room.directionImageUrls {
                var directionImageUrls = [URL]()
                directionImageUrlStrings.forEach {
                    if let url = URL(string: $0) {
                        directionImageUrls.append(url)
                    }
                }
                self.directionImageUrls = directionImageUrls
            }
        }
        else {
            title = "TBD"
        }
    }
}
