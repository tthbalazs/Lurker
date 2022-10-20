import Foundation

struct TopStories: Decodable {
    let ids: [Int]
     
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.ids = try container.decode([Int].self)
    }
}

struct Story: Decodable, Identifiable {
    let id: Int
    let title: String
    let url: URL
    let type: String
    let time: TimeInterval
    let score: Int
    
    var date: Date {
        Date(timeIntervalSince1970: time)
    }
}
