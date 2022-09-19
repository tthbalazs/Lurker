//

import Foundation

enum Thing: Decodable {
    case comment(Comment)
    case link(Link)
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case kind
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        
        switch kind {
        case "t1":
            let comment = try Comment(from: decoder)
            self = .comment(comment)
        case "t3":
            let link = try Link(from: decoder)
            self = .link(link)
        default:
            self = .unknown
        }
    }
    
    // MARK: - 
    
    var comment: Comment? {
        if case let .comment(comment) = self {
            return comment
        }
        return nil
    }
    
    var link: Link? {
        if case let .link(link) = self {
            return link
        }
        return nil
    }
}


