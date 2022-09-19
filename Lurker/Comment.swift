//

import Foundation

struct Comment: Decodable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case id
        case body
        case author
        case ups
    }
    
    let id: String
    let body: String?
    let author: String?
    let ups: Int?
    
    // MARK: - Init methods
    
    init(from decoder: Decoder) throws {
        let superContainer = try decoder.container(keyedBy: Thing.CodingKeys.self)
        let container = try superContainer.nestedContainer(
            keyedBy: CodingKeys.self,
            forKey: .data
        )
        
        self.id = try container.decode(String.self, forKey: .id)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.ups = try container.decodeIfPresent(Int.self, forKey: .ups)
    }
    
    init(id: String, body: String? = nil, author: String? = nil, ups: Int? = nil) {
        self.id = id
        self.body = body
        self.author = author
        self.ups = ups
    }
}
