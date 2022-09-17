//

import Foundation

struct Listing: Decodable {
    enum ContainerCodingKeys: String, CodingKey {
        case kind
        case data
    }
    
    enum CodingKeys: String, CodingKey {
        case children
    }
    
    let children: [Thing]
    
    init(from decoder: Decoder) throws {
        let parentContainer = try decoder.container(keyedBy: ContainerCodingKeys.self)
        let container = try parentContainer.nestedContainer(
            keyedBy: CodingKeys.self,
            forKey: .data
        )
        
        self.children = try container.decode([Thing].self, forKey: .children)
    }
}

struct CommentsListing: Decodable {
    enum ContainerCodingKeys: String, CodingKey {
        case kind
        case data
    }
    
    enum CodingKeys: String, CodingKey {
        case children
    }
    
    let children: [Comment]
    
    init(from decoder: Decoder) throws {
        let parentContainer = try decoder.container(keyedBy: ContainerCodingKeys.self)
        let container = try parentContainer.nestedContainer(
            keyedBy: CodingKeys.self,
            forKey: .data
        )
        
        self.children = try container.decode([Comment].self, forKey: .children)
    }
}
