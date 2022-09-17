//

import Foundation

struct Comment: Decodable, Identifiable {
    enum ContainerCodingKeys: String, CodingKey {
        case kind
        case data
    }
    
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
    
    init(from decoder: Decoder) throws {
        let parentContainer = try decoder.container(keyedBy: ContainerCodingKeys.self)
        let container = try parentContainer.nestedContainer(
            keyedBy: CodingKeys.self,
            forKey: .data
        )
        
        self.id = try container.decode(String.self, forKey: .id)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.ups = try container.decodeIfPresent(Int.self, forKey: .ups)
    }
}
