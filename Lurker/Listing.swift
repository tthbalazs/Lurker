//

import Foundation

struct Listing: Decodable {
    enum CodingKeys: String, CodingKey {
        case children
    }
    
    let children: [Thing]
    
    // MARK: - Init methods
    
    init(from decoder: Decoder) throws {
        let parentContainer = try decoder.container(keyedBy: Thing.CodingKeys.self)
        let container = try parentContainer.nestedContainer(
            keyedBy: CodingKeys.self,
            forKey: .data
        )
        
        self.children = try container.decode([Thing].self, forKey: .children)
    }
}
